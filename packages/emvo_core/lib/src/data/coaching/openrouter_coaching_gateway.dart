import 'dart:convert';

import 'package:fpdart/fpdart.dart';

import '../../domain/coaching/entities/message.dart';
import '../../domain/coaching/repositories/coaching_ai_gateway.dart';
import '../../domain/failures/failure.dart';
import 'openrouter_chat_client.dart';

/// OpenRouter-backed coach: chat turns, starters, and session insights.
class OpenRouterCoachingAiGateway implements CoachingAiGateway {
  OpenRouterCoachingAiGateway(this._client);

  final OpenRouterChatClient _client;

  static const _coachSystemPrompt = '''
You are Emvo, a warm, concise emotional intelligence (EQ) coach inside a mobile app.
Help users notice emotions, regulate responses, and build empathy. Keep answers supportive
and practical. Use short paragraphs or brief bullet points when helpful. Do not give
medical or crisis advice; encourage professional help for emergencies.

When the JSON includes an EQ assessment snapshot (overallScore, dimensionScores, growthDimensions),
use it as your main personalization signal—strengths, growth edges, and concrete practices.
Do not re-read scores every reply; weave them in when they help the user's question.

"dailyCheckIn" is a one-tap mood for today only (calendar day). It is background context, not
the topic of every message. Mention it at most once per conversation unless the user talks
about mood. For neutral labels (e.g. ok, fine, neutral, alright), do not repeatedly name or
validate that label—treat it as a steady baseline and move on to what they ask.

If both assessment and dailyCheckIn exist, weight the assessment for skill-building and use
the check-in only for tone when it is clearly relevant.
''';

  @override
  Future<Either<Failure, Message>> completeTurn({
    required CoachingSession session,
    required Message userMessage,
  }) async {
    try {
      final messages = <Map<String, String>>[
        {
          'role': 'system',
          'content': _systemWithContext(_coachSystemPrompt, session.context),
        },
      ];

      for (final m in session.messages) {
        final role = switch (m.sender) {
          MessageSender.user => 'user',
          MessageSender.coach => 'assistant',
          MessageSender.system => 'system',
        };
        if (m.content.trim().isEmpty) continue;
        messages.add({'role': role, 'content': m.content});
      }

      final text = await _client.complete(
        messages,
        maxTokens: 560,
        temperature: 0.7,
      );
      return Right(
        Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: text.trim(),
          sender: MessageSender.coach,
          timestamp: DateTime.now(),
          type: MessageType.text,
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Coach request failed: $e'));
    }
  }

  @override
  Stream<String> streamCoachTokens({
    required CoachingSession session,
    required Message userMessage,
  }) =>
      const Stream.empty();

  @override
  Future<Either<Failure, List<CoachingInsight>>> generateInsights({
    required CoachingSession session,
  }) async {
    final recent = session.messages
        .where((m) => m.sender == MessageSender.user)
        .take(8)
        .map((m) => m.content)
        .join('\n---\n');
    if (recent.trim().isEmpty) {
      return const Right([]);
    }
    try {
      final raw = await _client.complete(
        [
          {
            'role': 'system',
            'content':
                'You summarize coaching chat themes. Reply with ONLY valid JSON: '
                    '{"insights":[{"title":"short title","description":"1-2 sentences","relatedDimension":"selfAwareness|selfRegulation|empathy|socialSkills|null"}]} '
                    'Use 1-3 insights max. No markdown.',
          },
          {
            'role': 'user',
            'content': 'Recent user messages:\n$recent',
          },
        ],
        maxTokens: 380,
        temperature: 0.5,
      );
      final decoded =
          jsonDecode(_stripMarkdownJson(raw)) as Map<String, dynamic>;
      final list = decoded['insights'] as List<dynamic>? ?? [];
      final out = <CoachingInsight>[];
      for (final item in list.take(3)) {
        if (item is! Map<String, dynamic>) continue;
        final title = item['title']?.toString() ?? 'Insight';
        final desc = item['description']?.toString() ?? '';
        if (desc.isEmpty) continue;
        out.add(
          CoachingInsight(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: title,
            description: desc,
            generatedAt: DateTime.now(),
            relatedDimension: item['relatedDimension']?.toString(),
          ),
        );
      }
      return Right(out);
    } catch (e) {
      return Left(ServerFailure('Insights failed: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> suggestConversationStarters(
    Map<String, dynamic> userContext,
  ) async {
    try {
      var ctxLine = userContext.isEmpty
          ? 'No prior assessment context.'
          : 'User context (JSON): ${jsonEncode(userContext)}';
      final d = userContext['dailyCheckIn'];
      if (d is Map && d['moodLabel'] != null) {
        final label = d['moodLabel'].toString().toLowerCase().trim();
        const neutral = {
          'ok',
          'okay',
          'fine',
          'neutral',
          'alright',
          'all right',
          'meh',
          'average',
          'so-so',
          'normal'
        };
        if (!neutral.contains(label)) {
          ctxLine +=
              '\nThey checked in today as: ${d['moodLabel']}. You may reflect that lightly in one starter if it fits; do not make every starter about mood.';
        }
      }
      final raw = await _client.complete(
        [
          {
            'role': 'system',
            'content':
                'Reply with exactly 4 short first-person coaching prompts (one sentence each), '
                    'each on its own line. No numbering or bullets. Tailor lightly to their EQ context when provided.',
          },
          {
            'role': 'user',
            'content': 'Suggest 4 starters.\n$ctxLine',
          },
        ],
        maxTokens: 220,
        temperature: 0.75,
      );
      final lines = raw
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .take(4)
          .toList();
      if (lines.length >= 4) return Right(lines);
    } catch (_) {}
    return Right(_fallbackStarters(userContext));
  }

  static String _systemWithContext(
    String base,
    Map<String, dynamic>? context,
  ) {
    if (context == null || context.isEmpty) return base;
    try {
      return '$base\n\nUser EQ assessment snapshot (for personalization):\n${jsonEncode(context)}';
    } catch (_) {
      return base;
    }
  }

  static String _stripMarkdownJson(String raw) {
    var s = raw.trim();
    if (s.startsWith('```')) {
      s = s.replaceFirst(RegExp(r'^```\w*\n?'), '');
      s = s.replaceFirst(RegExp(r'\n?```\s*$'), '');
    }
    return s.trim();
  }

  static List<String> _fallbackStarters(Map<String, dynamic> userContext) {
    final growth = userContext['growthDimensions'] as List<dynamic>?;
    if (growth != null && growth.isNotEmpty) {
      final d = growth.first.toString();
      return [
        "I'd like to work on my $d — where should I start?",
        'What is one small habit that would raise my EQ this week?',
        'Help me notice my emotions earlier in stressful moments',
        'How can I respond instead of react when I feel triggered?',
      ];
    }
    return const [
      "I'm feeling overwhelmed today",
      'Help me prepare for a difficult conversation',
      'Why do I react so strongly to criticism?',
      'I want to improve my empathy',
    ];
  }
}

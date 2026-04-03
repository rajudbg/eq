import 'dart:convert';

import 'package:fpdart/fpdart.dart';

import '../../domain/failures/failure.dart';
import '../coaching/openrouter_chat_client.dart';

/// LLM-generated copy for the results screen; falls back to templates without an API key.
class AssessmentAiNarrative {
  const AssessmentAiNarrative({
    required this.headline,
    required this.narrative,
    required this.actions,
    this.usedLlm = false,
  });

  final String headline;
  final String narrative;
  final List<String> actions;
  final bool usedLlm;
}

class AssessmentAiNarrativeService {
  AssessmentAiNarrativeService._(this._client);

  final OpenRouterChatClient? _client;

  factory AssessmentAiNarrativeService.openRouter(OpenRouterChatClient client) =>
      AssessmentAiNarrativeService._(client);

  factory AssessmentAiNarrativeService.localOnly() =>
      AssessmentAiNarrativeService._(null);

  Future<Either<Failure, AssessmentAiNarrative>> generate(
    Map<String, dynamic> payload,
  ) async {
    final client = _client;
    if (client != null) {
      try {
        final raw = await client.complete([
          {
            'role': 'system',
            'content':
                'You write clear, warm EQ results copy for a free tier: one comprehensive analysis. '
                'Output ONLY valid JSON with keys: '
                'headline (max 12 words, inviting), '
                'narrative (4–6 short paragraphs, plain text, separate with \\n\\n). The narrative MUST: '
                '(1) explain what the overall and dimension scores mean—they are 0–100 from scenario-based choices, '
                'a practical snapshot not a medical or IQ test; '
                '(2) briefly interpret this user’s pattern using the JSON (strengths and growth areas); '
                '(3) explain why emotional intelligence matters in relationships, work, and wellbeing, in plain language; '
                '(4) tie “why it matters” to their specific scores where natural. '
                'Stay encouraging, non-judgmental, no clinical claims. '
                'actions: array of exactly 3 short imperative micro-habits for this week. '
                'No markdown, no code fences.',
          },
          {
            'role': 'user',
            'content':
                'Write this free comprehensive EQ analysis from the assessment JSON:\n${jsonEncode(payload)}',
          },
        ]);
        final parsed = _parseNarrativeJson(raw);
        if (parsed != null) {
          return Right(parsed);
        }
        return Right(_localNarrative(payload));
      } catch (_) {
        return Right(_localNarrative(payload));
      }
    }
    return Right(_localNarrative(payload));
  }

  AssessmentAiNarrative _localNarrative(Map<String, dynamic> payload) {
    final overall = (payload['overallScore'] as num?)?.round() ?? 50;
    final insights = payload['insights'] as List<dynamic>? ?? [];
    String? weakest;
    String? strongest;
    double low = 100;
    double high = -1;
    for (final i in insights) {
      if (i is Map<String, dynamic>) {
        final s = i['score'];
        final dim = i['dimension']?.toString() ?? 'this area';
        if (s is num) {
          final v = s.toDouble();
          if (v < low) {
            low = v;
            weakest = dim;
          }
          if (v > high) {
            high = v;
            strongest = dim;
          }
        }
      }
    }

    final headline = overall >= 75
        ? 'Strong emotional awareness is already on your side'
        : overall >= 55
            ? 'You are building a solid EQ foundation'
            : 'Small shifts here will compound quickly';

    final p1 =
        'Your numbers are on a 0–100 scale from scenario-based choices. They describe tendencies—how you notice feelings, regulate reactions, and navigate social situations—not a medical diagnosis, IQ score, or fixed label. Think of them as a snapshot you can grow from.';

    final p2 =
        'Emotional intelligence quietly shapes everyday life: how you recover after conflict, how clearly you communicate under stress, how supported others feel around you, and how steady your own mood tends to be. Improving these skills often means fewer regrets after hard conversations and more trust at work and home.';

    final p3 = (weakest != null && strongest != null && weakest != strongest)
        ? 'In your profile, **$strongest** is relatively strong right now, while **$weakest** is the ripest area to practice—that imbalance is common, and focused work there usually produces the fastest visible wins.'
        : weakest != null
            ? 'Your pattern points to **$weakest** as a key growth edge. That is normal; targeted practice there tends to unlock the biggest gains in relationships and stress.'
            : 'Your scores form a unique mix. Rather than fixing everything at once, pick one dimension to notice for a week—small, repeated awareness changes the system.';

    final p4 =
        'Use the coach and the plan below to rehearse real moments: naming emotions, pacing responses, and stating needs clearly. Consistency beats intensity.';

    final actions = <String>[
      if (weakest != null)
        'This week, notice one moment where $weakest shows up and name the feeling before you act'
      else
        'Once daily, label an emotion in one sentence before reacting',
      'After a stressful exchange, write two lines: what you felt vs. what you needed',
      'Open the coach before a conversation you are unsure about and rehearse your first sentence',
    ];

    return AssessmentAiNarrative(
      headline: headline,
      narrative: '$p1\n\n$p2\n\n$p3\n\n$p4',
      actions: actions,
      usedLlm: false,
    );
  }

  AssessmentAiNarrative? _parseNarrativeJson(String raw) {
    var s = raw.trim();
    if (s.startsWith('```')) {
      s = s.replaceFirst(RegExp(r'^```\w*\n?'), '');
      s = s.replaceFirst(RegExp(r'\n?```\s*$'), '');
    }
    try {
      final m = jsonDecode(s) as Map<String, dynamic>;
      final headline = m['headline']?.toString().trim() ?? '';
      final narrative = m['narrative']?.toString().trim() ?? '';
      final actionsRaw = m['actions'];
      final actions = <String>[];
      if (actionsRaw is List) {
        for (final a in actionsRaw.take(5)) {
          final t = a.toString().trim();
          if (t.isNotEmpty) actions.add(t);
        }
      }
      if (headline.isEmpty || narrative.isEmpty || actions.length < 2) {
        return null;
      }
      while (actions.length < 3) {
        actions.add('Keep one micro-habit visible on your lock screen this week');
      }
      return AssessmentAiNarrative(
        headline: headline,
        narrative: narrative,
        actions: actions.take(3).toList(),
        usedLlm: true,
      );
    } catch (_) {
      return null;
    }
  }
}

AssessmentAiNarrativeService createAssessmentAiNarrativeService() {
  const apiKey = String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: '',
  );
  const model = String.fromEnvironment(
    'OPENROUTER_MODEL',
    defaultValue: 'qwen/qwen3.6-plus:free',
  );
  if (apiKey.isEmpty) {
    return AssessmentAiNarrativeService.localOnly();
  }
  return AssessmentAiNarrativeService.openRouter(
    OpenRouterChatClient(apiKey: apiKey, model: model),
  );
}

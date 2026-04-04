import 'dart:convert';

import 'package:fpdart/fpdart.dart';

import '../../domain/failures/failure.dart';
import '../coaching/openrouter_chat_client.dart';

/// JSON payload uses [EQDimension.name] (e.g. selfAwareness); turn into readable copy.
String _dimensionDisplayName(String raw) {
  switch (raw) {
    case 'selfAwareness':
      return 'Self-Awareness';
    case 'selfRegulation':
      return 'Self-Regulation';
    case 'empathy':
      return 'Empathy';
    case 'socialSkills':
      return 'Social Skills';
    default:
      return raw;
  }
}

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

  factory AssessmentAiNarrativeService.openRouter(
          OpenRouterChatClient client) =>
      AssessmentAiNarrativeService._(client);

  factory AssessmentAiNarrativeService.localOnly() =>
      AssessmentAiNarrativeService._(null);

  Future<Either<Failure, AssessmentAiNarrative>> generate(
    Map<String, dynamic> payload,
  ) async {
    final client = _client;
    if (client != null) {
      try {
        String userPayload;
        try {
          userPayload = jsonEncode(payload);
        } catch (_) {
          userPayload = '{"overallScore":${payload['overallScore'] ?? 0}}';
        }
        final raw = await client.complete(
          [
            {
              'role': 'system',
              'content': 'You write clear, warm EQ results copy for a mobile app. Be concise—users wait on a loading screen. '
                  'Output ONLY valid JSON with keys: '
                  'headline (max 10 words, inviting), '
                  'narrative (2–3 short paragraphs only, plain text, separate with \\n\\n; each paragraph max 3 sentences; '
                  'no filler). The narrative MUST still cover: '
                  '(1) what 0–100 scores mean (each dimension vs strongest answers per question—not clinical); '
                  '(2) one line on their pattern from the JSON; '
                  '(3) one line on why EQ matters for them, tied lightly to scores. '
                  'Stay encouraging, non-judgmental. '
                  'actions: array of exactly 3 items, each one concrete imperative sentence (when/where), doable this week. '
                  'No markdown, no code fences.',
            },
            {
              'role': 'user',
              'content':
                  'Write this EQ analysis from the assessment JSON:\n$userPayload',
            },
          ],
          maxTokens: 720,
          temperature: 0.65,
        );
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
    String? weakestKey;
    String? strongestKey;
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
            weakestKey = dim;
          }
          if (v > high) {
            high = v;
            strongestKey = dim;
          }
        }
      }
    }

    final weakest =
        weakestKey == null ? null : _dimensionDisplayName(weakestKey);
    final strongest =
        strongestKey == null ? null : _dimensionDisplayName(strongestKey);

    final headline = overall >= 75
        ? 'Strong emotional awareness is already on your side'
        : overall >= 55
            ? 'You are building a solid EQ foundation'
            : 'Small shifts here will compound quickly';

    final p1 =
        'Your numbers are on a 0–100 scale: each dimension compares your raw points to the best you could score on the questions you answered, so they reflect how often you picked stronger responses—not a medical diagnosis, IQ score, or fixed label. Think of them as a snapshot you can grow from.';

    final p2 =
        'Emotional intelligence quietly shapes everyday life: how you recover after conflict, how clearly you communicate under stress, how supported others feel around you, and how steady your own mood tends to be. Improving these skills often means fewer regrets after hard conversations and more trust at work and home.';

    final p3 = (weakest != null &&
            strongest != null &&
            weakestKey != strongestKey)
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
    final candidates = <String>{s};
    final start = s.indexOf('{');
    final end = s.lastIndexOf('}');
    if (start >= 0 && end > start) {
      candidates.add(s.substring(start, end + 1));
    }
    for (final chunk in candidates) {
      final parsed = _tryParseNarrativeMap(chunk);
      if (parsed != null) return parsed;
    }
    return null;
  }

  AssessmentAiNarrative? _tryParseNarrativeMap(String s) {
    try {
      final decoded = jsonDecode(s);
      if (decoded is! Map) return null;
      final m = Map<String, dynamic>.from(decoded);
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
      if (headline.isEmpty || narrative.isEmpty) return null;
      if (actions.isEmpty) {
        actions
            .add('Name one emotion before you react in a tense moment today');
      }
      while (actions.length < 3) {
        actions
            .add('Keep one micro-habit visible on your lock screen this week');
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
    defaultValue: 'stepfun/step-3.5-flash:free',
  );
  if (apiKey.isEmpty) {
    return AssessmentAiNarrativeService.localOnly();
  }
  return AssessmentAiNarrativeService.openRouter(
    OpenRouterChatClient(apiKey: apiKey, model: model),
  );
}

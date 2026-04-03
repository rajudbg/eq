import 'dart:math';

import 'package:fpdart/fpdart.dart';

import '../../domain/coaching/entities/message.dart';
import '../../domain/coaching/repositories/coaching_ai_gateway.dart';
import '../../domain/failures/failure.dart';

/// Evidence-style local coach when no API key: uses assessment context + varied
/// reflective prompts (no brittle single-keyword routing).
class LocalContextCoachingAiGateway implements CoachingAiGateway {
  LocalContextCoachingAiGateway({Random? random})
      : _random = random ?? Random();

  final Random _random;

  static const _techniques = <String>[
    'Try naming the emotion out loud or in writing—labeling reduces amygdala activation.',
    'Take three slow breaths, exhaling longer than you inhale, before you reply to anyone.',
    'Ask yourself: "What do I need right now—support, space, or clarity?"',
    'Picture the situation from the other person’s goal: what might they be protecting?',
    'Ground with 5-4-3-2-1 (senses) for 60 seconds when intensity spikes.',
    'Use "I feel ___ when ___ because ___" to own your experience without blaming.',
    'Delay important replies by one hour when you are above a 7/10 emotionally.',
    'Notice where tension lives in your body—that is data, not weakness.',
  ];

  static const _reflectivePrompts = <String>[
    'What story are you telling yourself about this situation, and what is one alternative story?',
    'If a close friend felt the way you do now, what would you say to them?',
    'What is one boundary you could honor here without needing the other person to change first?',
    'What would "good enough" look like in the next 24 hours—not perfect, just workable?',
    'When have you navigated something similar before, even partially? What helped then?',
    'What is the smallest next step that respects both your values and your limits?',
    'What emotion is underneath the one on the surface (e.g. fear under anger)?',
    'How do you want to feel walking away from this interaction—and what choice moves you toward that?',
    'What need of yours feels unmet right now—connection, fairness, autonomy, or rest?',
    'If you zoom out six months, how much will this moment matter—and what deserves your energy today?',
    'What is one thing you can control today versus one you must release?',
    'What would curiosity sound like in your next sentence, instead of defense?',
  ];

  @override
  Future<Either<Failure, Message>> completeTurn({
    required CoachingSession session,
    required Message userMessage,
  }) async {
    await Future<void>.delayed(
        Duration(milliseconds: 400 + _random.nextInt(500)));

    final ctx = session.context ?? {};
    final coachReplies =
        session.messages.where((m) => m.sender == MessageSender.coach).length;
    final preamble = (coachReplies == 0 ? _dailyMoodPreamble(ctx) : '') +
        _assessmentPreamble(ctx);
    final reflection = _reflectivePrompts[
        (session.messages.length + userMessage.content.hashCode).abs() %
            _reflectivePrompts.length];
    final technique = _pickTechnique(userMessage.content);

    final body = _composeReply(
      preamble: preamble,
      acknowledgment: _acknowledge(userMessage.content),
      reflection: reflection,
      technique: technique,
    );

    return Right(
      Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: body,
        sender: MessageSender.coach,
        timestamp: DateTime.now(),
        type: MessageType.text,
      ),
    );
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
    final userTexts = session.messages
        .where((m) => m.sender == MessageSender.user)
        .map((m) => m.content.toLowerCase())
        .join(' ');
    if (userTexts.trim().isEmpty) return const Right([]);

    final themes = <String, String>{
      'stress':
          'You have been naming pressure and overload—building regulation skills here will compound.',
      'work':
          'Work themes are showing up; small boundary experiments often beat big confrontations.',
      'relationship':
          'Relationships are central in this thread—clarity on needs may unlock next steps.',
      'family':
          'Family dynamics can activate deep patterns; self-compassion is part of the work.',
      'angry':
          'Intensity has appeared; pacing responses and naming underlying needs can help.',
      'anxious':
          'Worry has surfaced; grounding and shrinking the horizon to the next right step can help.',
    };

    final insights = <CoachingInsight>[];
    for (final e in themes.entries) {
      if (userTexts.contains(e.key) && insights.length < 2) {
        insights.add(
          CoachingInsight(
            id: '${e.key}-${DateTime.now().millisecondsSinceEpoch}',
            title: 'Theme: ${e.key}',
            description: e.value,
            generatedAt: DateTime.now(),
          ),
        );
      }
    }

    if (insights.isEmpty) {
      insights.add(
        CoachingInsight(
          id: 'general-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Keep exploring',
          description:
              'You are building awareness simply by putting experience into words. '
              'Notice one emotional shift between messages—that is progress.',
          generatedAt: DateTime.now(),
        ),
      );
    }
    return Right(insights);
  }

  @override
  Future<Either<Failure, List<String>>> suggestConversationStarters(
    Map<String, dynamic> userContext,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    // Prefer EQ snapshot over a generic daily mood (especially "ok").
    final growth = userContext['growthDimensions'] as List<dynamic>?;
    if (growth != null && growth.isNotEmpty) {
      final d = growth.first.toString();
      return Right([
        "I'd like to build my $d—what's one practice I can try this week?",
        'Help me debrief a conversation that did not go how I wanted',
        'I want to stay calm when I get critical feedback',
        'How do I show empathy without losing my own boundaries?',
      ]);
    }
    final overall = userContext['overallScore'];
    if (overall is num && overall < 55) {
      return Right([
        'I want to understand my emotional patterns better',
        'What is a gentle first step to raise my EQ?',
        'Help me prepare for a stressful week ahead',
        'How do I stop spiraling when one thing goes wrong?',
      ]);
    }
    if (overall is num) {
      return Right([
        'I want to turn my assessment insights into one daily habit',
        'Help me prepare for a difficult conversation',
        'Why do I react so strongly to criticism?',
        'Teach me a quick calming technique I can use today',
      ]);
    }
    final daily = userContext['dailyCheckIn'];
    if (daily is Map) {
      final mood = daily['moodLabel']?.toString() ?? '';
      if (mood.isNotEmpty) {
        final m = mood.toLowerCase().trim();
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
          'normal',
        };
        if (neutral.contains(m)) {
          return Right([
            "I'm feeling overwhelmed today",
            'Help me prepare for a difficult conversation',
            'Why do I react so strongly to criticism?',
            'Teach me a quick calming technique',
          ]);
        }
        if (m == 'low' || m == 'down') {
          return Right([
            "I'm feeling $mood today—can we take this gently?",
            'One small thing I could do in the next hour to feel a bit steadier?',
            'Help me name what might be underneath this heavy mood',
            'A short grounding or breathing idea I can try right now',
          ]);
        }
        if (m == 'great' || m == 'good') {
          return Right([
            "I'm feeling $mood—how do I channel this into relationships?",
            'I want to keep this energy—what EQ habit should I reinforce?',
            'Help me notice what helped me feel this way today',
            'Turn a good day into momentum: one stretch goal for empathy?',
          ]);
        }
        return Right([
          "I checked in as feeling $mood—what does that suggest for today?",
          'Help me understand this mood without judging it',
          'One conversation I could handle better with this mood in mind',
          'What should I watch out for when I feel like this?',
        ]);
      }
    }
    return Right([
      "I'm feeling overwhelmed today",
      'Help me prepare for a difficult conversation',
      'Why do I react so strongly to criticism?',
      'I want to turn insights from my assessment into daily habits',
    ]);
  }

  String _dailyMoodPreamble(Map<String, dynamic> ctx) {
    final raw = ctx['dailyCheckIn'];
    if (raw is! Map) return '';
    final mood = raw['moodLabel']?.toString();
    if (mood == null || mood.isEmpty) return '';
    final m = mood.toLowerCase().trim();
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
      'normal',
    };
    if (neutral.contains(m)) return '';
    return 'The user checked in today as **$mood** (self-reported). Mention at most once if '
        'natural; do not keep repeating it.\n\n';
  }

  String _assessmentPreamble(Map<String, dynamic> ctx) {
    final overall = ctx['overallScore'];
    final growth = ctx['growthDimensions'] as List<dynamic>?;
    if (overall == null && (growth == null || growth.isEmpty)) {
      return '';
    }
    final buf = StringBuffer();
    if (overall is num) {
      buf.write(
        'From your recent EQ snapshot, you are working with a broad overall level around '
        '${overall.round()}/100—numbers are a compass, not a verdict.\n\n',
      );
    }
    if (growth != null && growth.isNotEmpty) {
      final top = growth.take(2).join(' and ');
      buf.write(
        'A useful focus area from that profile is **$top**—we can tie today’s chat to small, '
        'real-life experiments there.\n\n',
      );
    }
    return buf.toString();
  }

  String _acknowledge(String text) {
    final t = text.toLowerCase();
    if (t.contains('thank')) {
      return 'You are welcome. ';
    }
    if (t.contains('?')) {
      return 'That is an important question. ';
    }
    if (t.length < 24) {
      return 'Thanks for sharing that. ';
    }
    return 'Thanks for opening up about this. ';
  }

  String _pickTechnique(String userMessage) {
    final t = userMessage.toLowerCase();
    var idx = t.hashCode.abs() % _techniques.length;
    if (t.contains('breath') || t.contains('calm') || t.contains('anx')) {
      idx = 1;
    } else if (t.contains('angry') || t.contains('frustrat')) {
      idx = 5;
    } else if (t.contains('work') || t.contains('boss')) {
      idx = 3;
    }
    return _techniques[idx % _techniques.length];
  }

  String _composeReply({
    required String preamble,
    required String acknowledgment,
    required String reflection,
    required String technique,
  }) {
    final templates = <String>[
      '$preamble$acknowledgment$reflection\n\n**Try this:** $technique',
      '$preamble$acknowledgment**Reflect:** $reflection\n\n**Micro-practice:** $technique',
      '$preamble$acknowledgment$reflection\n\nOne concrete experiment: $technique',
    ];
    return templates[_random.nextInt(templates.length)];
  }
}

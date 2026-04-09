/// Monthly EQ challenge data and state management.
///
/// Each challenge is a 7-day practice that targets one EQ skill.
/// Users opt in, then check off each day during their daily check-in.
library;

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kActiveChallengeKey = 'eq_challenge.active_json';
const _kChallengeHistoryKey = 'eq_challenge.history_json';

/// A single EQ challenge definition.
class EqChallenge {
  const EqChallenge({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.dailyAction,
    required this.dimension,
    this.durationDays = 7,
    this.emoji = '🎯',
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String dailyAction;
  final String dimension;
  final int durationDays;
  final String emoji;
}

/// Pre-built challenge library — rotates monthly.
const List<EqChallenge> challengeLibrary = [
  EqChallenge(
    id: 'ch_name_it',
    title: 'Name It to Tame It',
    subtitle: '7 days of emotional precision',
    description:
        'Each day, pause 3 times to name your exact emotion (not just "good" '
        'or "bad"). Use the emotion wheel if you need help. By day 7, '
        'emotional labeling becomes automatic.',
    dailyAction: 'Name 3 specific emotions today',
    dimension: 'selfAwareness',
    emoji: '🏷️',
  ),
  EqChallenge(
    id: 'ch_pause_respond',
    title: 'Pause Before You Respond',
    subtitle: '7 days of intentional delay',
    description:
        'Before replying to any emotionally charged message or comment, '
        'wait 10 seconds. Notice the urge to react immediately — then '
        'choose your response instead of reflexing.',
    dailyAction: 'Pause 10 seconds before 2 emotional responses',
    dimension: 'selfRegulation',
    emoji: '⏸️',
  ),
  EqChallenge(
    id: 'ch_curious_listener',
    title: 'The Curious Listener',
    subtitle: '7 days of asking, not telling',
    description:
        'In every conversation today, ask at least one genuine follow-up '
        'question before sharing your own perspective. The goal: understand '
        'first, respond second.',
    dailyAction: 'Ask one "tell me more" follow-up in a conversation',
    dimension: 'empathy',
    emoji: '👂',
  ),
  EqChallenge(
    id: 'ch_repair_bid',
    title: 'The Repair Bid',
    subtitle: '7 days of relational maintenance',
    description:
        'Each day, send one "repair" message to someone — a text to check '
        'in, an apology for something small, or a compliment you\'ve been '
        'holding back. Relationships grow through micro-repairs.',
    dailyAction: 'Send one repair or reconnection message',
    dimension: 'socialSkills',
    emoji: '🔧',
  ),
  EqChallenge(
    id: 'ch_body_scan',
    title: 'The 6-Second Body Scan',
    subtitle: '7 days of somatic awareness',
    description:
        'Three times today, stop and scan: head, shoulders, stomach, hands. '
        'Name what your body is feeling before your mind labels it. By '
        'week\'s end, you\'ll catch emotions 10 seconds earlier.',
    dailyAction: 'Do 3 body scans (6 seconds each)',
    dimension: 'selfAwareness',
    emoji: '🫁',
  ),
  EqChallenge(
    id: 'ch_gratitude_anchor',
    title: 'Gratitude Anchor',
    subtitle: '7 days of noticing good',
    description:
        'Before bed, name one specific moment from today that you\'re '
        'grateful for — not a generic "family" or "health," but a specific '
        'moment: "The way my coworker laughed at my joke at 2pm."',
    dailyAction: 'Name one specific grateful moment tonight',
    dimension: 'empathy',
    emoji: '🙏',
  ),
  EqChallenge(
    id: 'ch_energy_audit',
    title: 'Social Energy Audit',
    subtitle: '7 days of tracking your social battery',
    description:
        'After every significant interaction today, rate it: did it charge '
        'you (+) or drain you (-)? By day 7, you\'ll see clear patterns '
        'in who and what refills your emotional tank.',
    dailyAction: 'Rate 3 interactions as charging (+) or draining (-)',
    dimension: 'socialSkills',
    emoji: '🔋',
  ),
  EqChallenge(
    id: 'ch_no_advice',
    title: 'The No-Advice Challenge',
    subtitle: '7 days of just listening',
    description:
        'When someone shares a problem, resist the urge to fix it. Instead, '
        'say "That sounds really hard" or "How are you feeling about it?" — '
        'nothing else. Most people want validation, not solutions.',
    dailyAction: 'Respond to one problem with empathy only (no advice)',
    dimension: 'empathy',
    emoji: '🤐',
  ),
  EqChallenge(
    id: 'ch_emotional_hangover',
    title: 'Clear the Emotional Hangover',
    subtitle: '7 days of mood transitions',
    description:
        'Before each major transition (work → home, meeting → focus time), '
        'take 60 seconds to consciously close the previous emotional chapter. '
        'Ask: "Am I carrying anything from the last hour?"',
    dailyAction: 'Do a 60-second emotional reset at 2 transitions',
    dimension: 'selfRegulation',
    emoji: '🍷',
  ),
  EqChallenge(
    id: 'ch_boundary_practice',
    title: 'Healthy Boundaries Week',
    subtitle: '7 days of respectful "no"',
    description:
        'Practice declining one thing each day that you\'d normally say yes '
        'to out of guilt. Use the formula: "I\'d love to, but I can\'t this '
        'time." No explanation needed.',
    dailyAction: 'Say one respectful "no" today',
    dimension: 'selfRegulation',
    emoji: '🚧',
  ),
  EqChallenge(
    id: 'ch_read_the_room',
    title: 'Read the Room',
    subtitle: '7 days of group awareness',
    description:
        'At the start of every group interaction (meeting, dinner, gathering), '
        'spend 30 seconds observing before participating. Who\'s engaged? '
        'Who\'s checked out? Where\'s the energy?',
    dailyAction: 'Observe a group for 30 seconds before joining',
    dimension: 'socialSkills',
    emoji: '🏠',
  ),
  EqChallenge(
    id: 'ch_tell_me_more',
    title: 'Three Words That Change Everything',
    subtitle: '7 days of "Tell me more"',
    description:
        'Replace your default response in conversations with "Tell me more." '
        'Use it at least twice today. Notice how it shifts the dynamic — '
        'the other person feels heard, and you learn more.',
    dailyAction: 'Say "Tell me more" at least twice today',
    dimension: 'socialSkills',
    emoji: '💬',
  ),
];

/// Returns this month's featured challenge based on calendar month.
EqChallenge challengeForMonth(DateTime date) {
  final index = (date.year * 12 + date.month) % challengeLibrary.length;
  return challengeLibrary[index];
}

/// The user's active challenge state.
class ActiveChallenge {
  const ActiveChallenge({
    required this.challengeId,
    required this.startedAt,
    required this.completedDays,
    required this.totalDays,
  });

  final String challengeId;
  final DateTime startedAt;
  final Set<int> completedDays; // day indices (0-based) the user checked off
  final int totalDays;

  bool get isCompleted => completedDays.length >= totalDays;
  int get currentDay {
    final elapsed = DateTime.now().difference(startedAt).inDays;
    return elapsed.clamp(0, totalDays - 1);
  }

  double get progress => completedDays.length / totalDays;

  EqChallenge? get challenge {
    try {
      return challengeLibrary.firstWhere((c) => c.id == challengeId);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
        'challengeId': challengeId,
        'startedAt': startedAt.toIso8601String(),
        'completedDays': completedDays.toList(),
        'totalDays': totalDays,
      };

  static ActiveChallenge? fromJson(Map<String, dynamic>? m) {
    if (m == null) return null;
    return ActiveChallenge(
      challengeId: m['challengeId'] as String,
      startedAt: DateTime.parse(m['startedAt'] as String),
      completedDays:
          (m['completedDays'] as List).map((e) => e as int).toSet(),
      totalDays: m['totalDays'] as int,
    );
  }
}

class ChallengeState {
  const ChallengeState({
    this.active,
    this.completedCount = 0,
  });

  final ActiveChallenge? active;
  final int completedCount;
}

class ChallengeNotifier extends StateNotifier<ChallengeState> {
  ChallengeNotifier() : super(const ChallengeState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    ActiveChallenge? active;
    final raw = prefs.getString(_kActiveChallengeKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        active = ActiveChallenge.fromJson(
            jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {}
    }

    int completedCount = 0;
    final histRaw = prefs.getString(_kChallengeHistoryKey);
    if (histRaw != null && histRaw.isNotEmpty) {
      try {
        completedCount = (jsonDecode(histRaw) as List).length;
      } catch (_) {}
    }

    state = ChallengeState(
      active: active,
      completedCount: completedCount,
    );
  }

  /// Start a new challenge.
  Future<void> startChallenge(EqChallenge challenge) async {
    final active = ActiveChallenge(
      challengeId: challenge.id,
      startedAt: DateTime.now(),
      completedDays: const {},
      totalDays: challenge.durationDays,
    );
    state = ChallengeState(
      active: active,
      completedCount: state.completedCount,
    );
    await _persist(active);
  }

  /// Check off today.
  Future<void> checkOffToday() async {
    final active = state.active;
    if (active == null) return;

    final day = active.currentDay;
    final updated = ActiveChallenge(
      challengeId: active.challengeId,
      startedAt: active.startedAt,
      completedDays: {...active.completedDays, day},
      totalDays: active.totalDays,
    );

    if (updated.isCompleted) {
      // Archive and clear.
      await _archiveCompleted(updated);
      state = ChallengeState(
        active: null,
        completedCount: state.completedCount + 1,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kActiveChallengeKey);
    } else {
      state = ChallengeState(
        active: updated,
        completedCount: state.completedCount,
      );
      await _persist(updated);
    }
  }

  /// Abandon the active challenge.
  Future<void> abandon() async {
    state = ChallengeState(
      active: null,
      completedCount: state.completedCount,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kActiveChallengeKey);
  }

  Future<void> _persist(ActiveChallenge active) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kActiveChallengeKey, jsonEncode(active.toJson()));
  }

  Future<void> _archiveCompleted(ActiveChallenge completed) async {
    final prefs = await SharedPreferences.getInstance();
    final histRaw = prefs.getString(_kChallengeHistoryKey);
    List<dynamic> hist = [];
    if (histRaw != null && histRaw.isNotEmpty) {
      try {
        hist = jsonDecode(histRaw) as List;
      } catch (_) {}
    }
    hist.add(completed.toJson());
    await prefs.setString(_kChallengeHistoryKey, jsonEncode(hist));
  }
}

final challengeProvider =
    StateNotifierProvider<ChallengeNotifier, ChallengeState>((ref) {
  return ChallengeNotifier();
});

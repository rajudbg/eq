import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_assessment/emvo_assessment.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kPulseResultKey = 'eq_pulse.latest_json';
const _kPulseWeekKey = 'eq_pulse.week_key';
const _kPulseHistoryKey = 'eq_pulse.history_json';
const _kMaxPulseHistory = 12;

/// ISO week string for deduplication: "2026-W15"
String _weekKey(DateTime d) {
  final l = d.toLocal();
  // ISO week: Mon-based.  Simple approximation good enough for streak logic.
  final jan1 = DateTime(l.year, 1, 1);
  final daysSinceJan1 = l.difference(jan1).inDays;
  final weekNum = ((daysSinceJan1 + jan1.weekday - 1) / 7).ceil();
  return '${l.year}-W${weekNum.toString().padLeft(2, '0')}';
}

/// A single pulse snapshot (3 questions, 4 dimension mini-scores).
class EqPulseResult {
  const EqPulseResult({
    required this.weekKey,
    required this.completedAt,
    required this.dimensionScores,
    required this.focusDimension,
  });

  final String weekKey;
  final DateTime completedAt;
  final Map<String, double> dimensionScores;
  final String focusDimension; // weakest dimension that was emphasized

  Map<String, dynamic> toJson() => {
        'weekKey': weekKey,
        'completedAt': completedAt.toIso8601String(),
        'dimensionScores': dimensionScores,
        'focusDimension': focusDimension,
      };

  static EqPulseResult? fromJson(Map<String, dynamic>? m) {
    if (m == null) return null;
    final wk = m['weekKey']?.toString();
    final ca = m['completedAt']?.toString();
    final ds = m['dimensionScores'];
    final fd = m['focusDimension']?.toString();
    if (wk == null || ca == null || ds == null || fd == null) return null;
    return EqPulseResult(
      weekKey: wk,
      completedAt: DateTime.parse(ca),
      dimensionScores: (ds as Map).map(
        (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
      ),
      focusDimension: fd,
    );
  }
}

class EqPulseState {
  const EqPulseState({
    this.latestPulse,
    this.history = const [],
    this.completedThisWeek = false,
    this.pulseQuestions = const [],
    this.focusDimension,
  });

  final EqPulseResult? latestPulse;
  final List<EqPulseResult> history;
  final bool completedThisWeek;

  /// 3 questions selected for this week's pulse (populated when not yet completed).
  final List<Question> pulseQuestions;

  /// The weakest dimension from the last full assessment (drives adaptive Q selection).
  final String? focusDimension;
}

class EqPulseNotifier extends StateNotifier<EqPulseState> {
  EqPulseNotifier(this._ref) : super(const EqPulseState()) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final currentWeek = _weekKey(DateTime.now());

    // Load history.
    final histRaw = prefs.getString(_kPulseHistoryKey);
    var history = <EqPulseResult>[];
    if (histRaw != null && histRaw.isNotEmpty) {
      try {
        final list = jsonDecode(histRaw) as List;
        history = list
            .whereType<Map>()
            .map((e) => EqPulseResult.fromJson(Map<String, dynamic>.from(e)))
            .whereType<EqPulseResult>()
            .toList();
      } catch (_) {}
    }

    // Load latest.
    EqPulseResult? latest;
    final latestRaw = prefs.getString(_kPulseResultKey);
    if (latestRaw != null && latestRaw.isNotEmpty) {
      try {
        latest =
            EqPulseResult.fromJson(jsonDecode(latestRaw) as Map<String, dynamic>);
      } catch (_) {}
    }

    final done = prefs.getString(_kPulseWeekKey) == currentWeek;

    // Determine weakest dimension from latest full assessment.
    String? weakest;
    try {
      final repo = _ref.read(assessmentRepositoryProvider);
      final historyResult = await repo.getHistory();
      historyResult.fold(
        (_) {},
        (results) {
          if (results.isNotEmpty) {
            final last = results.last;
            final sorted = last.dimensionScores.entries.toList()
              ..sort((a, b) => a.value.compareTo(b.value));
            weakest = sorted.first.key.name;
          }
        },
      );
    } catch (_) {}

    state = EqPulseState(
      latestPulse: latest,
      history: history,
      completedThisWeek: done,
      focusDimension: weakest,
    );
  }

  /// Select 3 adaptive questions from the given [allQuestions]:
  /// 1 targeting the weakest dimension, 2 random from other dimensions.
  List<Question> selectPulseQuestions(List<Question> allQuestions) {
    final rng = Random(DateTime.now().millisecondsSinceEpoch ~/ 86400000);
    final weakDim = state.focusDimension ?? 'selfAwareness';

    // Pool: questions targeting the weakest dim.
    final weakPool = allQuestions
        .where((q) => q.primaryDimension.name == weakDim)
        .toList();
    // Pool: everything else.
    final otherPool = allQuestions
        .where((q) => q.primaryDimension.name != weakDim)
        .toList();

    weakPool.shuffle(rng);
    otherPool.shuffle(rng);

    final picked = <Question>[];
    if (weakPool.isNotEmpty) picked.add(weakPool.first);
    for (final q in otherPool) {
      if (picked.length >= 3) break;
      // Avoid duplicate primary dimensions in the other 2 picks.
      if (picked.every((p) => p.primaryDimension != q.primaryDimension)) {
        picked.add(q);
      }
    }
    // Fill any remaining slots.
    for (final q in otherPool) {
      if (picked.length >= 3) break;
      if (!picked.contains(q)) picked.add(q);
    }

    state = EqPulseState(
      latestPulse: state.latestPulse,
      history: state.history,
      completedThisWeek: state.completedThisWeek,
      pulseQuestions: picked.take(3).toList(),
      focusDimension: state.focusDimension,
    );

    return state.pulseQuestions;
  }

  /// Score the pulse from the user's answers and persist.
  Future<EqPulseResult> completePulse(Map<String, String> answers) async {
    final questions = state.pulseQuestions;
    final repo = _ref.read(assessmentRepositoryProvider);
    final result = repo.calculateResult(
      answers: answers,
      questions: questions,
    );

    final weekKey = _weekKey(DateTime.now());
    final pulse = EqPulseResult(
      weekKey: weekKey,
      completedAt: DateTime.now(),
      dimensionScores: result.dimensionScores.map(
        (k, v) => MapEntry(k.name, v),
      ),
      focusDimension: state.focusDimension ?? 'selfAwareness',
    );

    // Persist.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPulseResultKey, jsonEncode(pulse.toJson()));
    await prefs.setString(_kPulseWeekKey, weekKey);

    var history = [...state.history, pulse];
    if (history.length > _kMaxPulseHistory) {
      history = history.sublist(history.length - _kMaxPulseHistory);
    }
    await prefs.setString(
      _kPulseHistoryKey,
      jsonEncode(history.map((e) => e.toJson()).toList()),
    );

    state = EqPulseState(
      latestPulse: pulse,
      history: history,
      completedThisWeek: true,
      focusDimension: state.focusDimension,
    );

    return pulse;
  }
}

final eqPulseProvider =
    StateNotifierProvider<EqPulseNotifier, EqPulseState>((ref) {
  return EqPulseNotifier(ref);
});

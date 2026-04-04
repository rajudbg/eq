import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_assessment/emvo_assessment.dart';

import '../providers/assessment_providers.dart';

/// Resolves when the assessment behind [resultId] was completed (for unlock math).
DateTime planUnlockAnchor(WidgetRef ref, String resultId) {
  final live = ref.watch(assessmentNotifierProvider).result;
  if (live != null && live.id == resultId) {
    return live.completedAt;
  }
  final asyncLatest = ref.watch(latestResultProvider);
  return asyncLatest.maybeWhen(
    data: (AssessmentResult? r) {
      if (r != null && r.id == resultId) {
        return r.completedAt;
      }
      return live?.completedAt ?? DateTime.now();
    },
    orElse: () => live?.completedAt ?? DateTime.now(),
  );
}

/// Progressive unlock: week 1 shows one habit, then +1 each calendar week (max 3).
int actionPlanVisibleHabitCount(DateTime assessmentCompletedAt) {
  final start = DateTime(
    assessmentCompletedAt.year,
    assessmentCompletedAt.month,
    assessmentCompletedAt.day,
  );
  final today = DateTime.now();
  final todayDay = DateTime(today.year, today.month, today.day);
  final days = todayDay.difference(start).inDays;
  final weeksElapsed = days ~/ 7;
  return (1 + weeksElapsed).clamp(1, 3);
}

/// Next habit index still locked (or null if all visible).
int? nextLockedHabitIndex(DateTime assessmentCompletedAt) {
  final n = actionPlanVisibleHabitCount(assessmentCompletedAt);
  if (n >= 3) return null;
  return n;
}

String actionPlanUnlockHint(DateTime assessmentCompletedAt, int habitIndex) {
  if (habitIndex < actionPlanVisibleHabitCount(assessmentCompletedAt)) {
    return '';
  }
  final start = DateTime(
    assessmentCompletedAt.year,
    assessmentCompletedAt.month,
    assessmentCompletedAt.day,
  );
  final targetDay = start.add(Duration(days: habitIndex * 7));
  final month = targetDay.month.toString().padLeft(2, '0');
  final day = targetDay.day.toString().padLeft(2, '0');
  return 'Full detail unlocks ${targetDay.year}-$month-$day (week ${habitIndex + 1})';
}

/// Dimension with lowest score for coach / UI copy.
EQDimension? weakestDimension(AssessmentResult result) {
  if (result.dimensionScores.isEmpty) return null;
  return result.dimensionScores.entries
      .reduce((a, b) => a.value <= b.value ? a : b)
      .key;
}

/// True when a new full assessment retake is due (30-day milestone).
bool isAssessmentRetakeDue(AssessmentResult? latest) {
  if (latest == null) return false;
  final eligible = latest.completedAt.add(const Duration(days: 30));
  return !DateTime.now().isBefore(eligible);
}

DateTime assessmentRetakeEligibleAt(AssessmentResult latest) =>
    latest.completedAt.add(const Duration(days: 30));

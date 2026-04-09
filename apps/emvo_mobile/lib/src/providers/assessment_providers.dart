import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_assessment/emvo_assessment.dart';

import 'user_intent_provider.dart';

/// Latest completed assessment (persisted via [AssessmentRepositoryImpl]).
final latestResultProvider = FutureProvider<AssessmentResult?>((ref) async {
  final repo = ref.watch(assessmentRepositoryProvider);
  final either = await repo.getLatestResult();
  return either.fold((_) => null, (r) => r);
});

/// Chronological EQ history (oldest → newest) for charts and streaks.
final assessmentHistoryProvider =
    FutureProvider<List<AssessmentResult>>((ref) async {
  final repo = ref.watch(assessmentRepositoryProvider);
  final either = await repo.getHistory();
  return either.fold((_) => <AssessmentResult>[], (list) {
    final sorted = List<AssessmentResult>.from(list)
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));
    return sorted;
  });
});

/// Fused deps so [AssessmentScreen] can [ref.listen] once when intent is ready
/// and the notifier is still at [AssessmentStatus.initial] (including retake).
typedef AssessmentKickoffDeps = (AsyncValue<UserIntent?>, AssessmentStatus);

final assessmentKickoffDepsProvider =
    Provider<AssessmentKickoffDeps>((ref) {
  return (
    ref.watch(userIntentProvider),
    ref.watch(assessmentNotifierProvider).status,
  );
});

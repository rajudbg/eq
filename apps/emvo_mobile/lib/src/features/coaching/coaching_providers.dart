import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_core/emvo_core.dart';

final coachingSessionProvider = FutureProvider<CoachingSession>((ref) async {
  final repo = ref.watch(coachingRepositoryProvider);
  final result = await repo.getActiveSession();
  return result.getOrElse((f) => throw Exception(f.message));
});

final sendMessageProvider = Provider<Future<void> Function(String)>((ref) {
  return (String content) async {
    final repo = ref.read(coachingRepositoryProvider);
    final result = await repo.sendMessage(content);
    result.fold(
      (f) => throw Exception(f.message),
      (_) {},
    );
    ref.invalidate(coachingSessionProvider);
  };
});

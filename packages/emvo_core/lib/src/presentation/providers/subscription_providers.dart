import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/subscription/entities/subscription_plan.dart';
import '../../domain/subscription/entities/subscription_status.dart';
import '../../domain/subscription/repositories/subscription_repository.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  throw UnimplementedError('Override in main');
});

final subscriptionPlansProvider =
    FutureProvider<List<SubscriptionPlan>>((ref) async {
  final repo = ref.watch(subscriptionRepositoryProvider);
  final result = await repo.getAvailablePlans();
  return result.getOrElse((_) => []);
});

/// Initial snapshot from [SubscriptionRepository.getCurrentSubscription], then
/// live updates from [SubscriptionRepository.subscriptionStatusStream].
final currentSubscriptionProvider =
    StreamProvider<UserSubscription>((ref) async* {
  final repo = ref.watch(subscriptionRepositoryProvider);
  final initial = await repo.getCurrentSubscription();
  yield initial.getOrElse((_) => UserSubscription.free());
  yield* repo.subscriptionStatusStream();
});

final isPremiumProvider = Provider<bool>((ref) {
  final subscriptionAsync = ref.watch(currentSubscriptionProvider);
  return subscriptionAsync.when(
    data: (sub) => sub.currentTier != SubscriptionTier.free,
    loading: () => false,
    error: (_, __) => false,
  );
});

final canAccessPremiumFeature =
    Provider.family<bool, SubscriptionFeature>((ref, feature) {
  final subscriptionAsync = ref.watch(currentSubscriptionProvider);
  return subscriptionAsync.when(
    data: (sub) => feature.isAvailableFor(sub.currentTier),
    loading: () => false,
    error: (_, __) => false,
  );
});

enum SubscriptionFeature {
  advancedCoaching,
  detailedAnalytics,
  unlimitedAssessments,
  exportData,
  prioritySupport;

  bool isAvailableFor(SubscriptionTier tier) {
    switch (this) {
      case SubscriptionFeature.advancedCoaching:
        return tier.hasAdvancedCoaching;
      case SubscriptionFeature.detailedAnalytics:
        return tier.hasDetailedAnalytics;
      case SubscriptionFeature.unlimitedAssessments:
        return tier.hasUnlimitedAssessments;
      case SubscriptionFeature.exportData:
        return tier.hasExportData;
      case SubscriptionFeature.prioritySupport:
        return tier.hasPrioritySupport;
    }
  }
}

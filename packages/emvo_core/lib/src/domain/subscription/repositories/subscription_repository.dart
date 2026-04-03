import 'package:fpdart/fpdart.dart';

import '../../failures/failure.dart';
import '../entities/subscription_plan.dart';
import '../entities/subscription_status.dart';

abstract class SubscriptionRepository {
  /// Get available plans for purchase
  Future<Either<Failure, List<SubscriptionPlan>>> getAvailablePlans();

  /// Get current user subscription status
  Future<Either<Failure, UserSubscription>> getCurrentSubscription();

  /// Purchase a plan
  Future<Either<Failure, UserSubscription>> purchasePlan(
    SubscriptionPlan plan,
  );

  /// Restore previous purchases
  Future<Either<Failure, UserSubscription>> restorePurchases();

  /// Cancel subscription (if applicable)
  Future<Either<Failure, Unit>> cancelSubscription();

  /// Stream of subscription status changes
  Stream<UserSubscription> subscriptionStatusStream();
}

// Feature flags based on subscription
extension SubscriptionFeatures on SubscriptionTier {
  bool get hasAdvancedCoaching =>
      this == SubscriptionTier.premium || this == SubscriptionTier.pro;
  bool get hasDetailedAnalytics =>
      this == SubscriptionTier.premium || this == SubscriptionTier.pro;
  bool get hasUnlimitedAssessments =>
      this == SubscriptionTier.premium || this == SubscriptionTier.pro;
  bool get hasExportData => this == SubscriptionTier.pro;
  bool get hasPrioritySupport => this == SubscriptionTier.pro;

  int get maxCoachingMessagesPerDay {
    switch (this) {
      case SubscriptionTier.free:
        return 5;
      case SubscriptionTier.premium:
        return 50;
      case SubscriptionTier.pro:
        return -1; // Unlimited
    }
  }
}

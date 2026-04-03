import 'package:freezed_annotation/freezed_annotation.dart';

import 'subscription_plan.dart';

part 'subscription_status.freezed.dart';

enum SubscriptionStatus {
  none, // Never subscribed
  active, // Currently active
  expired, // Was active, now expired
  cancelled, // Cancelled but still active until period end
  gracePeriod, // Payment issue but still active
}

@freezed
class UserSubscription with _$UserSubscription {
  const factory UserSubscription({
    required SubscriptionStatus status,
    required SubscriptionTier currentTier,
    DateTime? expiryDate,
    DateTime? purchaseDate,
    String? receiptId,
    bool? willRenew,
  }) = _UserSubscription;

  factory UserSubscription.free() => const UserSubscription(
        status: SubscriptionStatus.none,
        currentTier: SubscriptionTier.free,
      );
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_plan.freezed.dart';

enum SubscriptionTier {
  free,
  premium,
  pro,
}

enum BillingPeriod {
  monthly,
  yearly,
  lifetime,
}

@freezed
class SubscriptionPlan with _$SubscriptionPlan {
  const factory SubscriptionPlan({
    required String id,
    required String name,
    required SubscriptionTier tier,
    required BillingPeriod period,
    required double price,
    required String currency,
    required List<String> features,
    String? description,
    double? introductoryPrice,
    BillingPeriod? introductoryPeriod,
  }) = _SubscriptionPlan;
}

extension SubscriptionPlanExtension on SubscriptionPlan {
  String get formattedPrice => '\$$price/${period.name}';

  String get displayPeriod {
    switch (period) {
      case BillingPeriod.monthly:
        return 'month';
      case BillingPeriod.yearly:
        return 'year';
      case BillingPeriod.lifetime:
        return 'one-time';
    }
  }
}

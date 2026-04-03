import 'dart:async';

import 'package:fpdart/fpdart.dart';

import '../../domain/failures/failure.dart';
import '../../domain/subscription/entities/subscription_plan.dart';
import '../../domain/subscription/entities/subscription_status.dart';
import '../../domain/subscription/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  UserSubscription _currentSubscription = UserSubscription.free();
  final _statusController = StreamController<UserSubscription>.broadcast();

  @override
  Future<Either<Failure, List<SubscriptionPlan>>> getAvailablePlans() async {
    try {
      // Mock plans - in production, fetch from RevenueCat or backend
      return Right([
        const SubscriptionPlan(
          id: 'premium_monthly',
          name: 'Premium',
          tier: SubscriptionTier.premium,
          period: BillingPeriod.monthly,
          price: 9.99,
          currency: 'USD',
          features: [
            'Unlimited AI coaching',
            'Detailed EQ analytics',
            'Advanced exercises',
            'Progress tracking',
            'No ads',
          ],
          description: 'Full access to AI coaching and insights',
        ),
        const SubscriptionPlan(
          id: 'premium_yearly',
          name: 'Premium Annual',
          tier: SubscriptionTier.premium,
          period: BillingPeriod.yearly,
          price: 59.99,
          currency: 'USD',
          features: [
            'Everything in Monthly',
            '2 months free',
            'Export data (PDF)',
            'Priority support',
          ],
          description: 'Best value for serious growth',
          introductoryPrice: 4.99,
          introductoryPeriod: BillingPeriod.monthly,
        ),
        const SubscriptionPlan(
          id: 'pro_lifetime',
          name: 'Pro Lifetime',
          tier: SubscriptionTier.pro,
          period: BillingPeriod.lifetime,
          price: 199.99,
          currency: 'USD',
          features: [
            'Everything forever',
            'All future features',
            '1-on-1 coaching sessions',
            'Custom EQ development plan',
          ],
          description: 'One-time purchase, lifetime access',
        ),
      ]);
    } catch (e) {
      return Left(CacheFailure('Failed to load plans'));
    }
  }

  @override
  Future<Either<Failure, UserSubscription>> getCurrentSubscription() async {
    try {
      return Right(_currentSubscription);
    } catch (e) {
      return Left(CacheFailure('Failed to get subscription'));
    }
  }

  @override
  Future<Either<Failure, UserSubscription>> purchasePlan(
    SubscriptionPlan plan,
  ) async {
    try {
      // Mock purchase - simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      final newSubscription = UserSubscription(
        status: SubscriptionStatus.active,
        currentTier: plan.tier,
        purchaseDate: DateTime.now(),
        expiryDate: plan.period == BillingPeriod.lifetime
            ? null
            : DateTime.now().add(_getDuration(plan.period)),
        willRenew: plan.period != BillingPeriod.lifetime,
      );

      _currentSubscription = newSubscription;
      _statusController.add(newSubscription);

      return Right(newSubscription);
    } catch (e) {
      return Left(ServerFailure('Purchase failed'));
    }
  }

  @override
  Future<Either<Failure, UserSubscription>> restorePurchases() async {
    try {
      // Mock restore
      await Future.delayed(const Duration(seconds: 1));

      // In production, check with App Store/Play Store
      if (_currentSubscription.status == SubscriptionStatus.none) {
        return Right(UserSubscription.free());
      }

      return Right(_currentSubscription);
    } catch (e) {
      return Left(ServerFailure('Restore failed'));
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelSubscription() async {
    try {
      if (_currentSubscription.status == SubscriptionStatus.active) {
        _currentSubscription = _currentSubscription.copyWith(
          status: SubscriptionStatus.cancelled,
          willRenew: false,
        );
        _statusController.add(_currentSubscription);
      }
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Cancel failed'));
    }
  }

  @override
  Stream<UserSubscription> subscriptionStatusStream() =>
      _statusController.stream;

  Duration _getDuration(BillingPeriod period) {
    switch (period) {
      case BillingPeriod.monthly:
        return const Duration(days: 30);
      case BillingPeriod.yearly:
        return const Duration(days: 365);
      case BillingPeriod.lifetime:
        return Duration.zero;
    }
  }

  void dispose() {
    _statusController.close();
  }
}

// TODO: RevenueCat implementation for production
// class RevenueCatSubscriptionRepository implements SubscriptionRepository {
//   // Initialize with RevenueCat SDK
//   // Configure with API keys
//   // Handle purchases, restores, status
// }

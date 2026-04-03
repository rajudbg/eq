import 'package:injectable/injectable.dart';

import '../data/coaching/coaching_ai_factories.dart';
import '../data/coaching/coaching_repository_impl.dart';
import '../data/subscription/subscription_repository_impl.dart';
import '../domain/coaching/repositories/coaching_ai_gateway.dart';
import '../domain/coaching/repositories/coaching_repository.dart';
import '../domain/subscription/repositories/subscription_repository.dart';
import 'injection.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  CoachingAiGateway get coachingAiGateway => createCoachingAiGateway();

  @lazySingleton
  CoachingRepository get coachingRepository =>
      CoachingRepositoryImpl(getIt<CoachingAiGateway>());

  @lazySingleton
  SubscriptionRepository get subscriptionRepository =>
      SubscriptionRepositoryImpl(); // Switch to RevenueCat impl later
}

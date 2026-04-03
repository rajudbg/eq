// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../data/coaching/ai_service.dart' as _i710;
import '../domain/coaching/repositories/coaching_repository.dart' as _i1041;
import '../domain/subscription/repositories/subscription_repository.dart'
    as _i442;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i710.AIService>(() => registerModule.aiService);
    gh.lazySingleton<_i1041.CoachingRepository>(
        () => registerModule.coachingRepository);
    gh.lazySingleton<_i442.SubscriptionRepository>(
        () => registerModule.subscriptionRepository);
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_assessment/emvo_assessment.dart';
import 'package:emvo_core/emvo_core.dart';
import 'package:emvo_ui/emvo_ui.dart';

import 'flavors.dart';
import 'src/app.dart';
import 'src/bootstrap/emvo_bootstrap.dart';
import 'src/services/emvo_notification_service.dart';
import 'src/services/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  F.initFromDartDefine(); // Matches `--dart-define=FLAVOR=...` / CI

  runApp(
    EmvoAppBootstrap(
      onBootstrapComplete: _bootstrapBeforeFirstFrame,
      app: ProviderScope(
        overrides: [
          questionRepositoryProvider.overrideWithValue(
            QuestionRepositoryImpl(LocalQuestionDataSource()),
          ),
          assessmentRepositoryProvider.overrideWithValue(
            AssessmentRepositoryImpl(),
          ),
          // OpenRouter when OPENROUTER_API_KEY is set; else LocalContextCoachingAiGateway.
          coachingRepositoryProvider.overrideWithValue(
            CoachingRepositoryImpl(createCoachingAiGateway()),
          ),
          subscriptionRepositoryProvider.overrideWithValue(
            SubscriptionRepositoryImpl(),
          ),
        ],
        child: const EmvoApp(),
      ),
    ),
  );
}

Future<void> _bootstrapBeforeFirstFrame() async {
  await ensureFirebaseAppAndAnonymousUser();

  EmvoImageCache.configure();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  configureDependencies();

  if (!kIsWeb) {
    await EmvoNotificationService.instance.initialize();
  }
}

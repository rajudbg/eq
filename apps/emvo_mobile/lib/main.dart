import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_assessment/emvo_assessment.dart';
import 'package:emvo_core/emvo_core.dart';
import 'package:emvo_ui/emvo_ui.dart';

import 'flavors.dart';
import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  F.initFromDartDefine(); // Matches `--dart-define=FLAVOR=...` / CI

  // Performance configurations
  EmvoImageCache.configure();

  // Lock orientation to portrait for consistent experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure system UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  configureDependencies();

  runApp(
    ProviderScope(
      overrides: [
        questionRepositoryProvider.overrideWithValue(
          QuestionRepositoryImpl(LocalQuestionDataSource()),
        ),
        assessmentRepositoryProvider.overrideWithValue(
          AssessmentRepositoryImpl(),
        ),
        coachingRepositoryProvider.overrideWithValue(
          CoachingRepositoryImpl(MockAIService()),
        ),
        subscriptionRepositoryProvider.overrideWithValue(
          SubscriptionRepositoryImpl(),
        ),
      ],
      child: const EmvoApp(),
    ),
  );
}

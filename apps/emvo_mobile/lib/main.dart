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

  // Nav/status bar colors follow theme via [SystemUiThemeSync] in [EmvoApp].
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
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
  );
}

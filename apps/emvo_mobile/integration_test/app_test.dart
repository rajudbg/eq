import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:emvo_mobile/src/features/welcome/welcome_screen.dart';

/// Headless integration smoke test (runs on `flutter-tester` / CI).
///
/// Full `main()` is not used here: `EmvoTheme` + `google_fonts` trigger
/// `path_provider`, which is not available on the `flutter-tester` device.
/// For full end-to-end runs on a real device or emulator, use:
/// `flutter drive --target=integration_test/...` or run on `-d android`/`-d ios`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Integration smoke', () {
    testWidgets('Welcome screen shows primary content',
        (WidgetTester tester) async {
      final previousDilation = timeDilation;
      try {
        timeDilation = 50;
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: WelcomeScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Get Started'), findsOneWidget);

        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        expect(find.text('Welcome to Emvo!'), findsOneWidget);
      } finally {
        timeDilation = previousDilation;
      }
    });
  });
}

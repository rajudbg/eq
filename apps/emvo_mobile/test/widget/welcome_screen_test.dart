import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:emvo_mobile/src/features/welcome/welcome_screen.dart';

void main() {
  testWidgets('Welcome screen shows logo and buttons', (WidgetTester tester) async {
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
      // Speeds up flutter_animate + WelcomeScreen's delayed mascot callback.
      await tester.pumpAndSettle();

      expect(find.text('Emvo'), findsOneWidget);
      expect(find.text('Emotional Intelligence,\nIn Motion'), findsOneWidget);

      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('I Already Have an Account'), findsOneWidget);
    } finally {
      timeDilation = previousDilation;
    }
  });
}

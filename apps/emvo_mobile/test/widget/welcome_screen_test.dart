import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:emvo_mobile/src/features/welcome/welcome_screen.dart';

void main() {
  testWidgets('Welcome screen shows story and CTAs',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: WelcomeScreen(),
        ),
      ),
    );
    // Entry animations — avoid pumpAndSettle.
    await tester.pump(const Duration(milliseconds: 800));

    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.text("You're capable. People respect you."),
      findsOneWidget,
    );
    expect(find.text('Take the EQ Assessment'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
  });
}

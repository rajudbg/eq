import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class EmvoAnimations {
  // Durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  // Curves
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve accelerate = Curves.easeInCubic;
  static const Curve decelerate = Curves.easeOutCubic;
  static const Curve spring = Curves.elasticOut;
  static const Curve bounce = Curves.bounceOut;

  // Page transitions
  static const PageTransitionsTheme transitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: SharedAxisPageTransitionsBuilder(
        transitionType: SharedAxisTransitionType.horizontal,
      ),
    },
  );
}

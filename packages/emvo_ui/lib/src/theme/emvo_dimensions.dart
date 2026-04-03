import 'package:flutter/material.dart';

import 'emvo_colors.dart';

class EmvoDimensions {
  // Spacing
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Border Radius
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 999;

  // Shadows
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: EmvoColors.primary.withOpacity(0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: EmvoColors.primary.withOpacity(0.15),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: EmvoColors.primary.withOpacity(0.2),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  // Padding presets
  static const EdgeInsets paddingScreen = EdgeInsets.all(md);
  static const EdgeInsets paddingCard = EdgeInsets.all(lg);
  static const EdgeInsets paddingButton = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 16,
  );
}

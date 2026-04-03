import 'package:flutter/material.dart';

class EmvoColors {
  // Primary - Deep Teal (Calm, Growth)
  static const Color primary = Color(0xFF0A6B6B);
  static const Color primaryLight = Color(0xFF4A9B9B);
  static const Color primaryDark = Color(0xFF004040);

  // Secondary - Warm Amber (Energy, Optimism)
  static const Color secondary = Color(0xFFFFB347);
  static const Color secondaryLight = Color(0xFFFFD699);
  static const Color secondaryDark = Color(0xFFCC7A00);

  // Tertiary - Soft Lavender (Introspection, Wisdom)
  static const Color tertiary = Color(0xFF9B7EDE);
  static const Color tertiaryLight = Color(0xFFC5B3F0);
  static const Color tertiaryDark = Color(0xFF6B4FB5);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE57373);
  static const Color info = Color(0xFF2196F3);

  // Surface Colors
  static const Color surface = Color(0xFFFAF9F6);
  static const Color surfaceVariant = Color(0xFFF0EFEA);
  static const Color background = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF1C1B1F);
  static const Color onSurface = Color(0xFF1C1B1F);

  // Glassmorphism
  static const Color glassWhite = Color(0x40FFFFFF);
  static const Color glassBlack = Color(0x40000000);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

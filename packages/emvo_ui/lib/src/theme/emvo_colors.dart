import 'package:flutter/material.dart';

/// Brand palette aligned with the Emvo heart logo (magenta → purple → orange, cyan accent).
class EmvoColors {
  EmvoColors._();

  // —— Core brand (logo gradient family) ——
  static const Color brandPurple = Color(0xFF6A0DAD);
  static const Color brandMagenta = Color(0xFFD81B60);
  static const Color brandPink = Color(0xFFE639AF);
  static const Color brandOrange = Color(0xFFFF8C00);
  static const Color brandGold = Color(0xFFFFD54F);
  static const Color accentCyan = Color(0xFF00E5FF);

  // Primary = main interactive (magenta-pink)
  static const Color primary = Color(0xFFE91E8C);
  static const Color primaryLight = Color(0xFFFF6BB3);
  static const Color primaryDark = Color(0xFFAD1457);

  static const Color secondary = Color(0xFFFF9800);
  static const Color secondaryLight = Color(0xFFFFCC80);
  static const Color secondaryDark = Color(0xFFE65100);

  static const Color tertiary = Color(0xFF7C4DFF);
  static const Color tertiaryLight = Color(0xFFB47CFF);
  static const Color tertiaryDark = Color(0xFF4527A0);

  static const Color success = Color(0xFF69F0AE);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFFF8A80);
  static const Color info = accentCyan;

  // —— Light glass shell ——
  static const Color backgroundLight = Color(0xFFF5F2FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFEDE8F5);
  static const Color onBackgroundLight = Color(0xFF1A1530);

  // —— Dark glass shell (logo navy) ——
  static const Color backgroundDark = Color(0xFF0B0B1E);
  static const Color backgroundDarkElevated = Color(0xFF12122A);
  static const Color surfaceDark = Color(0xFF18182E);
  static const Color surfaceVariantDark = Color(0xFF222240);
  static const Color onBackgroundDark = Color(0xFFF0F0FA);

  // Legacy aliases (prefer theme ColorScheme in new code)
  static const Color surface = surfaceLight;
  static const Color surfaceVariant = surfaceVariantLight;
  static const Color background = backgroundLight;
  static const Color onBackground = onBackgroundLight;
  static const Color onSurface = onBackgroundLight;

  /// Glass fill (light mode)
  static const Color glassLight = Color(0xB3FFFFFF);

  /// Alias for light glass fill (legacy call sites).
  static const Color glassWhite = glassLight;

  /// Glass fill (dark mode)
  static const Color glassDark = Color(0x26FFFFFF);

  static const Color glassStrokeLight = Color(0x4DFFFFFF);
  static const Color glassStrokeDark = Color(0x33FFFFFF);

  /// Hero gradient (buttons, chips, highlights)
  static const LinearGradient brandGradient = LinearGradient(
    colors: [brandPurple, brandMagenta, brandOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandGradientSoft = LinearGradient(
    colors: [
      Color(0x6685007D),
      Color(0x66D81B60),
      Color(0x66FF9800),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = brandGradient;
}

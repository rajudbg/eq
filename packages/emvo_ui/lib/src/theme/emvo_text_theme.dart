import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'emvo_colors.dart';

class EmvoTextTheme {
  static TextTheme textThemeFor(ColorScheme scheme) {
    final base = GoogleFonts.plusJakartaSansTextTheme();
    final onSurface = scheme.onSurface;

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        color: onSurface,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        color: onSurface,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.35,
        height: 1.2,
        color: onSurface,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.5,
        color: onSurface,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.45,
        color: onSurface.withValues(alpha: 0.92),
      ),
      bodySmall: base.bodySmall?.copyWith(
        color: onSurface.withValues(alpha: 0.72),
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: onSurface,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: onSurface.withValues(alpha: 0.92),
      ),
      labelSmall: base.labelSmall?.copyWith(
        color: onSurface.withValues(alpha: 0.65),
      ),
    );
  }

  /// @deprecated Use [textThemeFor] with a [ColorScheme].
  static TextTheme get textTheme => textThemeFor(
        const ColorScheme.light(onSurface: EmvoColors.onBackgroundLight),
      );
}

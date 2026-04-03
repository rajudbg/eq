import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'emvo_colors.dart';

class EmvoTextTheme {
  static TextTheme get textTheme {
    final base = GoogleFonts.plusJakartaSansTextTheme();

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        color: EmvoColors.onBackground,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: EmvoColors.onBackground,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.5,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.4,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

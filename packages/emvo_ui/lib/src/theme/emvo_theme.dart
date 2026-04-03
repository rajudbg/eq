import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'emvo_colors.dart';
import 'emvo_text_theme.dart';

class EmvoTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: EmvoColors.primary,
        onPrimary: Colors.white,
        primaryContainer: EmvoColors.primaryLight,
        onPrimaryContainer: EmvoColors.primaryDark,
        secondary: EmvoColors.secondary,
        onSecondary: Colors.black,
        secondaryContainer: EmvoColors.secondaryLight,
        onSecondaryContainer: EmvoColors.secondaryDark,
        tertiary: EmvoColors.tertiary,
        onTertiary: Colors.white,
        tertiaryContainer: EmvoColors.tertiaryLight,
        onTertiaryContainer: EmvoColors.tertiaryDark,
        error: EmvoColors.error,
        onError: Colors.white,
        surface: EmvoColors.surface,
        onSurface: EmvoColors.onBackground,
        surfaceContainerHighest: EmvoColors.surfaceVariant,
        onSurfaceVariant: EmvoColors.onBackground,
        outline: EmvoColors.primaryLight,
      ),
      textTheme: EmvoTextTheme.textTheme,
      scaffoldBackgroundColor: EmvoColors.background,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: EmvoColors.surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: EmvoColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: EmvoColors.primary, width: 2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: EmvoColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: SharedAxisPageTransitionsBuilder(
            fillColor: EmvoColors.background,
            transitionType: SharedAxisTransitionType.horizontal,
          ),
        },
      ),
    );
  }
}

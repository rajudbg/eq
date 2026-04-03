import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'emvo_colors.dart';
import 'emvo_text_theme.dart';

class EmvoTheme {
  static ThemeData get lightTheme {
    final scheme = ColorScheme(
      brightness: Brightness.light,
      primary: EmvoColors.primary,
      onPrimary: Colors.white,
      primaryContainer: EmvoColors.primaryLight,
      onPrimaryContainer: EmvoColors.primaryDark,
      secondary: EmvoColors.secondary,
      onSecondary: Color(0xFF1A1530),
      secondaryContainer: EmvoColors.secondaryLight,
      onSecondaryContainer: EmvoColors.secondaryDark,
      tertiary: EmvoColors.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: EmvoColors.tertiaryLight,
      onTertiaryContainer: EmvoColors.tertiaryDark,
      error: EmvoColors.error,
      onError: Color(0xFF1A1530),
      surface: EmvoColors.surfaceLight,
      onSurface: EmvoColors.onBackgroundLight,
      surfaceContainerHighest: EmvoColors.surfaceVariantLight,
      onSurfaceVariant: EmvoColors.onBackgroundLight,
      outline: EmvoColors.brandMagenta.withValues(alpha: 0.35),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      textTheme: EmvoTextTheme.textThemeFor(scheme),
      scaffoldBackgroundColor: EmvoColors.backgroundLight,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: Colors.white.withValues(alpha: 0.72),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(
            color: EmvoColors.primary.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.85),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: EmvoColors.onBackgroundLight.withValues(alpha: 0.12),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: EmvoColors.onBackgroundLight.withValues(alpha: 0.1),
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: EmvoColors.onBackgroundLight,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.75),
        indicatorColor: EmvoColors.primary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontSize: 12,
            fontWeight: s.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: EmvoColors.onBackgroundLight,
          ),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: SharedAxisPageTransitionsBuilder(
            fillColor: EmvoColors.backgroundLight,
            transitionType: SharedAxisTransitionType.horizontal,
          ),
        },
      ),
    );
  }

  static ThemeData get darkTheme {
    final scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: EmvoColors.primaryLight,
      onPrimary: Color(0xFF1A0512),
      primaryContainer: EmvoColors.primaryDark,
      onPrimaryContainer: EmvoColors.primaryLight,
      secondary: EmvoColors.secondary,
      onSecondary: Color(0xFF1A1530),
      secondaryContainer: EmvoColors.secondaryDark,
      onSecondaryContainer: EmvoColors.secondaryLight,
      tertiary: EmvoColors.tertiaryLight,
      onTertiary: Color(0xFF1A1530),
      tertiaryContainer: EmvoColors.tertiaryDark,
      onTertiaryContainer: EmvoColors.tertiaryLight,
      error: EmvoColors.error,
      onError: Color(0xFF1A1530),
      surface: EmvoColors.surfaceDark,
      onSurface: EmvoColors.onBackgroundDark,
      surfaceContainerHighest: EmvoColors.surfaceVariantDark,
      onSurfaceVariant: EmvoColors.onBackgroundDark,
      outline: Colors.white.withValues(alpha: 0.14),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      textTheme: EmvoTextTheme.textThemeFor(scheme),
      scaffoldBackgroundColor: EmvoColors.backgroundDark,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: Colors.white.withValues(alpha: 0.06),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.22),
            width: 1.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: EmvoColors.onBackgroundDark,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.06),
        indicatorColor: EmvoColors.accentCyan.withValues(alpha: 0.22),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontSize: 12,
            fontWeight: s.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: EmvoColors.onBackgroundDark,
          ),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: SharedAxisPageTransitionsBuilder(
            fillColor: EmvoColors.backgroundDark,
            transitionType: SharedAxisTransitionType.horizontal,
          ),
        },
      ),
    );
  }
}

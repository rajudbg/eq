import 'package:flutter/material.dart';

/// Use with the app [ThemeData] (light/dark) instead of static [EmvoColors]
/// aliases like [EmvoColors.onBackground] or [EmvoColors.surfaceVariant],
/// which are fixed to the light palette and break dark-mode legibility.
extension EmvoThemeContext on BuildContext {
  ColorScheme get emvoScheme => Theme.of(this).colorScheme;

  Color emvoOnSurface([double alpha = 1]) =>
      emvoScheme.onSurface.withValues(alpha: alpha);

  Color emvoOnSurfaceVariant([double alpha = 1]) =>
      emvoScheme.onSurfaceVariant.withValues(alpha: alpha);

  Color get emvoSurfaceContainer => emvoScheme.surfaceContainerHighest;

  Color emvoOutline([double alpha = 1]) =>
      emvoScheme.outline.withValues(alpha: alpha);
}

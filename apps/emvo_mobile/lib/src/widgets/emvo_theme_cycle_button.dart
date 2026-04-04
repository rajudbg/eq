import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../providers/theme_settings_provider.dart';

/// Cycles system → light → dark. Matches app-wide theme (Settings).
class EmvoThemeCycleButton extends ConsumerWidget {
  const EmvoThemeCycleButton({super.key, this.iconSize = 22});

  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final icon = switch (mode) {
      ThemeMode.dark => Icons.dark_mode_outlined,
      ThemeMode.light => Icons.light_mode_outlined,
      ThemeMode.system => Icons.brightness_auto_outlined,
    };
    return IconButton(
      tooltip: 'Theme: ${mode.name}',
      icon: Icon(icon, size: iconSize),
      color: context.emvoOnSurface(0.72),
      onPressed: () {
        final next = switch (mode) {
          ThemeMode.system => ThemeMode.light,
          ThemeMode.light => ThemeMode.dark,
          ThemeMode.dark => ThemeMode.system,
        };
        ref.read(themeModeProvider.notifier).setThemeMode(next);
      },
    );
  }
}

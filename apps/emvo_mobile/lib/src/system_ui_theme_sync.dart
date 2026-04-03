import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Applies [SystemChrome] from the resolved [Theme] without wrapping the
/// navigator in [AnnotatedRegion], which has been linked to
/// `view.dart` render-tree assertions on Flutter web when the theme changes.
class SystemUiThemeSync extends StatefulWidget {
  const SystemUiThemeSync({super.key, required this.child});

  final Widget child;

  @override
  State<SystemUiThemeSync> createState() => _SystemUiThemeSyncState();
}

class _SystemUiThemeSyncState extends State<SystemUiThemeSync> {
  Brightness? _lastApplied;

  void _applyForBrightness(Brightness brightness) {
    final theme = Theme.of(context);
    final style = brightness == Brightness.dark
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: theme.colorScheme.surface,
            systemNavigationBarIconBrightness: Brightness.light,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: theme.colorScheme.surface,
            systemNavigationBarIconBrightness: Brightness.dark,
          );
    SystemChrome.setSystemUIOverlayStyle(style);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final b = Theme.of(context).brightness;
    if (_lastApplied == b) return;
    _lastApplied = b;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (Theme.of(context).brightness != b) return;
      _applyForBrightness(b);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

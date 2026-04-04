import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_core/emvo_core.dart';
import 'package:emvo_ui/emvo_ui.dart';

import 'providers/theme_settings_provider.dart';
import 'routing/app_router.dart';
import 'system/notification_schedule_sync.dart';
import 'system_ui_theme_sync.dart';

class EmvoApp extends ConsumerWidget {
  const EmvoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return ErrorBoundary(
      child: MaterialApp.router(
        title: 'Emvo',
        debugShowCheckedModeBanner: false,
        theme: EmvoTheme.lightTheme,
        darkTheme: EmvoTheme.darkTheme,
        themeMode: themeMode,
        routerConfig: AppRouter.router,
        builder: (context, child) {
          return SystemUiThemeSync(
            child: NotificationScheduleSync(
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}

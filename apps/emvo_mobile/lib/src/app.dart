import 'package:flutter/material.dart';
import 'package:emvo_core/emvo_core.dart';
import 'package:emvo_ui/emvo_ui.dart';

import 'routing/app_router.dart';

class EmvoApp extends StatelessWidget {
  const EmvoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      child: MaterialApp.router(
        title: 'Emvo',
        debugShowCheckedModeBanner: false,
        theme: EmvoTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}

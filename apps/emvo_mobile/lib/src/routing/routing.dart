// Single import for GoRouter + NavigationExtensions without clashing with
// go_router's GoRouterHelper extension.
export 'package:go_router/go_router.dart' hide GoRouterHelper;

export 'app_router.dart';
export 'navigation_extensions.dart';

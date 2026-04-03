import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart' hide GoRouterHelper;

/// Type-safe navigation helpers. Import this library instead of raw
/// `go_router` when you need these names; otherwise [GoRouterHelper] from
/// `go_router` also adds [BuildContext] navigation methods.
extension NavigationExtensions on BuildContext {
  /// Push with result.
  Future<T?> push<T extends Object?>(String location, {Object? extra}) {
    return GoRouter.of(this).push<T>(location, extra: extra);
  }

  /// Go (replace stack / declarative navigation).
  void go(String location, {Object? extra}) {
    GoRouter.of(this).go(location, extra: extra);
  }

  /// Replace top route (preserves page key when possible).
  void replace(String location, {Object? extra}) {
    GoRouter.of(this).replace(location, extra: extra);
  }

  /// Pop with optional result.
  void pop<T extends Object?>([T? result]) {
    GoRouter.of(this).pop<T>(result);
  }

  /// Current path segment (no query).
  String get currentLocation => GoRouterState.of(this).uri.path;

  /// Whether [route] matches the start of the current path.
  bool isRouteActive(String route) => currentLocation.startsWith(route);
}

/// Type-safe route arguments for assessment.
class AssessmentArguments {
  const AssessmentArguments({this.isRetake = false});

  final bool isRetake;
}

/// Type-safe route arguments for results.
class ResultsArguments {
  const ResultsArguments({
    required this.scores,
    required this.insights,
  });

  final Map<String, double> scores;
  final String insights;
}

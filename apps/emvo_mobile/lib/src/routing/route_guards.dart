import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_state_providers.dart';
import 'app_router.dart';

/// Route guards that use Riverpod providers for state checks.
///
/// Usage in GoRouter redirect:
/// ```dart
/// redirect: (context, state) => RouteGuards.checkAll(context, state),
/// ```
class RouteGuards {
  static String? checkAll(BuildContext context, GoRouterState state) {
    // Skip guards for auth-related routes to prevent redirect loops
    final location = state.uri.path;
    final isAuthRoute = location == Routes.welcome ||
        location == Routes.onboarding ||
        location.startsWith('/login');

    if (isAuthRoute) return null;

    // EQ assessment + results are entry paths for new and returning users; they must
    // not require sign-in or onboarding first (otherwise "I already have an account"
    // navigates here and is immediately redirected back to /welcome).
    if (location == Routes.assessment || location == Routes.results) {
      return null;
    }

    // Check auth
    final authRedirect = _checkAuth(context, state);
    if (authRedirect != null) return authRedirect;

    // Check onboarding
    final onboardingRedirect = _checkOnboarding(context, state);
    if (onboardingRedirect != null) return onboardingRedirect;

    // Check assessment
    final assessmentRedirect = _checkAssessment(context, state);
    if (assessmentRedirect != null) return assessmentRedirect;

    return null;
  }

  static String? _checkAuth(BuildContext context, GoRouterState state) {
    final container = ProviderScope.containerOf(context);
    final isAuthenticated = container.read(authProvider);
    final location = state.uri.path;
    final hasCompletedAssessment =
        container.read(assessmentCompletionProvider);

    // Guest mode: main tabs + settings/paywall after EQ assessment without sign-in.
    if (_isAllowedAfterAssessment(location) && hasCompletedAssessment) {
      return null;
    }

    if (!isAuthenticated) return Routes.welcome;
    return null;
  }

  static String? _checkOnboarding(BuildContext context, GoRouterState state) {
    final container = ProviderScope.containerOf(context);
    final hasCompletedOnboarding = container.read(onboardingProvider);
    final location = state.uri.path;
    final hasCompletedAssessment =
        container.read(assessmentCompletionProvider);

    if (_isAllowedAfterAssessment(location) && hasCompletedAssessment) {
      return null;
    }

    if (!hasCompletedOnboarding) return Routes.onboarding;
    return null;
  }

  static bool _isDashboardShellPath(String location) {
    return location == Routes.home ||
        location == Routes.coach ||
        location == Routes.progress ||
        location == Routes.profile;
  }

  /// Routes guests may open after completing the assessment (no sign-in / onboarding).
  static bool _isAllowedAfterAssessment(String location) {
    return _isDashboardShellPath(location) ||
        location == Routes.settings ||
        location == Routes.paywall;
  }

  static String? _checkAssessment(BuildContext context, GoRouterState state) {
    final container = ProviderScope.containerOf(context);
    final hasCompletedAssessment = container.read(assessmentCompletionProvider);

    // Don't redirect if already going to assessment or results
    final location = state.uri.path;
    if (location == Routes.assessment || location == Routes.results) {
      return null;
    }

    if (!hasCompletedAssessment) return Routes.assessment;
    return null;
  }
}

/// Legacy individual guards (kept for backward compatibility)
@Deprecated('Use RouteGuards.checkAll instead')
class AuthGuard {
  static String? redirect(BuildContext context, GoRouterState state) {
    final container = ProviderScope.containerOf(context);
    final isAuthenticated = container.read(authProvider);
    if (!isAuthenticated) return Routes.welcome;
    return null;
  }
}

@Deprecated('Use RouteGuards.checkAll instead')
class OnboardingGuard {
  static String? redirect(BuildContext context, GoRouterState state) {
    final container = ProviderScope.containerOf(context);
    final hasCompleted = container.read(onboardingProvider);
    if (!hasCompleted) return Routes.onboarding;
    return null;
  }
}

@Deprecated('Use RouteGuards.checkAll instead')
class AssessmentGuard {
  static String? redirect(BuildContext context, GoRouterState state) {
    final container = ProviderScope.containerOf(context);
    final hasCompleted = container.read(assessmentCompletionProvider);
    if (!hasCompleted) return Routes.assessment;
    return null;
  }
}

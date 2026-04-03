import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// TODO: Implement with Riverpod state
class AuthGuard {
  static String? redirect(BuildContext context, GoRouterState state) {
    // Check if user is authenticated
    // if (!isAuthenticated) return '/welcome';
    return null;
  }
}

class OnboardingGuard {
  static String? redirect(BuildContext context, GoRouterState state) {
    // Check if user has completed onboarding
    // if (!hasCompletedOnboarding) return '/onboarding';
    return null;
  }
}

class AssessmentGuard {
  static String? redirect(BuildContext context, GoRouterState state) {
    // Check if user has completed assessment
    // if (!hasCompletedAssessment) return '/assessment';
    return null;
  }
}

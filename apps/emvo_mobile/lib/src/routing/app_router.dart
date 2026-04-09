import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/assessment/assessment_screen.dart';
import '../features/coaching/coaching_screen.dart';
import '../features/dashboard/dashboard_shell.dart';
import '../features/dashboard/home_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/onboarding/eq_dimensions_intro_screen.dart';
import '../features/onboarding/intent_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/results/results_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/subscription/paywall_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/welcome/welcome_screen.dart';
import 'route_guards.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

class AppRouter {
  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/welcome',
    debugLogDiagnostics: true,
    routes: [
      // Welcome & Onboarding (no shell)
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginScreen(
          initialRegister: state.uri.queryParameters['mode'] == 'register',
        ),
      ),
      GoRoute(
        path: '/eq-intro',
        name: 'eq-intro',
        builder: (context, state) => const EqDimensionsIntroScreen(),
      ),
      GoRoute(
        path: '/intent',
        name: 'intent',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const IntentScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/onboarding',
        redirect: (context, state) => Routes.intent,
      ),
      GoRoute(
        path: '/paywall',
        name: 'paywall',
        builder: (context, state) => PaywallScreen(
          source: state.uri.queryParameters['source'],
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Assessment Flow (horizontal shared axis)
      GoRoute(
        path: '/assessment',
        name: 'assessment',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const AssessmentScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
        ),
      ),

      // Results (vertical shared axis - unveiling)
      GoRoute(
        path: '/results',
        name: 'results',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const ResultsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.vertical,
              child: child,
            );
          },
        ),
      ),

      // Dashboard Shell (persistent bottom nav)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => DashboardShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/coach',
            name: 'coach',
            // Match other shell tabs: avoid stacking [FadeScaleTransition] on top
            // of [PageTransitionSwitcher] (nested transitions + dual scaffolds
            // caused layout and inherited-widget issues for some devices).
            builder: (context, state) => const CoachingScreen(),
          ),
          GoRoute(
            path: '/progress',
            name: 'progress',
            builder: (context, state) => const ProgressScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],

    // Redirect logic: check auth, onboarding, and assessment state
    redirect: RouteGuards.checkAll,

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri.path}'),
      ),
    ),
  );
}

/// Route names for type-safe navigation
class Routes {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String eqIntro = '/eq-intro';
  static const String intent = '/intent';
  static const String onboarding = '/onboarding';
  static const String assessment = '/assessment';
  static const String results = '/results';
  static const String home = '/home';
  static const String coach = '/coach';
  static const String progress = '/progress';
  static const String profile = '/profile';
  static const String paywall = '/paywall';
  static const String settings = '/settings';
}

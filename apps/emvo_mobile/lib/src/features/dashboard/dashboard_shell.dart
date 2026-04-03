import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../../routing/routing.dart';

class DashboardShell extends StatelessWidget {
  const DashboardShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _calculateSelectedIndex(location);

    return Scaffold(
      body: PageTransitionSwitcher(
        duration: EmvoAnimations.normal,
        transitionBuilder: (
          Widget c,
          Animation<double> primary,
          Animation<double> secondary,
        ) {
          return FadeThroughTransition(
            animation: primary,
            secondaryAnimation: secondary,
            child: c,
          );
        },
        child: KeyedSubtree(
          key: ValueKey<String>(location),
          child: child,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) => _onItemTapped(index, context),
          backgroundColor: EmvoColors.surface,
          elevation: 0,
          indicatorColor: EmvoColors.primary.withValues(alpha: 0.2),
          animationDuration: EmvoAnimations.normal,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble),
              label: 'Coach',
            ),
            NavigationDestination(
              icon: Icon(Icons.trending_up_outlined),
              selectedIcon: Icon(Icons.trending_up),
              label: 'Progress',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(
            duration: EmvoAnimations.normal,
            curve: EmvoAnimations.standard,
          )
          .slideY(
            begin: 0.08,
            duration: EmvoAnimations.normal,
            curve: EmvoAnimations.decelerate,
          ),
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith(Routes.home)) {
      return 0;
    }
    if (location.startsWith(Routes.coach)) {
      return 1;
    }
    if (location.startsWith(Routes.progress)) {
      return 2;
    }
    if (location.startsWith(Routes.profile)) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(Routes.home);
        break;
      case 1:
        context.go(Routes.coach);
        break;
      case 2:
        context.go(Routes.progress);
        break;
      case 3:
        context.go(Routes.profile);
        break;
    }
  }
}

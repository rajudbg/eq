import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../../providers/daily_checkin_provider.dart';
import '../../routing/routing.dart';

class DashboardShell extends ConsumerStatefulWidget {
  const DashboardShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends ConsumerState<DashboardShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dailyCheckInProvider.notifier).refreshFromStorage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _calculateSelectedIndex(location);
    // [PageTransitionSwitcher] + [FadeThroughTransition] can build the active tab
    // in a subtree where [Directionality] is missing; [Icon] / [ListTile] then throw.
    final textDirection =
        Directionality.maybeOf(context) ?? TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
      // Only tab content should react to the keyboard; nested [Scaffold]s
      // both resizing causes broken constraints (huge overflow / layout errors).
      resizeToAvoidBottomInset: false,
      body: PageTransitionSwitcher(
        duration: EmvoAnimations.normal,
        // Default [Stack] uses [StackFit.loose], so the active tab can shrink to
        // intrinsic height and clip the app bar / status area. Expand so each
        // shell route fills the body like a full-screen page.
        layoutBuilder: (List<Widget> entries) => Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: entries,
        ),
        transitionBuilder: (
          Widget c,
          Animation<double> primary,
          Animation<double> secondary,
        ) {
          return FadeThroughTransition(
            animation: primary,
            secondaryAnimation: secondary,
            child: Directionality(
              textDirection: textDirection,
              child: c,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<String>(location),
          child: widget.child,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) => _onItemTapped(index, context),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          elevation: 0,
          indicatorColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
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
              label: 'You',
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

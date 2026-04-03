import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../../routing/routing.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // Mascot starts idle, then celebrates after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ref.read(mascotProvider.notifier).celebrate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mascotState = ref.watch(mascotProvider);
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EmvoDimensions.paddingScreen,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        // Default .scale() begins at (0,0) → invisible; start near 1.0.
                        EmvoMascotEmoji(size: 160)
                            .animate()
                            .scale(
                              begin: const Offset(0.88, 0.88),
                              duration: EmvoAnimations.slow,
                              curve: EmvoAnimations.spring,
                            ),
                        const SizedBox(height: 16),
                        if (mascotState == MascotState.celebrating)
                          Text(
                            'Welcome to Emvo!',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: EmvoColors.primary),
                          ).animate().fadeIn().slideY(begin: 0.12),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Emvo',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: EmvoColors.primary,
                          ),
                    ).animate().fadeIn(duration: EmvoAnimations.normal),
                    const SizedBox(height: 8),
                    Text(
                      'Emotional Intelligence,\nIn Motion',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: EmvoColors.onBackground.withValues(
                              alpha: (EmvoColors.onBackground.a * 0.7)
                                  .clamp(0.0, 1.0),
                            ),
                          ),
                    ).animate().fadeIn(
                          delay: const Duration(milliseconds: 200),
                        ),
                    const SizedBox(height: 32),
                    AnimatedButton(
                      text: 'Get Started',
                      onPressed: () {
                        ref.read(mascotProvider.notifier).encourage();
                        context.go(Routes.onboarding);
                      },
                      width: double.infinity,
                    ).animate().slideY(
                          begin: 0.12,
                          duration: EmvoAnimations.normal,
                        ),
                    const SizedBox(height: 16),
                    AnimatedButton(
                      text: 'I Already Have an Account',
                      onPressed: () => context.go(Routes.assessment),
                      isSecondary: true,
                      width: double.infinity,
                    ).animate().slideY(
                          begin: 0.12,
                          delay: const Duration(milliseconds: 100),
                        ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

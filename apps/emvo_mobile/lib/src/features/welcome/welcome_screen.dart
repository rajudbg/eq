import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../../routing/routing.dart';
import 'welcome_animated_logo.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _emphasizeLogo = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _emphasizeLogo = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EmvoAmbientBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EmvoDimensions.paddingScreen,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      WelcomeAnimatedLogo(emphasize: _emphasizeLogo),
                      const SizedBox(height: 28),
                      if (_emphasizeLogo)
                        Text(
                          'Welcome to Emvo!',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ).animate().fadeIn(duration: 400.ms).slideY(
                              begin: 0.1,
                              duration: 450.ms,
                              curve: Curves.easeOutCubic,
                            ),
                      if (_emphasizeLogo) const SizedBox(height: 12),
                      GlassContainer(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Emotional Intelligence,\nIn Motion',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: context.emvoOnSurface(0.78),
                                    height: 1.4,
                                  ),
                            ).animate().fadeIn(
                                  delay: const Duration(milliseconds: 180),
                                  duration: 450.ms,
                                ),
                            const SizedBox(height: 28),
                            AnimatedButton(
                              text: 'Get Started',
                              onPressed: () {
                                ref.read(mascotProvider.notifier).encourage();
                                context.go(Routes.onboarding);
                              },
                              width: double.infinity,
                            ).animate().slideY(
                                  begin: 0.1,
                                  duration: EmvoAnimations.normal,
                                  curve: EmvoAnimations.standard,
                                ),
                            const SizedBox(height: 14),
                            AnimatedButton(
                              text: 'I Already Have an Account',
                              onPressed: () => context.go(Routes.assessment),
                              isSecondary: true,
                              width: double.infinity,
                            ).animate().slideY(
                                  begin: 0.1,
                                  delay: const Duration(milliseconds: 90),
                                  duration: EmvoAnimations.normal,
                                  curve: EmvoAnimations.standard,
                                ),
                          ],
                        ),
                      ).animate().fadeIn(
                            delay: const Duration(milliseconds: 120),
                            duration: 500.ms,
                          ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../../providers/app_state_providers.dart';
import '../../routing/routing.dart';
import '../../providers/user_intent_provider.dart';
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
    Future<void>.delayed(const Duration(milliseconds: 420), () {
      if (mounted) setState(() => _emphasizeLogo = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(assessmentCompletionProvider, (prev, next) {
      if (next == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.go(Routes.home);
        });
      }
    });

    final scheme = context.emvoScheme;
    final subtle = context.emvoOnSurface(0.72);
    final bodyStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 1.48,
          color: context.emvoOnSurface(0.82),
          fontWeight: FontWeight.w500,
        );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: EmvoAmbientBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EmvoDimensions.paddingScreen,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      Center(
                        child: WelcomeAnimatedLogo(
                          emphasize: _emphasizeLogo,
                          size: 192,
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (_emphasizeLogo)
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: scheme.brightness == Brightness.dark
                                ? [
                                    Colors.white,
                                    const Color(0xFFE2D9F3),
                                    const Color(0xFFD4C4EB),
                                  ]
                                : [
                                    const Color(0xFF1E113C),
                                    const Color(0xFF2C1959),
                                    const Color(0xFF1A0E32),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            "You're capable.\nPeople respect you.",
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  height: 1.15,
                                  color: Colors.white,
                                  letterSpacing: -0.8,
                                ),
                          ),
                        )
                            .animate()
                            .fadeIn(
                              duration: 500.ms,
                              curve: Curves.easeOutCubic,
                            )
                            .slideY(
                              begin: 0.1,
                              duration: 550.ms,
                              curve: Curves.easeOutCubic,
                            ),
                      if (_emphasizeLogo) const SizedBox(height: 32),
                      if (_emphasizeLogo)
                        _StaggerLine(
                          delayMs: 40,
                          child: _BulletText(
                            text: 'But sometimes you say the wrong thing.',
                            style: bodyStyle,
                          ),
                        ),
                      if (_emphasizeLogo)
                        _StaggerLine(
                          delayMs: 110,
                          child: _BulletText(
                            text: 'Sometimes you shut down when it matters.',
                            style: bodyStyle,
                          ),
                        ),
                      if (_emphasizeLogo)
                        _StaggerLine(
                          delayMs: 180,
                          child: _BulletText(
                            text:
                                'Sometimes you wonder why relationships\nat work feel so draining.',
                            style: bodyStyle,
                          ),
                        ),
                      if (_emphasizeLogo) const SizedBox(height: 24),
                      if (_emphasizeLogo)
                        _StaggerLine(
                          delayMs: 250,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.surface.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: scheme.primary.withValues(alpha: 0.15),
                                ),
                              ),
                              child: Text(
                                "It's not about trying harder.\n"
                                "It's about understanding yourself better.",
                                textAlign: TextAlign.center,
                                style: bodyStyle?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.primary,
                                  fontSize: (bodyStyle.fontSize ?? 16) + 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (_emphasizeLogo) const SizedBox(height: 28),
                      if (_emphasizeLogo)
                        GlassContainer(
                          margin: EdgeInsets.zero,
                          padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AnimatedButton(
                                text: 'Take the EQ Assessment',
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  ref.read(mascotProvider.notifier).encourage();
                                  context.go(Routes.intent);
                                },
                                width: double.infinity,
                              )
                                  .animate()
                                  .fadeIn(
                                    delay: 300.ms,
                                    duration: 400.ms,
                                  )
                                  .slideY(
                                    begin: 0.08,
                                    delay: 300.ms,
                                    duration: 420.ms,
                                    curve: Curves.easeOutCubic,
                                  ),
                              const SizedBox(height: 10),
                              Text(
                                'Takes about 8 minutes · Completely free',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: subtle, height: 1.35),
                              ).animate().fadeIn(
                                    delay: 360.ms,
                                    duration: 450.ms,
                                  ),
                              const SizedBox(height: 18),
                              AnimatedButton(
                                text: 'I already have an account',
                                onPressed: () {
                                  final hasLocalIntent =
                                      ref.read(userIntentProvider) != null;
                                  final signedIn = ref.read(authProvider);
                                  if (signedIn || hasLocalIntent) {
                                    context.go(Routes.assessment);
                                  } else {
                                    context.go(Routes.intent);
                                  }
                                },
                                isSecondary: true,
                                width: double.infinity,
                              )
                                  .animate()
                                  .fadeIn(
                                    delay: 380.ms,
                                    duration: 400.ms,
                                  )
                                  .slideY(
                                    begin: 0.06,
                                    delay: 380.ms,
                                    duration: 400.ms,
                                    curve: Curves.easeOutCubic,
                                  ),
                            ],
                          ),
                        ).animate().fadeIn(
                              delay: 280.ms,
                              duration: 480.ms,
                              curve: Curves.easeOutCubic,
                            ),
                      const SizedBox(height: 20),
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

class _StaggerLine extends StatelessWidget {
  const _StaggerLine({
    required this.delayMs,
    required this.child,
  });

  final int delayMs;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: child
          .animate()
          .fadeIn(
            delay: Duration(milliseconds: delayMs),
            duration: 380.ms,
            curve: Curves.easeOutCubic,
          )
          .slideY(
            begin: 0.04,
            delay: Duration(milliseconds: delayMs),
            duration: 400.ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}

class _BulletText extends StatelessWidget {
  const _BulletText({required this.text, this.style});
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final scheme = context.emvoScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: style,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

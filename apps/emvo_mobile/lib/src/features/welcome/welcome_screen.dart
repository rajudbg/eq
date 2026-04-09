import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../../providers/app_state_providers.dart';
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
    final bodyStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 1.48,
          color: context.emvoOnSurface(0.82),
          fontWeight: FontWeight.w500,
        );
    final bulletStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 13,
          height: 1.38,
          color: context.emvoOnSurface(0.78),
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
                      const SizedBox(height: 8),
                      Center(
                        child: WelcomeAnimatedLogo(
                          emphasize: _emphasizeLogo,
                          size: 152,
                        ),
                      ),
                      const SizedBox(height: 18),
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
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  height: 1.15,
                                  color: Colors.white,
                                  letterSpacing: -0.6,
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
                      if (_emphasizeLogo) const SizedBox(height: 20),
                      if (_emphasizeLogo)
                        _StaggerLine(
                          delayMs: 40,
                          child: _BulletLine(
                            text: 'Sometimes the wrong words slip out.',
                            style: bulletStyle,
                          ),
                        ),
                      if (_emphasizeLogo)
                        _StaggerLine(
                          delayMs: 110,
                          child: _BulletLine(
                            text:
                                'Sometimes you go quiet when it matters most.',
                            style: bulletStyle,
                          ),
                        ),
                      if (_emphasizeLogo)
                        _StaggerLine(
                          delayMs: 180,
                          child: _BulletLine(
                            text:
                                'And sometimes… people just feel exhausting.',
                            style: bulletStyle,
                          ),
                        ),
                      if (_emphasizeLogo) const SizedBox(height: 12),
                      if (_emphasizeLogo)
                        _StaggerLine(
                          delayMs: 250,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.surface.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: scheme.primary.withValues(alpha: 0.15),
                                ),
                              ),
                              child: Text(
                                "It's not about trying harder—it's about "
                                'understanding yourself better.',
                                textAlign: TextAlign.center,
                                style: bodyStyle?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.primary,
                                  fontSize: (bodyStyle.fontSize ?? 16) * 0.94,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (_emphasizeLogo) const SizedBox(height: 14),
                      if (_emphasizeLogo)
                        GlassContainer(
                          margin: EdgeInsets.zero,
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AnimatedButton(
                                text: 'Discover your EQ',
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  ref.read(mascotProvider.notifier).encourage();
                                  final seen = ref.read(eqDimensionsIntroSeenProvider);
                                  context.go(
                                    seen ? Routes.intent : Routes.eqIntro,
                                  );
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
                              const SizedBox(height: 6),
                              Text(
                                'EQ profile & growth plan · ~10 min · Free',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: context.emvoOnSurface(0.72),
                                      height: 1.3,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ).animate().fadeIn(
                                    delay: 340.ms,
                                    duration: 450.ms,
                                  ),
                              const SizedBox(height: 12),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    context.go(Routes.login);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        context.emvoOnSurface(0.55),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'I already have an account',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.15,
                                        ),
                                  ),
                                ),
                              )
                                  .animate()
                                  .fadeIn(
                                    delay: 380.ms,
                                    duration: 400.ms,
                                  )
                                  .slideY(
                                    begin: 0.04,
                                    delay: 380.ms,
                                    duration: 400.ms,
                                    curve: Curves.easeOutCubic,
                                  ),
                              TextButton(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  context.go(Routes.login);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      context.emvoOnSurface(0.45),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Google, Apple, Facebook, or email',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        height: 1.25,
                                      ),
                                ),
                              )
                                  .animate()
                                  .fadeIn(
                                    delay: 420.ms,
                                    duration: 400.ms,
                                  ),
                            ],
                          ),
                        ).animate().fadeIn(
                              delay: 280.ms,
                              duration: 480.ms,
                              curve: Curves.easeOutCubic,
                            ),
                      const SizedBox(height: 8),
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
      padding: const EdgeInsets.only(bottom: 10),
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

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final scheme = context.emvoScheme;
    final bulletColor = scheme.primary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Icon(
            Icons.fiber_manual_record,
            size: 10,
            color: bulletColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: style,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:emvo_ui/emvo_ui.dart';

/// Single hero logo: heart mark on brand gradient, with layered motion.
class WelcomeAnimatedLogo extends StatefulWidget {
  const WelcomeAnimatedLogo({
    super.key,
    this.emphasize = false,
    this.size = 168,
  });

  /// When true (e.g. after a short delay), plays a one-shot “hello” burst.
  final bool emphasize;
  final double size;

  @override
  State<WelcomeAnimatedLogo> createState() => _WelcomeAnimatedLogoState();
}

class _WelcomeAnimatedLogoState extends State<WelcomeAnimatedLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.size * 0.24;
    final logoPath = 'assets/branding/emvo_logo.png';

    final core = AnimatedBuilder(
      animation: _shimmer,
      builder: (context, child) {
        final t = _shimmer.value * math.pi * 2;
        final breath = 1.0 + 0.035 * math.sin(t);
        final tilt = 0.018 * math.sin(t * 0.5);
        return Transform.rotate(
          angle: tilt,
          child: Transform.scale(
            scale: breath,
            child: child,
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: EmvoColors.brandGradient,
                ),
              ),
              // Soft inner vignette for depth
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.05,
                    colors: [
                      Colors.white.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.12),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(widget.size * 0.14),
                child: Image.asset(
                  logoPath,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.favorite_rounded,
                    size: widget.size * 0.42,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return SizedBox(
      width: widget.size + 32,
      height: widget.size + 32,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Ambient glow (reacts to emphasize)
          ListenableBuilder(
            listenable: _shimmer,
            builder: (context, _) {
              final pulse =
                  0.55 + 0.12 * math.sin(_shimmer.value * math.pi * 2);
              return Container(
                width: widget.size * 1.35,
                height: widget.size * 1.35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: EmvoColors.brandMagenta.withValues(
                        alpha: widget.emphasize ? 0.42 : 0.28 * pulse,
                      ),
                      blurRadius: widget.emphasize ? 48 : 32,
                      spreadRadius: widget.emphasize ? 2 : 0,
                    ),
                    BoxShadow(
                      color: EmvoColors.accentCyan.withValues(
                        alpha: widget.emphasize ? 0.22 : 0.12,
                      ),
                      blurRadius: widget.emphasize ? 36 : 22,
                    ),
                  ],
                ),
              );
            },
          ),
          core
              .animate()
              .fadeIn(
                duration: 500.ms,
                curve: Curves.easeOutCubic,
              )
              .scale(
                begin: const Offset(0.78, 0.78),
                duration: 950.ms,
                curve: Curves.easeOutCubic,
              )
              .animate(
                target: widget.emphasize ? 1 : 0,
              )
              .shake(
                hz: 3,
                rotation: 0.02,
                duration: 520.ms,
                curve: Curves.easeOutCubic,
              )
              .scale(
                duration: 480.ms,
                begin: const Offset(1, 1),
                end: const Offset(1.08, 1.08),
                curve: Curves.easeOutBack,
              ),
        ],
      ),
    );
  }
}

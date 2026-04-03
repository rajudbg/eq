import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../emvo_ui.dart';

class AnimatedScoreRing extends StatelessWidget {
  final double score; // 0-100
  final double size;
  final bool animated;

  const AnimatedScoreRing({
    super.key,
    required this.score,
    this.size = 120,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    final clampedScore = score.clamp(0.0, 100.0);
    final color = _getScoreColor(clampedScore);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          CircularProgressIndicator(
            value: 1,
            strokeWidth: size * 0.08,
            backgroundColor: EmvoColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              color.withValues(alpha: (color.a * 0.2).clamp(0.0, 1.0)),
            ),
          ),

          // Animated progress ring
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: clampedScore / 100),
            duration: animated ? EmvoAnimations.verySlow : Duration.zero,
            curve: EmvoAnimations.decelerate,
            builder: (context, value, child) {
              return CircularProgressIndicator(
                value: value,
                strokeWidth: size * 0.08,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeCap: StrokeCap.round,
              );
            },
          ),

          // Score text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                clampedScore.toInt().toString(),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: color,
                      fontSize: size * 0.35,
                    ),
              ).animate(target: animated ? 1 : 0).scale(
                    begin: const Offset(0.5, 0.5),
                    duration: EmvoAnimations.slow,
                    curve: EmvoAnimations.spring,
                  ),
              Text(
                'EQ',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: EmvoColors.onBackground.withValues(
                        alpha:
                            (EmvoColors.onBackground.a * 0.6).clamp(0.0, 1.0),
                      ),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return EmvoColors.success;
    if (score >= 60) return EmvoColors.primary;
    if (score >= 40) return EmvoColors.secondary;
    return EmvoColors.tertiary;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../emvo_ui.dart';

class AnimatedProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final bool showPercentage;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: EmvoColors.surfaceVariant,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: EmvoAnimations.slow,
                    curve: EmvoAnimations.standard,
                    width: constraints.maxWidth * progress.clamp(0, 1),
                    height: height,
                    decoration: BoxDecoration(
                      gradient: EmvoColors.primaryGradient,
                      borderRadius: BorderRadius.circular(height / 2),
                      boxShadow: EmvoDimensions.shadowSm,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (showPercentage) ...[
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}%',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: EmvoColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ).animate().fadeIn(),
        ],
      ],
    );
  }
}

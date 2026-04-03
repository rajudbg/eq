import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../emvo_ui.dart';

class AnimatedOptionCard extends StatefulWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const AnimatedOptionCard({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  State<AnimatedOptionCard> createState() => _AnimatedOptionCardState();
}

class _AnimatedOptionCardState extends State<AnimatedOptionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final s = _isPressed ? 0.98 : 1.0;
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: EmvoAnimations.fast,
        curve: EmvoAnimations.spring,
        transform: Matrix4.diagonal3Values(s, s, 1.0),
        child: GlassContainer(
          color: widget.isSelected
              ? EmvoColors.primary.withValues(
                  alpha: (EmvoColors.primary.a * 0.15).clamp(0.0, 1.0),
                )
              : EmvoColors.glassWhite,
          border: widget.isSelected
              ? Border.all(color: EmvoColors.primary, width: 2)
              : null,
          padding: const EdgeInsets.all(EmvoDimensions.md),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: widget.isSelected
                      ? EmvoColors.primary
                      : EmvoColors.onBackground.withValues(
                          alpha:
                              (EmvoColors.onBackground.a * 0.6).clamp(0.0, 1.0),
                        ),
                ),
                const SizedBox(width: EmvoDimensions.md),
              ],
              Expanded(
                child: Text(
                  widget.text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: widget.isSelected
                            ? EmvoColors.primary
                            : EmvoColors.onBackground,
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                ),
              ),
              if (widget.isSelected)
                const Icon(Icons.check_circle, color: EmvoColors.primary)
                    .animate()
                    .scale(duration: EmvoAnimations.fast),
            ],
          ),
        ),
      ),
    );
  }
}

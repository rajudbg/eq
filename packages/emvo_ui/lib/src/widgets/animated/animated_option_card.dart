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
    final scheme = context.emvoScheme;
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
              ? scheme.primary.withValues(alpha: 0.15)
              : null,
          border: widget.isSelected
              ? Border.all(color: scheme.primary, width: 2)
              : null,
          padding: const EdgeInsets.all(EmvoDimensions.md),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: widget.isSelected
                      ? scheme.primary
                      : context.emvoOnSurface(0.58),
                ),
                const SizedBox(width: EmvoDimensions.md),
              ],
              Expanded(
                child: Text(
                  widget.text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: widget.isSelected
                            ? scheme.primary
                            : scheme.onSurface,
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                ),
              ),
              if (widget.isSelected)
                Icon(Icons.check_circle, color: scheme.primary)
                    .animate()
                    .scale(duration: EmvoAnimations.fast),
            ],
          ),
        ),
      ),
    );
  }
}

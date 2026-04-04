import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../emvo_ui.dart';

class AnimatedOptionCard extends StatefulWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  /// Single-letter label (e.g. A–D) so options read as choices, not scenario text.
  final String? badgeLabel;

  const AnimatedOptionCard({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.badgeLabel,
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
          color:
              widget.isSelected ? scheme.primary.withValues(alpha: 0.15) : null,
          border: widget.isSelected
              ? Border.all(color: scheme.primary, width: 2)
              : null,
          padding: const EdgeInsets.symmetric(
            horizontal: EmvoDimensions.md,
            vertical: EmvoDimensions.md - 2,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.badgeLabel != null &&
                  widget.badgeLabel!.isNotEmpty) ...[
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isSelected
                        ? scheme.primary.withValues(alpha: 0.18)
                        : scheme.surfaceContainerHighest
                            .withValues(alpha: 0.65),
                    border: Border.all(
                      color: widget.isSelected
                          ? scheme.primary
                          : scheme.outline.withValues(alpha: 0.45),
                      width: widget.isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    widget.badgeLabel!,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: widget.isSelected
                              ? scheme.primary
                              : context.emvoOnSurface(0.55),
                          height: 1,
                        ),
                  ),
                ),
                const SizedBox(width: EmvoDimensions.md),
              ],
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                        color: widget.isSelected
                            ? scheme.primary
                            : scheme.onSurface.withValues(alpha: 0.92),
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
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

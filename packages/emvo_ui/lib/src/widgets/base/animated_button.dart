import 'package:flutter/material.dart';

import '../../theme/emvo_animations.dart';
import '../../theme/emvo_colors.dart';

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;
  final double? width;

  const AnimatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
    this.width,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        widget.isSecondary ? Colors.transparent : EmvoColors.primary;
    final fgColor = widget.isSecondary ? EmvoColors.primary : Colors.white;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: EmvoAnimations.fast,
        curve: EmvoAnimations.spring,
        width: widget.width,
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: widget.isSecondary
                ? Border.all(color: EmvoColors.primary, width: 2)
                : null,
            boxShadow: _isPressed || widget.isSecondary
                ? []
                : [
                    BoxShadow(
                      color: EmvoColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: widget.width != null
                      ? MainAxisSize.max
                      : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: fgColor, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: fgColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

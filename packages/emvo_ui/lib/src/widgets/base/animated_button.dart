import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/emvo_colors.dart';
import 'emvo_loading_indicator.dart';

class AnimatedButton extends StatefulWidget {
  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
    this.width,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;
  final double? width;

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isPressed = false;

  static const Duration _pressAnimDuration = Duration(milliseconds: 100);

  @override
  void didUpdateWidget(AnimatedButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && _isPressed) {
      _isPressed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fgSecondary = scheme.primary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        if (widget.isLoading) return;
        setState(() => _isPressed = true);
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: (widget.isLoading || widget.onPressed == null)
          ? null
          : () {
              HapticFeedback.lightImpact();
              widget.onPressed!();
            },
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: _pressAnimDuration,
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: widget.width,
          child: widget.isSecondary
              ? _secondaryBody(context, fgSecondary)
              : _primaryBody(context),
        ),
      ),
    );
  }

  Widget _primaryBody(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDisabled = widget.onPressed == null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDisabled ? scheme.surfaceContainerHighest : null,
        gradient: isDisabled ? null : EmvoColors.brandGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDisabled ? [] : [
          BoxShadow(
            color: EmvoColors.brandMagenta.withValues(
              alpha: _isPressed ? 0.2 : 0.45,
            ),
            blurRadius: _isPressed ? 10 : 20,
            offset: Offset(0, _isPressed ? 4 : 8),
          ),
        ],
      ),
      child: widget.isLoading
          ? const Center(
              child: EmvoLoadingIndicator(size: EmvoLoaderSize.compact),
            )
          : _labelRow(isDisabled ? scheme.onSurface.withValues(alpha: 0.38) : Colors.white),
    );
  }

  Widget _secondaryBody(BuildContext context, Color fg) {
    final scheme = Theme.of(context).colorScheme;
    final isDisabled = widget.onPressed == null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDisabled ? scheme.onSurface.withValues(alpha: 0.12) : fg.withValues(alpha: 0.55),
          width: 1.5,
        ),
      ),
      child: widget.isLoading
          ? const Center(
              child: EmvoLoadingIndicator(size: EmvoLoaderSize.compact),
            )
          : _labelRow(isDisabled ? scheme.onSurface.withValues(alpha: 0.38) : fg),
    );
  }

  Widget _labelRow(Color fg) {
    return Row(
      mainAxisSize: widget.width != null ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, color: fg, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: TextStyle(
            color: fg,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

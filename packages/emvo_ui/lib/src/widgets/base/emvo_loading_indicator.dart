import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/emvo_colors.dart';

/// Brand-aligned loader: gradient orbital ring + soft core pulse (no Material spinner).
class EmvoLoadingIndicator extends StatefulWidget {
  const EmvoLoadingIndicator({
    super.key,
    this.message,
    this.size = EmvoLoaderSize.standard,
  });

  /// Optional caption under the orbit (standard size only).
  final String? message;

  final EmvoLoaderSize size;

  @override
  State<EmvoLoadingIndicator> createState() => _EmvoLoadingIndicatorState();
}

enum EmvoLoaderSize {
  /// ~56px — screens, bootstrap.
  standard,

  /// ~22px — inline in buttons.
  compact,
}

class _EmvoLoadingIndicatorState extends State<EmvoLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbit;

  @override
  void initState() {
    super.initState();
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _orbit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dim = widget.size == EmvoLoaderSize.standard ? 56.0 : 22.0;
    final stroke = widget.size == EmvoLoaderSize.standard ? 3.2 : 2.0;

    final orbit = AnimatedBuilder(
      animation: _orbit,
      builder: (context, child) {
        return CustomPaint(
          size: Size(dim, dim),
          painter: _GradientOrbitPainter(
            rotation: _orbit.value * 2 * math.pi,
            strokeWidth: stroke,
          ),
        );
      },
    );

    if (widget.size == EmvoLoaderSize.compact) {
      return SizedBox(width: dim, height: dim, child: orbit);
    }

    final scheme = Theme.of(context).colorScheme;
    final msg = widget.message;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: dim + 8,
          height: dim + 8,
          child: Stack(
            alignment: Alignment.center,
            children: [
              orbit,
              _BreathingCore(
                color: scheme.primary.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
        if (msg != null && msg.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.62),
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  letterSpacing: 0.2,
                ),
          ),
        ],
      ],
    );
  }
}

/// Full-screen body: ambient-style panel with the orbital loader centered.
class EmvoLoadingPanel extends StatelessWidget {
  const EmvoLoadingPanel({
    super.key,
    this.message = 'Loading…',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: isDark
                ? EmvoColors.surfaceDark.withValues(alpha: 0.42)
                : Colors.white.withValues(alpha: 0.55),
            border: Border.all(
              color: scheme.primary.withValues(alpha: isDark ? 0.14 : 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.08),
                blurRadius: 32,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
            child: EmvoLoadingIndicator(message: message),
          ),
        ),
      ),
    );
  }
}

class _GradientOrbitPainter extends CustomPainter {
  _GradientOrbitPainter({
    required this.rotation,
    required this.strokeWidth,
  });

  final double rotation;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.shortestSide / 2) - strokeWidth;
    final rect = Rect.fromCircle(center: c, radius: r);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        tileMode: TileMode.clamp,
        colors: [
          EmvoColors.brandMagenta.withValues(alpha: 0.05),
          EmvoColors.brandMagenta.withValues(alpha: 0.95),
          EmvoColors.brandPurple.withValues(alpha: 0.95),
          EmvoColors.brandOrange.withValues(alpha: 0.9),
          EmvoColors.accentCyan.withValues(alpha: 0.65),
          EmvoColors.brandMagenta.withValues(alpha: 0.05),
        ],
        stops: const [0.0, 0.18, 0.38, 0.58, 0.78, 1.0],
      ).createShader(rect);

    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(rotation);
    canvas.translate(-c.dx, -c.dy);
    canvas.drawArc(rect, 0.15, math.pi * 1.85, false, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GradientOrbitPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class _BreathingCore extends StatefulWidget {
  const _BreathingCore({required this.color});

  final Color color;

  @override
  State<_BreathingCore> createState() => _BreathingCoreState();
}

class _BreathingCoreState extends State<_BreathingCore>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_c.value);
        final scale = 0.65 + t * 0.55;
        final opacity = 0.25 + t * 0.45;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withValues(alpha: opacity),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: opacity * 0.8),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

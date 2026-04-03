import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../theme/emvo_colors.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 24,
    this.blur = 24,
    this.color,
    this.padding,
    this.margin,
    this.border,
  });

  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blur;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultFill =
        color ?? (isDark ? EmvoColors.glassDark : EmvoColors.glassLight);
    final strokeColor =
        isDark ? EmvoColors.glassStrokeDark : EmvoColors.glassStrokeLight;

    final fill = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(defaultFill, Colors.white, isDark ? 0.08 : 0.6) ??
                defaultFill,
            defaultFill,
            Color.lerp(defaultFill, Colors.black, isDark ? 0.2 : 0.05) ??
                defaultFill,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );

    final clip = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: kIsWeb
          ? fill
          : BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: fill,
            ),
    );

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ??
            Border.all(
              color: strokeColor,
              width: 1,
            ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: clip,
    );
  }
}

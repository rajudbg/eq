import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/emvo_colors.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blur;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Border? border;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.blur = 10,
    this.color,
    this.padding,
    this.margin,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border:
            border ??
            Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? EmvoColors.glassWhite,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../emvo_ui.dart';

class TypewriterText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Duration delay;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style ?? Theme.of(context).textTheme.bodyLarge,
    ).animate().fadeIn(delay: delay).moveY(
          begin: 10,
          end: 0,
          delay: delay,
          duration: EmvoAnimations.normal,
        );
  }
}

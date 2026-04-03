import 'package:flutter/material.dart';

/// Wordmark for the app bar (replaces plain "Emvo" text).
class EmvoAppBarTitle extends StatelessWidget {
  const EmvoAppBarTitle({
    super.key,
    this.height = 30,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Emvo',
      child: Image.asset(
        'assets/branding/emvo_logo_with_text.png',
        height: height,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => Text(
          'Emvo',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

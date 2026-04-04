import 'package:flutter/material.dart';

/// Mark-only logo for the app bar (no wordmark). Sized to read larger while
/// staying within the default Material toolbar height — do not raise
/// [AppBar.toolbarHeight] here.
class EmvoAppBarTitle extends StatelessWidget {
  const EmvoAppBarTitle({
    super.key,
    /// Fits comfortably inside [kToolbarHeight] with standard padding (~56dp).
    this.height = 40,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Emvo',
      child: Image.asset(
        'assets/branding/emvo_logo.png',
        height: height,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => Icon(
          Icons.favorite_rounded,
          size: height * 0.88,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

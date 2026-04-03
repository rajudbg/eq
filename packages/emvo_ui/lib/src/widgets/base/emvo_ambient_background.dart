import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../theme/emvo_colors.dart';

/// Soft gradient + blurred “blobs” behind glass UI (matches logo energy).
class EmvoAmbientBackground extends StatelessWidget {
  const EmvoAmbientBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // On mobile/desktop, a new subtree when brightness flips can help after blur
    // layers. On web, remounting the full [Stack] has been observed to contribute
    // to RawView `renderObject.child` assertions when toggling theme — update
    // decorations in place instead.
    return Stack(
      key: kIsWeb ? null : ValueKey<bool>(isDark),
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [
                      EmvoColors.backgroundDark,
                      Color(0xFF12102A),
                      Color(0xFF1A0E32),
                    ]
                  : const [
                      Color(0xFFF0EBFA),
                      Color(0xFFFAF5FF),
                      Color(0xFFFFF5F0),
                    ],
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -60,
          child: _BlurBlob(
            diameter: 260,
            color: (isDark ? EmvoColors.brandMagenta : EmvoColors.brandPurple)
                .withValues(alpha: isDark ? 0.22 : 0.18),
          ),
        ),
        Positioned(
          bottom: 120,
          left: -100,
          child: _BlurBlob(
            diameter: 320,
            color: (isDark ? EmvoColors.brandOrange : EmvoColors.primary)
                .withValues(alpha: isDark ? 0.14 : 0.12),
          ),
        ),
        Positioned(
          top: 180,
          left: 40,
          child: _BlurBlob(
            diameter: 140,
            color: EmvoColors.accentCyan.withValues(alpha: isDark ? 0.08 : 0.1),
          ),
        ),
        child,
      ],
    );
  }
}

class _BlurBlob extends StatelessWidget {
  const _BlurBlob({
    required this.diameter,
    required this.color,
  });

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );

    // ImageFiltered + blur is a frequent source of view/layer bugs on Flutter web
    // when the tree rebuilds (e.g. light/dark toggle).
    if (kIsWeb) {
      return Opacity(
        opacity: 0.92,
        child: circle,
      );
    }

    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 64, sigmaY: 64),
      child: circle,
    );
  }
}

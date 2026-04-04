
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../theme/emvo_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
          top: -120,
          right: -80,
          child: _BlurBlob(
            diameter: 480,
            color: (isDark ? EmvoColors.brandMagenta : EmvoColors.brandPurple)
                .withValues(alpha: isDark ? 0.45 : 0.40),
          ),
        ),
        Positioned(
          bottom: 20,
          left: -140,
          child: _BlurBlob(
            diameter: 560,
            color: (isDark ? EmvoColors.brandOrange : EmvoColors.primary)
                .withValues(alpha: isDark ? 0.35 : 0.30),
          ),
        ),
        Positioned(
          top: 240,
          left: 80,
          child: _BlurBlob(
            diameter: 320,
            color:
                EmvoColors.accentCyan.withValues(alpha: isDark ? 0.25 : 0.28),
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
    // We use a BoxShape.circle with a RadialGradient to create a performant,
    // gorgeous blur effect that works flawlessly on Flutter Web canvas/wasm
    // without the ImageFiltered performance and layout bugs.
    Widget blob = Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0.0),
          ],
          stops: const [0.1, 1.0],
        ),
      ),
    );

    // Pseudo-randomize based on diameter to avoid them moving in unison
    final int durationSec = 10 + (diameter % 8).toInt();
    final double moveOffset = diameter / 4;

    return blob
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .move(
          begin: Offset(-moveOffset, -moveOffset / 2),
          end: Offset(moveOffset, moveOffset / 2),
          duration: durationSec.seconds,
          curve: Curves.easeInOutSine,
        )
        .scale(
          begin: const Offset(0.9, 0.95),
          end: const Offset(1.1, 1.05),
          duration: (durationSec + 2).seconds,
          curve: Curves.easeInOutSine,
        );
  }
}

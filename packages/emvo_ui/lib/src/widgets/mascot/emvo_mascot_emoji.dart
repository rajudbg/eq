import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/emvo_colors.dart';
import 'mascot_controller.dart';

/// Emoji stand-in for the Rive mascot until `.riv` assets are available.
/// Watches [mascotProvider] so UI matches the same reactions as [EmvoMascot].
class EmvoMascotEmoji extends ConsumerWidget {
  const EmvoMascotEmoji({
    super.key,
    this.size = 120,
  });

  final double size;

  static String emojiFor(MascotState state) {
    switch (state) {
      case MascotState.listening:
        return '👂';
      case MascotState.thinking:
        return '🤔';
      case MascotState.happy:
        return '😊';
      case MascotState.concerned:
        return '😟';
      case MascotState.celebrating:
        return '🎉';
      case MascotState.encouraging:
        return '💪';
      case MascotState.surprised:
        return '😮';
      case MascotState.idle:
        return '😌';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mascotProvider);
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: EmvoColors.primaryGradient,
          borderRadius: BorderRadius.circular(size * 0.25),
        ),
        child: Center(
          child: Text(
            emojiFor(state),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size * 0.45,
              height: 1,
              fontFamilyFallback: const [
                'Apple Color Emoji',
                'Segoe UI Emoji',
                'Noto Color Emoji',
              ],
            ),
          ),
        ),
      ),
    );
  }
}

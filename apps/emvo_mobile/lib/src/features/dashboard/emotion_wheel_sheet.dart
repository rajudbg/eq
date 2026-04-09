import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:emvo_ui/emvo_ui.dart';

import 'emotion_vocabulary.dart';

/// Bottom sheet that shows specific emotion words for a broad [MoodCategory].
///
/// Returns the selected [EmotionWord] label (e.g. "Grateful") when the user
/// taps one, or `null` if dismissed.
///
/// Matches the existing glassmorphism / ambient-bg patterns used throughout
/// the Emvo dashboard.
Future<String?> showEmotionWheelSheet(
  BuildContext context, {
  required MoodCategory category,
}) async {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EmotionWheelSheet(category: category),
  );
}

class _EmotionWheelSheet extends StatelessWidget {
  const _EmotionWheelSheet({required this.category});

  final MoodCategory category;

  @override
  Widget build(BuildContext context) {
    final words = emotionVocabulary[category] ?? [];
    final isDark = context.isDarkMode;
    final scheme = Theme.of(context).colorScheme;
    final safePadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.55,
      ),
      decoration: BoxDecoration(
        color: isDark ? EmvoColors.surfaceDark : EmvoColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: isDark
                ? EmvoColors.glassStrokeDark
                : EmvoColors.glassStrokeLight,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: EmvoDimensions.lg,
            right: EmvoDimensions.lg,
            top: EmvoDimensions.lg,
            bottom: safePadding + EmvoDimensions.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Handle ──
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.emvoOnSurface(0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Header ──
              Row(
                children: [
                  Text(
                    category.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You feel ${category.label.toLowerCase()}…',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Can you name it more precisely?',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: context.emvoOnSurface(0.6),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.05, duration: 300.ms),

              const SizedBox(height: 20),

              // ── Emotion grid ──
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: words.asMap().entries.map((entry) {
                      final i = entry.key;
                      final word = entry.value;
                      return _EmotionWordChip(
                        word: word,
                        accent: scheme.primary,
                        onTap: () => Navigator.of(context).pop(word.label),
                      )
                          .animate()
                          .fadeIn(
                            duration: 260.ms,
                            delay: Duration(milliseconds: 40 * i),
                          )
                          .slideY(
                            begin: 0.08,
                            duration: 280.ms,
                            delay: Duration(milliseconds: 40 * i),
                            curve: Curves.easeOutCubic,
                          );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Skip link ──
              Center(
                child: TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(category.label),
                  child: Text(
                    'Just log as "${category.label}"',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: context.emvoOnSurface(0.5),
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmotionWordChip extends StatefulWidget {
  const _EmotionWordChip({
    required this.word,
    required this.accent,
    required this.onTap,
  });

  final EmotionWord word;
  final Color accent;
  final VoidCallback onTap;

  @override
  State<_EmotionWordChip> createState() => _EmotionWordChipState();
}

class _EmotionWordChipState extends State<_EmotionWordChip> {
  bool _showDefinition = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: () => setState(() => _showDefinition = !_showDefinition),
      child: AnimatedContainer(
        duration: EmvoAnimations.fast,
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(EmvoDimensions.radiusMd),
          border: Border.all(
            color: _showDefinition
                ? widget.accent.withValues(alpha: 0.4)
                : context.emvoOutline(0.12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.word.emoji,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.word.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            if (_showDefinition) ...[
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: Text(
                  widget.word.definition,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: context.emvoOnSurface(0.6),
                        height: 1.3,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:emvo_ui/emvo_ui.dart';

class SuggestedPrompts extends StatelessWidget {
  const SuggestedPrompts({
    super.key,
    required this.prompts,
    required this.onPromptSelected,
  });

  final List<String> prompts;
  final void Function(String) onPromptSelected;

  @override
  Widget build(BuildContext context) {
    if (prompts.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: EmvoDimensions.md),
        itemCount: prompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => onPromptSelected(prompts[index]),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Center(
                child: Text(
                  prompts[index],
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: index * 100),
              )
              .slideX(begin: 0.2);
        },
      ),
    );
  }
}

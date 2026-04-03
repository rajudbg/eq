import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:emvo_ui/emvo_ui.dart';

class SuggestedPrompts extends StatelessWidget {
  const SuggestedPrompts({
    super.key,
    required this.onPromptSelected,
  });

  final void Function(String) onPromptSelected;

  static const List<String> _prompts = [
    "I'm feeling overwhelmed today",
    "Help me prepare for a difficult conversation",
    "Why do I react so strongly to criticism?",
    "Teach me a quick calming technique",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: EmvoDimensions.md),
        itemCount: _prompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => onPromptSelected(_prompts[index]),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Center(
                child: Text(
                  _prompts[index],
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

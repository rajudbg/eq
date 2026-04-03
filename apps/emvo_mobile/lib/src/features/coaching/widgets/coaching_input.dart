import 'package:flutter/material.dart';
import 'package:emvo_ui/emvo_ui.dart';

class CoachingInput extends StatelessWidget {
  const CoachingInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.isTyping = false,
  });

  final TextEditingController controller;
  final Function(String) onSend;
  final bool isTyping;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(EmvoDimensions.md),
        decoration: BoxDecoration(
          color: EmvoColors.surface,
          boxShadow: EmvoDimensions.shadowSm,
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {},
            ),
            Expanded(
              child: GlassContainer(
                blur: 0,
                color: EmvoColors.surfaceVariant,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: isTyping ? null : onSend,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: EmvoAnimations.fast,
              child: Material(
                color: isTyping ? EmvoColors.surfaceVariant : EmvoColors.primary,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: isTyping ? null : () => onSend(controller.text),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.send,
                      color: isTyping
                          ? EmvoColors.onBackground.withValues(alpha: 0.3)
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

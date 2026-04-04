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
    final scheme = context.emvoScheme;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(EmvoDimensions.md),
        decoration: BoxDecoration(
          color: scheme.surface,
          boxShadow: EmvoDimensions.shadowSm,
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.auto_awesome_outlined,
                color: EmvoColors.primary.withValues(alpha: 0.75),
              ),
              onPressed: () {},
            ),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: [
                      EmvoColors.primary.withValues(alpha: 0.2),
                      EmvoColors.tertiary.withValues(alpha: 0.12),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1.2),
                  child: GlassContainer(
                    blur: 0,
                    color: scheme.surfaceContainerHighest,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'Share what’s on your mind…',
                        hintStyle: TextStyle(
                          color: context.emvoOnSurface(0.45),
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 6,
                      textInputAction: TextInputAction.send,
                      onSubmitted: isTyping
                          ? null
                          : (value) {
                              FocusManager.instance.primaryFocus?.unfocus();
                              onSend(value);
                            },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: EmvoAnimations.fast,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: isTyping
                    ? null
                    : LinearGradient(
                        colors: [
                          scheme.primary,
                          Color.lerp(
                                scheme.primary,
                                EmvoColors.accentCyan,
                                0.25,
                              ) ??
                              scheme.primary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: isTyping ? scheme.surfaceContainerHighest : null,
                boxShadow: isTyping
                    ? null
                    : [
                        BoxShadow(
                          color: scheme.primary.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: isTyping
                      ? null
                      : () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          onSend(controller.text);
                        },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.send_rounded,
                      color: isTyping
                          ? context.emvoOnSurface(0.35)
                          : scheme.onPrimary,
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

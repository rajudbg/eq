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
  final void Function(String) onSend;
  final bool isTyping;

  @override
  Widget build(BuildContext context) {
    final scheme = context.emvoScheme;
    final radius = BorderRadius.circular(22);

    return Material(
      color: scheme.surface,
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          EmvoDimensions.md,
          EmvoDimensions.sm,
          EmvoDimensions.md,
          EmvoDimensions.sm + MediaQuery.paddingOf(context).bottom * 0.25,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Share what’s on your mind…',
                  hintStyle: TextStyle(
                    color: context.emvoOnSurface(0.45),
                  ),
                  filled: true,
                  fillColor: scheme.surfaceContainerHighest.withValues(
                    alpha: 0.85,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: radius,
                    borderSide: BorderSide(
                      color: scheme.outline.withValues(alpha: 0.28),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: radius,
                    borderSide: BorderSide(
                      color: scheme.outline.withValues(alpha: 0.22),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: radius,
                    borderSide: BorderSide(
                      color: scheme.primary.withValues(alpha: 0.65),
                      width: 1.5,
                    ),
                  ),
                ),
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                onSubmitted: isTyping
                    ? null
                    : (value) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        onSend(value);
                      },
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
                          color: scheme.primary.withValues(alpha: 0.28),
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
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.send_rounded,
                      size: 22,
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

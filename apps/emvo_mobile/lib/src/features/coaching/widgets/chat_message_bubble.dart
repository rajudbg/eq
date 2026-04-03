import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:emvo_ui/emvo_ui.dart';
import 'package:emvo_core/emvo_core.dart';

import 'coach_message_markdown.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    this.animate = false,
  });

  final Message message;
  final bool animate;

  static String _sanitizeUserPlain(String raw) {
    if (raw.isEmpty) return raw;
    final buf = StringBuffer();
    for (final r in raw.runes) {
      if (r != 0) buf.writeCharCode(r);
    }
    return buf
        .toString()
        .replaceAll(RegExp(r'<[^>]{0,800}>', multiLine: true), '')
        .trimRight();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.emvoScheme;
    final isUser = message.sender == MessageSender.user;
    final isCoach = message.sender == MessageSender.coach;

    final bubble = Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isCoach) ...[
              _CoachAvatar(),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: isCoach
                  ? _CoachMessageCard(
                      textColor: scheme.onSurface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CoachMessageHeader(color: scheme.onSurface),
                          const SizedBox(height: 10),
                          CoachMarkdownView(
                            data: message.content,
                            textColor: scheme.onSurface,
                          ),
                        ],
                      ),
                    )
                  : _UserMessageCard(
                      scheme: scheme,
                      child: SelectableText(
                        _sanitizeUserPlain(message.content),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onPrimary,
                              height: 1.45,
                              fontSize: (Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.fontSize ??
                                      14) *
                                  1.02,
                            ),
                      ),
                    ),
            ),
            if (isUser) ...[
              const SizedBox(width: 10),
              _UserAvatar(scheme: scheme),
            ],
          ],
        ),
      ),
    );

    if (!animate) return bubble;
    return bubble
        .animate()
        .fadeIn(duration: EmvoAnimations.normal, curve: EmvoAnimations.standard)
        .slideY(
          begin: 0.06,
          duration: EmvoAnimations.normal,
          curve: EmvoAnimations.decelerate,
        );
  }
}

class _CoachMessageHeader extends StatelessWidget {
  const _CoachMessageHeader({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            gradient: EmvoColors.brandGradient,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: EmvoColors.primary.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            size: 14,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'EMVO COACH',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color.withValues(alpha: 0.55),
                fontWeight: FontWeight.w800,
                letterSpacing: 1.15,
                fontSize: 10,
              ),
        ),
      ],
    );
  }
}

class _CoachMessageCard extends StatelessWidget {
  const _CoachMessageCard({
    required this.textColor,
    required this.child,
  });

  final Color textColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final innerFill = Color.alphaBlend(
      EmvoColors.primary.withValues(alpha: 0.06),
      scheme.surface,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: EmvoColors.brandGradient,
        boxShadow: [
          BoxShadow(
            color: EmvoColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.6),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.5),
            color: innerFill,
            border: Border.all(
              color: scheme.outline.withValues(alpha: 0.12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: textColor),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _UserMessageCard extends StatelessWidget {
  const _UserMessageCard({
    required this.scheme,
    required this.child,
  });

  final ColorScheme scheme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, EmvoColors.brandPurple, 0.22)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(6),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: child,
      ),
    );
  }
}

class _CoachAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: EmvoColors.brandGradient,
        boxShadow: [
          BoxShadow(
            color: EmvoColors.primary.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: const Center(
        child: Text(
          'E',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 15,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        shape: BoxShape.circle,
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Icon(
        Icons.person_rounded,
        size: 20,
        color: context.emvoOnSurface(0.55),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:emvo_ui/emvo_ui.dart';
import 'package:emvo_core/emvo_core.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    this.animate = false,
  });

  final Message message;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    final isCoach = message.sender == MessageSender.coach;

    final bubble = Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isCoach) _buildAvatar(context),
            if (isCoach) const SizedBox(width: 8),
            Flexible(
              child: GlassContainer(
                color: isUser
                    ? EmvoColors.primary.withValues(alpha: 0.9)
                    : EmvoColors.glassWhite,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  message.content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isUser ? Colors.white : EmvoColors.onBackground,
                      ),
                ),
              ),
            ),
            if (isUser) const SizedBox(width: 8),
            if (isUser) _buildUserAvatar(context),
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

  Widget _buildAvatar(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: EmvoColors.primaryGradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'E',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: EmvoColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.person,
        size: 20,
        color: EmvoColors.onBackground.withValues(alpha: 0.6),
      ),
    );
  }
}

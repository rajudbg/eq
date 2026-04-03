import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:emvo_core/emvo_core.dart';
import 'package:emvo_ui/emvo_ui.dart';

import 'coaching_providers.dart';
import 'widgets/chat_message_bubble.dart';
import 'widgets/coaching_input.dart';
import 'widgets/suggested_prompts.dart';

class CoachingScreen extends ConsumerStatefulWidget {
  const CoachingScreen({super.key});

  @override
  ConsumerState<CoachingScreen> createState() => _CoachingScreenState();
}

class _CoachingScreenState extends ConsumerState<CoachingScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Defer: updating providers in initState can run while the tree is still
    // building and triggers Riverpod's "modify provider while building" error.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(mascotProvider.notifier).listen();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: EmvoAnimations.normal,
        curve: EmvoAnimations.standard,
      );
    }
  }

  Future<void> _sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    if (_isAtMessageLimit(ref)) {
      return;
    }

    setState(() => _isTyping = true);
    _textController.clear();
    ref.read(mascotProvider.notifier).think();

    try {
      final sendMessage = ref.read(sendMessageProvider);
      await sendMessage(content.trim());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTyping = false);
        ref.read(mascotProvider.notifier).listen();
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    }
  }

  bool _isAtMessageLimit(WidgetRef ref) {
    final subscription = ref.read(currentSubscriptionProvider).valueOrNull;
    final session = ref.read(coachingSessionProvider).valueOrNull;
    final messageCount = session?.messages
            .where((m) => m.sender == MessageSender.user)
            .length ??
        0;
    final maxMessages =
        subscription?.currentTier.maxCoachingMessagesPerDay ?? 5;
    if (maxMessages == -1) return false;
    return messageCount >= maxMessages;
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(coachingSessionProvider);
    final subscriptionAsync = ref.watch(currentSubscriptionProvider);
    final subscription = subscriptionAsync.valueOrNull;
    final session = sessionAsync.valueOrNull;

    final messageCount = session?.messages
            .where((m) => m.sender == MessageSender.user)
            .length ??
        0;
    final maxMessages =
        subscription?.currentTier.maxCoachingMessagesPerDay ?? 5;
    final remainingMessages = maxMessages - messageCount;
    final hasReachedLimit =
        remainingMessages <= 0 && maxMessages != -1;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            const Text('Coach'),
            Text(
              'AI-Powered EQ Guidance',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: EmvoColors.onBackground.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const EmvoMascotEmoji(size: 40),
                const SizedBox(width: 12),
                Flexible(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final mascotState = ref.watch(mascotProvider);
                      return Text(
                        _getMascotStatus(mascotState, _isTyping),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: EmvoColors.onBackground.withValues(
                                alpha: 0.6,
                              ),
                            ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: sessionAsync.when(
              data: (session) => _buildMessageList(session),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(
                child: Padding(
                  padding: EmvoDimensions.paddingScreen,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: EmvoColors.error,
                      ),
                      const SizedBox(height: 16),
                      const Text('Failed to load conversation'),
                      const SizedBox(height: 16),
                      AnimatedButton(
                        text: 'Retry',
                        onPressed: () =>
                            ref.invalidate(coachingSessionProvider),
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Consumer(
            builder: (context, ref, _) {
              final s = ref.watch(coachingSessionProvider).valueOrNull;
              if (s == null || s.messages.length > 2 || hasReachedLimit) {
                return const SizedBox.shrink();
              }
              return SuggestedPrompts(
                onPromptSelected: _sendMessage,
              );
            },
          ),
          if (hasReachedLimit) ...[
            GlassContainer(
              color: EmvoColors.secondary.withValues(alpha: 0.1),
              margin: const EdgeInsets.all(EmvoDimensions.md),
              padding: const EdgeInsets.all(EmvoDimensions.md),
              child: Column(
                children: [
                  const Text(
                    'You have reached your daily message limit',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Upgrade to Premium for unlimited coaching',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  AnimatedButton(
                    text: 'Upgrade to Premium',
                    onPressed: () => context.push('/paywall'),
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ] else ...[
            CoachingInput(
              controller: _textController,
              onSend: _sendMessage,
              isTyping: _isTyping,
            ),
            if (maxMessages != -1)
              Padding(
                padding: const EdgeInsets.only(bottom: EmvoDimensions.sm),
                child: Text(
                  '$remainingMessages messages remaining today',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color:
                            EmvoColors.onBackground.withValues(alpha: 0.5),
                      ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageList(CoachingSession session) {
    if (session.messages.isEmpty) {
      if (_isTyping) {
        return Center(
          child: Padding(
            padding: EmvoDimensions.paddingScreen,
            child: _buildTypingIndicator(),
          ),
        );
      }
      return Center(
        child: Padding(
          padding: EmvoDimensions.paddingScreen,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: EmvoColors.onBackground.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),
              Text(
                'Start a conversation',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Share how you are feeling or ask for EQ advice',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: EmvoColors.onBackground.withValues(alpha: 0.6),
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(EmvoDimensions.md),
      itemCount: session.messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == session.messages.length) {
          return _buildTypingIndicator();
        }

        final message = session.messages[index];
        final isLast = index == session.messages.length - 1;

        return Padding(
          padding: const EdgeInsets.only(bottom: EmvoDimensions.sm),
          child: ChatMessageBubble(
            message: message,
            animate: isLast,
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: EmvoColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: EmvoColors.primary.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            _buildDot(1),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: EmvoColors.primary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .scale(
          duration: const Duration(milliseconds: 600),
          delay: Duration(milliseconds: index * 100),
        );
  }

  String _getMascotStatus(MascotState state, bool isTyping) {
    if (isTyping || state == MascotState.thinking) {
      return 'Coach is typing…';
    }
    return switch (state) {
      MascotState.listening => 'Listening…',
      MascotState.thinking => 'Coach is typing…',
      MascotState.happy => 'Here to help',
      MascotState.concerned => 'Here with you',
      MascotState.celebrating => 'Great momentum',
      MascotState.encouraging => 'You’ve got this',
      MascotState.surprised => 'Interesting point',
      MascotState.idle => 'Here to help',
    };
  }
}

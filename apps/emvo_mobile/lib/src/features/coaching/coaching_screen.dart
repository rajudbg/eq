import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_assessment/emvo_assessment.dart';
import 'package:emvo_core/emvo_core.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../../providers/assessment_providers.dart';
import '../../routing/routing.dart';
import '../assessment/assessment_ai_bridge.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      ref.read(mascotProvider.notifier).listen();
      // EQ snapshot was only applied from Results → "Start Coaching"; hydrate from
      // persisted latest so the Coach tab always has scores when available.
      try {
        final inMemory = ref.read(assessmentNotifierProvider).result;
        final persisted = await ref.read(latestResultProvider.future);
        final result = inMemory ?? persisted;
        if (!mounted || result == null) return;
        ref.read(coachingRepositoryProvider).applyCoachingContext(
              assessmentToCoachingContext(result),
            );
        // Session is re-read from the repo on each send/suggest; invalidating it
        // here only forced a full-screen loading spinner. Refresh starters only.
        ref.invalidate(suggestedPromptsProvider);
      } catch (_) {}
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
    FocusManager.instance.primaryFocus?.unfocus();
    if (_isAtMessageLimit(ref)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Daily message limit reached. Upgrade for more.'),
          ),
        );
      }
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
    final messageCount =
        session?.messages.where((m) => m.sender == MessageSender.user).length ??
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
    final repo = ref.watch(coachingRepositoryProvider);
    final session = sessionAsync.valueOrNull ?? repo.cachedActiveSession;

    final messageCount =
        session?.messages.where((m) => m.sender == MessageSender.user).length ??
            0;
    final maxMessages =
        subscription?.currentTier.maxCoachingMessagesPerDay ?? 5;
    final remainingMessages = maxMessages - messageCount;
    final hasReachedLimit = remainingMessages <= 0 && maxMessages != -1;

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                EmvoColors.primary.withValues(alpha: 0.08),
                EmvoColors.tertiary.withValues(alpha: 0.06),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bubble_chart_rounded,
                  size: 20,
                  color: EmvoColors.primary.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 8),
                const Text('Coach'),
              ],
            ),
            Text(
              'EQ guidance · not therapy',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: context.emvoOnSurface(0.58),
                    letterSpacing: 0.2,
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
      body: EmvoAmbientBackground(
        child: SizedBox.expand(
          child: Column(
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
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: context.emvoOnSurface(0.62),
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
                  skipLoadingOnReload: true,
                  skipLoadingOnRefresh: true,
                  data: (session) => _buildMessageList(session),
                  loading: () {
                    final cached = repo.cachedActiveSession;
                    if (cached != null) {
                      return _buildMessageList(cached);
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
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
                  final promptsAsync = ref.watch(suggestedPromptsProvider);
                  return promptsAsync.when(
                    skipLoadingOnReload: true,
                    data: (prompts) => SuggestedPrompts(
                      prompts: prompts,
                      onPromptSelected: _sendMessage,
                    ),
                    loading: () => SuggestedPrompts(
                      prompts: promptsAsync.hasValue
                          ? promptsAsync.requireValue
                          : kDefaultSuggestedPrompts,
                      onPromptSelected: _sendMessage,
                    ),
                    error: (_, __) => SuggestedPrompts(
                      prompts: kDefaultSuggestedPrompts,
                      onPromptSelected: _sendMessage,
                    ),
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
                      Text(
                        'You have reached your daily message limit',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.emvoScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upgrade to Premium for unlimited coaching',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.emvoOnSurface(0.78),
                            ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedButton(
                        text: 'Upgrade to Premium',
                        onPressed: () => context.push(Routes.paywall),
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
                            color: context.emvoOnSurface(0.52),
                          ),
                    ),
                  ),
              ],
            ],
          ),
        ),
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
                color: context.emvoOnSurface(0.22),
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
                      color: context.emvoOnSurface(0.62),
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
    final scheme = Theme.of(context).colorScheme;
    final inner = scheme.surface.withValues(alpha: 0.92);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: EmvoColors.brandGradient,
          boxShadow: [
            BoxShadow(
              color: EmvoColors.primary.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(1.5),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: inner,
            borderRadius: BorderRadius.circular(18.5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                _buildDot(1),
                _buildDot(2),
              ],
            ),
          ),
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

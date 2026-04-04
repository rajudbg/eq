import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_assessment/emvo_assessment.dart';
import 'package:emvo_core/emvo_core.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../../providers/app_state_providers.dart';
import '../../providers/assessment_providers.dart';
import '../../routing/routing.dart';

class AssessmentScreen extends ConsumerStatefulWidget {
  const AssessmentScreen({super.key});

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen> {
  /// True after [Previous] so we stay on the question until [Continue] (or change answer).
  bool _editingAfterBack = false;

  /// Prevents double-taps while a transition animation / delay runs.
  bool _interactionBusy = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration.zero, () {
      ref.read(onboardingProvider.notifier).completeOnboarding();
      ref.read(assessmentNotifierProvider.notifier).loadQuestions();
      ref.read(mascotProvider.notifier).listen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assessmentNotifierProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final history =
        ref.watch(assessmentHistoryProvider).valueOrNull ?? const [];
    final hasCompletedAssessment = history.isNotEmpty;
    final shouldGateAssessment = !isPremium &&
        hasCompletedAssessment &&
        state.status != AssessmentStatus.inProgress;

    if (shouldGateAssessment) {
      return Scaffold(
        appBar: AppBar(title: const Text('Assessment')),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EmvoDimensions.paddingScreen,
              child: GlassContainer(
                padding: const EdgeInsets.all(EmvoDimensions.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 48,
                      color: EmvoColors.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Unlimited Assessments',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You have used your free assessment. Upgrade to take unlimited assessments and track deeper growth over time.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    AnimatedButton(
                      text: 'Upgrade to Premium',
                      onPressed: () =>
                          context.push('/paywall?source=assessment'),
                      width: double.infinity,
                    ),
                    const SizedBox(height: 8),
                    AnimatedButton(
                      text: 'Back to Dashboard',
                      onPressed: () => context.go('/home'),
                      isSecondary: true,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: state.status == AssessmentStatus.inProgress
            ? Text(
                'Question ${state.currentQuestionIndex + 1} of ${state.questions.length}',
              )
            : const Text('Assessment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Leave assessment',
          onPressed: () async {
            ref.read(assessmentNotifierProvider.notifier).reset();
            if (!ref.read(assessmentCompletionProvider)) {
              await ref.read(onboardingProvider.notifier).reset();
            }
            if (!context.mounted) return;
            context.go(Routes.welcome);
          },
        ),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(AssessmentState state) {
    switch (state.status) {
      case AssessmentStatus.initial:
      case AssessmentStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case AssessmentStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: EmvoColors.error,
              ),
              const SizedBox(height: 16),
              Text(state.errorMessage ?? 'Something went wrong'),
              const SizedBox(height: 16),
              AnimatedButton(
                text: 'Try Again',
                onPressed: () => ref
                    .read(assessmentNotifierProvider.notifier)
                    .loadQuestions(),
              ),
            ],
          ),
        );

      case AssessmentStatus.inProgress:
        return _buildQuestion(state);

      case AssessmentStatus.completed:
        return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildQuestion(AssessmentState state) {
    final question = state.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    final selectedOptionId = state.answers[question.id];

    return SafeArea(
      child: Padding(
        padding: EmvoDimensions.paddingScreen,
        child: Column(
          children: [
            AnimatedProgressBar(
              progress: state.progress,
              showPercentage: true,
            ),
            const SizedBox(height: 4),
            Text(
              'Typical session is about 8 minutes — you are almost there.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: context.emvoOnSurface(0.55),
                    height: 1.3,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Focus: ${question.primaryDimension.displayName}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: EmvoColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            Text(
              question.primaryDimension.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.emvoOnSurface(0.68),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, _) {
                final mascotState = ref.watch(mascotProvider);
                return Column(
                  children: [
                    AnimatedSwitcher(
                      duration: EmvoAnimations.fast,
                      switchInCurve: EmvoAnimations.standard,
                      switchOutCurve: EmvoAnimations.standard,
                      child: EmvoMascotEmoji(
                        key: ValueKey<MascotState>(mascotState),
                        size: 88,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _mascotFeedback(mascotState),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: context.emvoOnSurface(0.78),
                          ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            _ScenarioPromptCard(
              key: ValueKey(question.id),
              scenario: question.scenario,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  Icons.radio_button_checked_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Choose your response',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.15,
                          color: context.emvoOnSurface(1),
                          height: 1.25,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Tap the option that best matches what you would do.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.emvoOnSurface(0.82),
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: question.options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final option = question.options[index];
                  final isSelected = selectedOptionId == option.id;
                  final letter = index < 26
                      ? String.fromCharCode(65 + index)
                      : '${index + 1}';

                  return AnimatedOptionCard(
                    badgeLabel: letter,
                    text: option.text,
                    isSelected: isSelected,
                    onTap: _interactionBusy
                        ? () {}
                        : () => _onOptionSelected(question, option),
                  )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: index * 100),
                      )
                      .slideX(begin: 0.1);
                },
              ),
            ),
            if (_editingAfterBack && selectedOptionId != null) ...[
              const SizedBox(height: 16),
              AnimatedButton(
                text: 'Continue',
                onPressed: _interactionBusy
                    ? () {}
                    : () {
                        _onContinueFromReview();
                      },
                width: double.infinity,
              ),
            ],
            if (!state.isFirstQuestion)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: AnimatedButton(
                  text: 'Previous',
                  onPressed: _interactionBusy
                      ? () {}
                      : () {
                          ref
                              .read(assessmentNotifierProvider.notifier)
                              .previousQuestion();
                          setState(() => _editingAfterBack = true);
                        },
                  isSecondary: true,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _advanceAfterAnswer() async {
    final notifier = ref.read(assessmentNotifierProvider.notifier);
    final current = ref.read(assessmentNotifierProvider);

    if (current.isLastQuestion) {
      await notifier.calculateResult();
      if (!mounted) return;
      await ref
          .read(assessmentCompletionProvider.notifier)
          .completeAssessment();
      if (!mounted) return;
      context.go('/results');
    } else {
      notifier.nextQuestion();
      ref.read(mascotProvider.notifier).listen();
    }
    if (mounted) setState(() => _editingAfterBack = false);
  }

  Future<void> _onContinueFromReview() async {
    if (_interactionBusy || !_editingAfterBack) return;
    setState(() => _interactionBusy = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 280));
      if (!mounted) return;
      await _advanceAfterAnswer();
    } finally {
      if (mounted) setState(() => _interactionBusy = false);
    }
  }

  String _mascotFeedback(MascotState state) {
    return switch (state) {
      MascotState.celebrating =>
        'High-scoring choice on this scenario’s rubric — nice work.',
      MascotState.concerned =>
        'Lower rubric score — a pause or reframe often helps next time.',
      MascotState.encouraging =>
        'Middle of the range — keep building consistency.',
      MascotState.happy => 'Aligned with a constructive path forward.',
      MascotState.listening => 'Ready for the next scenario…',
      MascotState.thinking => 'Take your time to choose.',
      MascotState.surprised => 'Interesting angle.',
      MascotState.idle => 'Your companion is here with you.',
    };
  }

  /// Maps option score totals to 1–5 so [MascotNotifier.reactToAnswer] reflects rubric quality.
  int _rubricQualityScore(AnswerOption option, Question q) {
    final sum = option.scores.values.fold<int>(0, (a, b) => a + b);
    final maxSum = q.options
        .map((o) => o.scores.values.fold<int>(0, (a, b) => a + b))
        .fold<int>(0, math.max);
    if (maxSum <= 0) return 3;
    return (sum / maxSum * 5).round().clamp(1, 5);
  }

  Future<void> _onOptionSelected(Question question, AnswerOption option) async {
    if (_interactionBusy) return;

    final reviewing = _editingAfterBack;

    setState(() => _interactionBusy = true);
    try {
      ref.read(assessmentNotifierProvider.notifier).answerQuestion(option.id);

      ref.read(mascotProvider.notifier).reactToAnswer(
            _rubricQualityScore(option, question),
          );

      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;

      if (reviewing) {
        ref.read(mascotProvider.notifier).listen();
        return;
      }

      await _advanceAfterAnswer();
    } finally {
      if (mounted) setState(() => _interactionBusy = false);
    }
  }
}

/// Visually distinct from [AnimatedOptionCard]: reads as the situational prompt, not a choice.
class _ScenarioPromptCard extends StatelessWidget {
  const _ScenarioPromptCard({
    super.key,
    required this.scenario,
  });

  final String scenario;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            EmvoColors.primary.withValues(alpha: 0.14),
            scheme.surfaceContainerHighest.withValues(alpha: 0.35),
          ],
        ),
        border: Border.all(
          color: EmvoColors.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: EmvoColors.primary.withValues(alpha: 0.1),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.5),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                decoration: const BoxDecoration(
                  gradient: EmvoColors.primaryGradient,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_stories_rounded,
                            size: 22,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SCENARIO',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.35,
                                  color: scheme.primary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TypewriterText(
                        key: ValueKey(scenario),
                        text: scenario,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              height: 1.48,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface.withValues(alpha: 0.94),
                            ),
                        delay: Duration.zero,
                      ),
                    ],
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

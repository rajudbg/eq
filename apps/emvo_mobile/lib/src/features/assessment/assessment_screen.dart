import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:emvo_assessment/emvo_assessment.dart';
import 'package:emvo_core/emvo_core.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../../providers/assessment_providers.dart';

class AssessmentScreen extends ConsumerStatefulWidget {
  const AssessmentScreen({super.key});

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration.zero, () {
      ref.read(assessmentNotifierProvider.notifier).loadQuestions();
      ref.read(mascotProvider.notifier).listen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assessmentNotifierProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final history = ref.watch(assessmentHistoryProvider).valueOrNull ?? const [];
    final hasCompletedAssessment = history.isNotEmpty;
    final shouldGateAssessment =
        !isPremium &&
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
                      onPressed: () => context.push('/paywall?source=assessment'),
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
          onPressed: () {
            ref.read(assessmentNotifierProvider.notifier).reset();
            context.go('/welcome');
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
              const Icon(Icons.error_outline, size: 64, color: EmvoColors.error),
              const SizedBox(height: 16),
              Text(state.errorMessage ?? 'Something went wrong'),
              const SizedBox(height: 16),
              AnimatedButton(
                text: 'Try Again',
                onPressed: () =>
                    ref.read(assessmentNotifierProvider.notifier).loadQuestions(),
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
            AnimatedProgressBar(progress: state.progress, showPercentage: false),
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
                    color: EmvoColors.onBackground.withValues(
                      alpha: (EmvoColors.onBackground.a * 0.65)
                          .clamp(0.0, 1.0),
                    ),
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
                            color: EmvoColors.onBackground.withValues(
                              alpha: (EmvoColors.onBackground.a * 0.75)
                                  .clamp(0.0, 1.0),
                            ),
                          ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.all(EmvoDimensions.lg),
              child: TypewriterText(
                key: ValueKey(question.id),
                text: question.scenario,
                style: Theme.of(context).textTheme.bodyLarge,
                delay: Duration.zero,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: question.options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final option = question.options[index];
                  final isSelected = selectedOptionId == option.id;

                  return AnimatedOptionCard(
                    text: option.text,
                    isSelected: isSelected,
                    onTap: selectedOptionId == null
                        ? () => _onOptionSelected(question, option)
                        : () {},
                  )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: index * 100),
                      )
                      .slideX(begin: 0.1);
                },
              ),
            ),
            if (!state.isFirstQuestion)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: AnimatedButton(
                  text: 'Previous',
                  onPressed: () =>
                      ref.read(assessmentNotifierProvider.notifier).previousQuestion(),
                  isSecondary: true,
                ),
              ),
          ],
        ),
      ),
    );
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
    ref.read(assessmentNotifierProvider.notifier).answerQuestion(option.id);

    ref.read(mascotProvider.notifier).reactToAnswer(
          _rubricQualityScore(option, question),
        );

    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final notifier = ref.read(assessmentNotifierProvider.notifier);
    final current = ref.read(assessmentNotifierProvider);

    if (current.isLastQuestion) {
      await notifier.calculateResult();
      if (!mounted) return;
      context.go('/results');
    } else {
      notifier.nextQuestion();
      ref.read(mascotProvider.notifier).listen();
    }
  }
}

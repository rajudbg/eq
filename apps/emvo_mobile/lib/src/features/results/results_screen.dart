import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_assessment/emvo_assessment.dart';
import 'package:emvo_core/emvo_core.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../../providers/app_state_providers.dart';
import '../../providers/assessment_providers.dart';
import '../../retention/action_plan_unlock.dart';
import '../../widgets/eq_action_plan_widgets.dart';
import '../../routing/routing.dart';
import '../assessment/assessment_ai_bridge.dart';
import '../assessment/assessment_ai_providers.dart';
import 'results_account_nudge.dart';
import 'results_notification_nudge.dart';
import '../../widgets/eq_profile_share_card.dart';
import 'eq_benchmarks.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final rid = GoRouterState.of(context).uri.queryParameters['rid'];
      if (rid != null && rid.isNotEmpty) {
        return;
      }

      final r = ref.read(assessmentNotifierProvider).result;
      if (r != null) {
        await ref
            .read(assessmentCompletionProvider.notifier)
            .completeAssessment();
      }
      if (mounted) {
        ref.invalidate(assessmentNarrativeProvider);
        ref.read(mascotProvider.notifier).celebrate();
      }
      if (!mounted || r == null) return;
      if (!kIsWeb) {
        await Future<void>.delayed(const Duration(milliseconds: 2200));
        if (!mounted) return;
        await ResultsAccountNudge.maybeShow(context, ref);
        if (!mounted) return;
        await Future<void>.delayed(const Duration(milliseconds: 550));
        if (!mounted) return;
        await ResultsNotificationNudge.maybeShow(context, ref);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pastId = GoRouterState.of(context).uri.queryParameters['rid'];
    final viewingPast = pastId != null && pastId.isNotEmpty;

    if (viewingPast) {
      final historyAsync = ref.watch(assessmentHistoryProvider);
      return historyAsync.when(
        loading: () => Scaffold(
          body: EmvoAmbientBackground(
            child: SafeArea(
              child: Center(
                child: EmvoLoadingPanel(
                  message: 'Loading results…',
                ),
              ),
            ),
          ),
        ),
        error: (_, __) => Scaffold(
          body: Center(
            child: Padding(
              padding: EmvoDimensions.paddingScreen,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Could not load assessment history.',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  AnimatedButton(
                    text: 'Back',
                    onPressed: () {
                      if (GoRouter.of(context).canPop()) {
                        context.pop();
                      } else {
                        context.go(Routes.progress);
                      }
                    },
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ),
        ),
        data: (history) {
          AssessmentResult? found;
          for (final r in history) {
            if (r.id == pastId) {
              found = r;
              break;
            }
          }
          if (found == null) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: EmvoDimensions.paddingScreen,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'That assessment could not be found.',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      AnimatedButton(
                        text: 'Back to Progress',
                        onPressed: () {
                          if (GoRouter.of(context).canPop()) {
                            context.pop();
                          } else {
                            context.go(Routes.progress);
                          }
                        },
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return _buildResultsScaffold(
            context,
            found,
            narrativeResultId: pastId,
          );
        },
      );
    }

    final assessmentState = ref.watch(assessmentNotifierProvider);
    final result = assessmentState.result;

    if (result == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: EmvoDimensions.paddingScreen,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No assessment results yet.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                AnimatedButton(
                  text: 'Back to home',
                  onPressed: () => context.go(Routes.welcome),
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _buildResultsScaffold(
      context,
      result,
      narrativeResultId: null,
    );
  }

  Widget _buildResultsScaffold(
    BuildContext context,
    AssessmentResult result, {
    required String? narrativeResultId,
  }) {
    final fromHistory = narrativeResultId != null;

    return Scaffold(
      body: EmvoAmbientBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: fromHistory ? 228 : 200,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  // Keep short — long titles stack on the hero and overlap the score.
                  expandedTitleScale: 1.0,
                  titlePadding: const EdgeInsetsDirectional.only(
                    start: 16,
                    bottom: 14,
                  ),
                  centerTitle: false,
                  title: const Text(
                    'Your EQ Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      shadows: [
                        Shadow(
                          color: Color(0x66000000),
                          blurRadius: 8,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: EmvoColors.primaryGradient,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 8,
                              bottom: 52,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    result.overallScore.toInt().toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          height: 1.05,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Overall EQ Score',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.white
                                              .withValues(alpha: 0.92),
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  if (fromHistory) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Completed ${_fmtShortDate(result.completedAt)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: Colors.white
                                                .withValues(alpha: 0.72),
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.2,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EmvoDimensions.paddingScreen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Center(
                        child: EqRadarChart(
                          style: EqRadarChartStyle.compact,
                          chartHeight: 280,
                          showMidpointBaseline: true,
                          values: [
                            result.dimensionScores[EQDimension.selfAwareness] ??
                                0,
                            result.dimensionScores[EQDimension.selfRegulation] ??
                                0,
                            result.dimensionScores[EQDimension.empathy] ?? 0,
                            result.dimensionScores[EQDimension.socialSkills] ??
                                0,
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _BenchmarkSection(result: result),
                      const SizedBox(height: 28),
                      Text(
                        'Your Strengths & Growth Areas',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ...result.insights.map(
                        (insight) => _DimensionInsightCard(insight: insight),
                      ),
                      const SizedBox(height: 28),
                      Consumer(
                        builder: (context, ref, _) {
                          final async = narrativeResultId != null
                              ? ref.watch(
                                  assessmentNarrativeByResultIdProvider(
                                    narrativeResultId,
                                  ),
                                )
                              : ref.watch(assessmentNarrativeProvider);
                          void invalidateNarrative() {
                            if (narrativeResultId != null) {
                              ref.invalidate(
                                assessmentNarrativeByResultIdProvider(
                                  narrativeResultId,
                                ),
                              );
                            } else {
                              ref.invalidate(assessmentNarrativeProvider);
                            }
                          }

                          return async.when(
                            skipLoadingOnReload: true,
                            loading: () => const _EqAnalysisLoadingCard(),
                            error: (_, __) => Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'We could not load your written analysis. You can retry or use the scores and plan below.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.8),
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: invalidateNarrative,
                                    child: const Text('Retry analysis'),
                                  ),
                                ],
                              ),
                            ),
                            data: (n) {
                              if (n == null) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Written analysis did not load. Tap retry—your scores and plan below are still valid.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.72),
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: invalidateNarrative,
                                        child: const Text('Retry analysis'),
                                      ),
                                      const SizedBox(height: 20),
                                      EqWeeklyActionPlanCard(
                                        resultId: result.id,
                                        actionTexts: result.recommendations,
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _AiCoachReadSection(narrative: n),
                                    EqWeeklyActionPlanCard(
                                      resultId: result.id,
                                      actionTexts: n.actions,
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Your Personalized Plan',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ...result.recommendations.asMap().entries.map(
                            (entry) => _RecommendationCard(
                              index: entry.key + 1,
                              text: entry.value,
                            ),
                          ),
                      const SizedBox(height: 24),
                      GlassContainer(
                        padding: const EdgeInsets.all(EmvoDimensions.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.event_repeat,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Your growth checkpoint',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Retake your EQ assessment on or after '
                              '${_fmtDate(assessmentRetakeEligibleAt(result))} '
                              '(${_daysUntilRetakeLabel(result)}) to see how your scores move.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    height: 1.4,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.78),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      AnimatedButton(
                        text: 'Start Coaching',
                        onPressed: () {
                          final repo = ref.read(coachingRepositoryProvider);
                          repo.applyCoachingContext(
                            assessmentToCoachingContext(result),
                          );
                          context.go(Routes.coach);
                        },
                        width: double.infinity,
                      ),
                      const SizedBox(height: 12),
                      AnimatedButton(
                        text: 'Go to Dashboard',
                        onPressed: () => context.go(Routes.home),
                        isSecondary: true,
                        width: double.infinity,
                      ),
                      if (!kIsWeb) ...[
                        const SizedBox(height: 20),
                        _ShareProfileCta(result: result),
                      ],
                      const SizedBox(height: 32),
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

  String _fmtShortDate(DateTime d) {
    final local = d.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }

  String _fmtDate(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  String _daysUntilRetakeLabel(AssessmentResult result) {
    final eligible = assessmentRetakeEligibleAt(result);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final el = DateTime(eligible.year, eligible.month, eligible.day);
    final d = el.difference(today).inDays;
    if (d <= 0) return 'today — mark your calendar';
    if (d == 1) return '1 day';
    return '$d days';
  }

}

/// Shown while [assessmentNarrativeProvider] loads — reads as “AI composing,” not a generic bar.
class _EqAnalysisLoadingCard extends StatelessWidget {
  const _EqAnalysisLoadingCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.72);
    final track = scheme.surfaceContainerHighest.withValues(alpha: 0.75);

    Widget skeletonLine(double widthFactor) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: widthFactor,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: track,
              ),
            ).animate(onPlay: (c) => c.repeat()).shimmer(
                  delay: (widthFactor * 180).round().ms,
                  duration: 1600.ms,
                  color: scheme.primary.withValues(alpha: 0.22),
                ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: GlassContainer(
        padding: const EdgeInsets.all(EmvoDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: scheme.primary,
                      size: 26,
                    ),
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                      begin: const Offset(0.94, 0.94),
                      end: const Offset(1.05, 1.05),
                      duration: 1100.ms,
                      curve: Curves.easeInOut,
                    ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generating your EQ analysis',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.1,
                                ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'AI is interpreting your scores and growth areas to write a personalized summary and three habits for this week. This usually takes a few seconds.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: muted,
                              height: 1.45,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 5,
                backgroundColor: track,
                color: scheme.primary.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Preview',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: muted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
            ),
            const SizedBox(height: 10),
            skeletonLine(1),
            skeletonLine(0.92),
            skeletonLine(0.62),
          ],
        ),
      ),
    );
  }
}

class _AiCoachReadSection extends StatelessWidget {
  const _AiCoachReadSection({required this.narrative});

  final AssessmentAiNarrative narrative;

  static String _plain(String s) => s.replaceAll('**', '');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final paragraphs = _plain(narrative.narrative)
        .split('\n\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 22,
              color: scheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your EQ analysis',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'What your scores mean—and why they matter—for you.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.65),
                          height: 1.35,
                        ),
                  ),
                ],
              ),
            ),
            if (narrative.usedLlm)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'AI-personalized',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: scheme.outline.withValues(alpha: 0.35),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Built-in summary',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
          ],
        ),
        if (!narrative.usedLlm && kIsWeb) ...[
          const SizedBox(height: 8),
          Text(
            'The web preview uses this written summary. For live AI-personalized copy from your scores, run the app on a phone or desktop target (the browser blocks direct model calls).',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                  height: 1.4,
                ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          _plain(narrative.headline),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
        ),
        const SizedBox(height: 12),
        ...paragraphs.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              p,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.45,
                    color: scheme.onSurface.withValues(alpha: 0.92),
                  ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your three habits for this week are in the action plan below.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.62),
                height: 1.35,
              ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _DimensionInsightCard extends StatelessWidget {
  const _DimensionInsightCard({required this.insight});

  final DimensionInsight insight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _getScoreColor(insight.score);

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(EmvoDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    insight.score.toInt().toString(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.dimension.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        insight.level,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                _getIconForDimension(insight.dimension),
                color: color,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.88),
                  height: 1.45,
                ),
          ),
          if (insight.growthAreas.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: insight.growthAreas
                  .map(
                    (area) => Chip(
                      label: Text(
                        area,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      backgroundColor: scheme.surfaceContainerHighest
                          .withValues(alpha: 0.85),
                      side: BorderSide(
                        color: scheme.outline.withValues(alpha: 0.35),
                      ),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return EmvoColors.success;
    if (score >= 60) return EmvoColors.primary;
    if (score >= 40) return EmvoColors.secondary;
    return EmvoColors.tertiary;
  }

  IconData _getIconForDimension(EQDimension dimension) {
    switch (dimension) {
      case EQDimension.selfAwareness:
        return Icons.self_improvement;
      case EQDimension.selfRegulation:
        return Icons.spa_outlined;
      case EQDimension.empathy:
        return Icons.favorite;
      case EQDimension.socialSkills:
        return Icons.people;
    }
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.index,
    required this.text,
  });

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(EmvoDimensions.md),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                index.toString(),
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.92),
                  ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: index * 100),
        )
        .slideX(begin: 0.1);
  }
}



class _BenchmarkSection extends StatelessWidget {
  const _BenchmarkSection({required this.result});

  final AssessmentResult result;

  @override
  Widget build(BuildContext context) {
    final benchmarks = EqBenchmarks(result);
    final scheme = Theme.of(context).colorScheme;
    final strongest = benchmarks.strongestBenchmark;

    return GlassContainer(
      padding: const EdgeInsets.all(EmvoDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.leaderboard_rounded, color: scheme.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                'Where You Stand',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Compared to general population EQ norms.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.55),
                  height: 1.3,
                ),
          ),
          const SizedBox(height: 16),

          // Overall badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scheme.primary.withValues(alpha: 0.12),
                  scheme.primary.withValues(alpha: 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(EmvoDimensions.radiusMd),
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.primary.withValues(alpha: 0.15),
                  ),
                  child: Center(
                    child: Text(
                      '${benchmarks.overall.percentile}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: scheme.primary,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        benchmarks.overall.label,
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Better than ${benchmarks.overall.percentile}% of people',
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color:
                                      scheme.onSurface.withValues(alpha: 0.65),
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Per-dimension chips
          ...benchmarks.dimensions.entries.map((entry) {
            final dim = entry.key;
            final bench = entry.value;
            final isStrongest = dim == strongest.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      dim.displayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor:
                                (bench.percentile / 100).clamp(0.0, 1.0),
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: isStrongest
                                    ? scheme.primary
                                    : scheme.primary.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    child: Text(
                      bench.label == 'Top ${100 - bench.percentile}%'
                          ? bench.label
                          : '${bench.percentile}%',
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isStrongest
                                ? scheme.primary
                                : scheme.onSurface.withValues(alpha: 0.7),
                          ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.04, duration: 350.ms);
  }
}

class _ShareProfileCta extends StatelessWidget {
  const _ShareProfileCta({required this.result});

  final AssessmentResult result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => shareEqProfileCard(context, result),
      child: GlassContainer(
        padding: const EdgeInsets.all(EmvoDimensions.md),
        color: scheme.primary.withValues(alpha: 0.06),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: EmvoColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.share_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share Your EQ Profile',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'A designed card with your scores, radar, and EQ superpower.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.6),
                          height: 1.3,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: scheme.primary.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }
}

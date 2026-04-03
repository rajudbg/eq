import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_assessment/emvo_assessment.dart';
import 'package:emvo_core/emvo_core.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../../providers/app_state_providers.dart';
import '../../routing/routing.dart';
import '../assessment/assessment_ai_bridge.dart';
import '../assessment/assessment_ai_providers.dart';
import '../subscription/widgets/premium_gate.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration.zero, () async {
      if (!mounted) return;
      final r = ref.read(assessmentNotifierProvider).result;
      if (r != null) {
        await ref
            .read(assessmentCompletionProvider.notifier)
            .completeAssessment();
      }
      if (mounted) {
        ref.read(mascotProvider.notifier).celebrate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      body: EmvoAmbientBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text('Your EQ Profile'),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: EmvoColors.primaryGradient,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Text(
                            result.overallScore.toInt().toString(),
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Overall EQ Score',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                          ),
                        ],
                      ),
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
                      const SizedBox(height: 24),
                      Center(
                        child: SizedBox(
                          height: 280,
                          child: _buildRadarChart(result),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Consumer(
                        builder: (context, ref, _) {
                          final async = ref.watch(assessmentNarrativeProvider);
                          return async.when(
                            loading: () => Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child:
                                    const LinearProgressIndicator(minHeight: 4),
                              ),
                            ),
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
                                    onPressed: () => ref.invalidate(
                                      assessmentNarrativeProvider,
                                    ),
                                    child: const Text('Retry analysis'),
                                  ),
                                ],
                              ),
                            ),
                            data: (n) {
                              if (n == null) return const SizedBox.shrink();
                              return _AiCoachReadSection(narrative: n);
                            },
                          );
                        },
                      ),
                      Text(
                        'Your Strengths & Growth Areas',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ...result.insights.take(2).map(
                            (insight) =>
                                _DimensionInsightCard(insight: insight),
                          ),
                      if (result.insights.length > 2)
                        PremiumGate(
                          feature: SubscriptionFeature.detailedAnalytics,
                          featureName: 'Detailed Dimension Analysis',
                          child: Column(
                            children: result.insights
                                .skip(2)
                                .map(
                                  (insight) => _DimensionInsightCard(
                                    insight: insight,
                                  ),
                                )
                                .toList(),
                          ),
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
                      const SizedBox(height: 32),
                      AnimatedButton(
                        text: 'Start Coaching',
                        onPressed: () {
                          final r = ref.read(assessmentNotifierProvider).result;
                          final repo = ref.read(coachingRepositoryProvider);
                          if (r != null) {
                            repo.applyCoachingContext(
                              assessmentToCoachingContext(r),
                            );
                          }
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

  Widget _buildRadarChart(AssessmentResult result) {
    final dimensions = EQDimension.values.toList();
    final entries = dimensions
        .map((d) => RadarEntry(value: result.dimensionScores[d] ?? 0))
        .toList();

    return RadarChart(
      RadarChartData(
        dataSets: [
          RadarDataSet(
            fillColor: EmvoColors.primary.withValues(alpha: 0.3),
            borderColor: EmvoColors.primary,
            entryRadius: 5,
            dataEntries: entries,
            borderWidth: 2,
          ),
          RadarDataSet(
            fillColor: Colors.transparent,
            borderColor:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.18),
            entryRadius: 0,
            dataEntries: List.generate(
              dimensions.length,
              (_) => const RadarEntry(value: 50),
            ),
            borderWidth: 1,
          ),
        ],
        radarBackgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        radarBorderData: BorderSide(
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
        ),
        titlePositionPercentageOffset: 0.2,
        getTitle: (index, angle) {
          final dimension = dimensions[index];
          return RadarChartTitle(
            text: dimension.displayName.split(' ').join('\n'),
            angle: angle,
            positionPercentageOffset: 0.2,
          );
        },
        titleTextStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
        tickCount: 4,
        ticksTextStyle: const TextStyle(color: Colors.transparent),
        tickBorderData: BorderSide(
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
        ),
        gridBorderData: BorderSide(
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
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
          'Try this week',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        ...narrative.actions.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${e.key + 1}.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.primary,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _plain(e.value),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.9),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        const SizedBox(height: 24),
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

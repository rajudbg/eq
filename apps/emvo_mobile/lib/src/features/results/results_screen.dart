import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_assessment/emvo_assessment.dart';
import 'package:emvo_core/emvo_core.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../../routing/routing.dart';
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
    Future<void>.delayed(Duration.zero, () {
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
      body: SafeArea(
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
                          style:
                              Theme.of(context).textTheme.displayLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          'Overall EQ Score',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white
                                        .withValues(alpha: 0.9),
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
                    Text(
                      'Your Strengths & Growth Areas',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ...result.insights
                        .take(2)
                        .map(
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
                      onPressed: () => context.go(Routes.coach),
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
            borderColor: EmvoColors.onBackground.withValues(alpha: 0.2),
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
          color: EmvoColors.onBackground.withValues(alpha: 0.1),
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
              color: EmvoColors.onBackground.withValues(alpha: 0.65),
              fontWeight: FontWeight.w500,
            ),
        tickCount: 4,
        ticksTextStyle: const TextStyle(color: Colors.transparent),
        tickBorderData: BorderSide(
          color: EmvoColors.onBackground.withValues(alpha: 0.05),
        ),
        gridBorderData: BorderSide(
          color: EmvoColors.onBackground.withValues(alpha: 0.1),
        ),
      ),
    );
  }
}

class _DimensionInsightCard extends StatelessWidget {
  const _DimensionInsightCard({required this.insight});

  final DimensionInsight insight;

  @override
  Widget build(BuildContext context) {
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
                  color: EmvoColors.onBackground.withValues(alpha: 0.8),
                ),
          ),
          if (insight.growthAreas.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: insight.growthAreas
                  .map(
                    (area) => Chip(
                      label: Text(
                        area,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: EmvoColors.surfaceVariant,
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
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(EmvoDimensions.md),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: EmvoColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                index.toString(),
                style: const TextStyle(
                  color: EmvoColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
          delay: Duration(milliseconds: index * 100),
        ).slideX(begin: 0.1);
  }
}

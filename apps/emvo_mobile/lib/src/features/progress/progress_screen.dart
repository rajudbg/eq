import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_assessment/emvo_assessment.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../../providers/assessment_providers.dart';
import '../../providers/eq_action_plan_provider.dart';
import '../../routing/routing.dart';
import '../../widgets/eq_action_plan_widgets.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<List<AssessmentResult>>>(
      assessmentHistoryProvider,
      (previous, next) {
        next.whenData((history) {
          if (history.isNotEmpty) {
            ref
                .read(eqActionPlanProvider.notifier)
                .ensureFromAssessment(history.last);
          }
        });
      },
    );

    final historyAsync = ref.watch(assessmentHistoryProvider);
    final textDirection =
        Directionality.maybeOf(context) ?? TextDirection.ltr;

    // Nested shell [Scaffold] + tab [Scaffold]: [primary: false] avoids broken
    // body constraints; explicit [Directionality] covers [ListTile]/[Icon] if
    // transition layers ever drop inherited directionality.
    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
      primary: false,
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Your Progress'),
      ),
      body: EmvoAmbientBackground(
        child: SafeArea(
          child: historyAsync.when(
            data: (history) => _buildContent(context, ref, history),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(
              child: Padding(
                padding: EmvoDimensions.paddingScreen,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: EmvoColors.error,
                    ),
                    const SizedBox(height: 16),
                    const Text('Failed to load history'),
                    const SizedBox(height: 16),
                    AnimatedButton(
                      text: 'Retry',
                      onPressed: () =>
                          ref.invalidate(assessmentHistoryProvider),
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<AssessmentResult> history,
  ) {
    if (history.isEmpty) {
      return Center(
        child: Padding(
          padding: EmvoDimensions.paddingScreen,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.trending_up,
                size: 64,
                color: context.emvoOnSurface(0.32),
              ),
              const SizedBox(height: 16),
              Text(
                'No data yet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Complete your first assessment to see progress',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.emvoOnSurface(0.62),
                    ),
              ),
              const SizedBox(height: 24),
              AnimatedButton(
                text: 'Take assessment',
                onPressed: () => context.go(Routes.assessment),
                width: double.infinity,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EmvoDimensions.paddingScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildJourneyHero(context, history),
          const SizedBox(height: 28),
          Text(
            'EQ Journey',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Each point is a completed assessment — your trail through time.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.emvoOnSurface(0.62),
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildTrendChart(context, history),
          ),
          if (history.length >= 2) ...[
            const SizedBox(height: 24),
            _AssessmentDeltaCard(
              previous: history[history.length - 2],
              latest: history.last,
            ),
          ],
          const SizedBox(height: 32),
          Text(
            'Dimension Growth',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          _buildDimensionComparison(context, history.last),
          const SizedBox(height: 24),
          EqDashboardActionPlanSummary(result: history.last),
          const SizedBox(height: 32),
          Text(
            'Assessment History',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          ...history.reversed.map((result) => _HistoryCard(result: result)),
        ],
      ),
    );
  }

  /// Ring + copy so progress is felt as movement, not only a line chart.
  Widget _buildJourneyHero(
    BuildContext context,
    List<AssessmentResult> history,
  ) {
    final latest = history.last;
    final first = history.first;
    final hasArc = history.length >= 2;
    final delta = hasArc ? latest.overallScore - first.overallScore : 0.0;
    final deltaLabel =
        delta >= 0 ? '+${delta.toStringAsFixed(1)}' : delta.toStringAsFixed(1);

    return Semantics(
      container: true,
      label: 'Overall score ${latest.overallScore.toInt()} out of one hundred',
      child: GlassContainer(
        padding: const EdgeInsets.all(EmvoDimensions.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedScoreRing(
              score: latest.overallScore,
              size: 128,
              animated: true,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Where you are on the path',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasArc
                        ? 'EQ shifts gradually — small moves still count. '
                            'The chart below is how your overall score has traveled.'
                        : 'This ring is your baseline. After a second assessment, '
                            'the journey line appears and you can feel the arc.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.emvoOnSurface(0.68),
                          height: 1.45,
                        ),
                  ),
                  if (hasArc) ...[
                    const SizedBox(height: 10),
                    Text(
                      '$deltaLabel points overall vs your first result '
                      '(${first.overallScore.toInt()} → ${latest.overallScore.toInt()})',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart(
    BuildContext context,
    List<AssessmentResult> history,
  ) {
    final spots = history.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.overallScore);
    }).toList();

    final scheme = context.emvoScheme;
    final dotStroke = scheme.surface;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: context.emvoOnSurface(0.06),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: context.emvoOnSurface(0.52),
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (history.length - 1).toDouble(),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: EmvoColors.primary,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: EmvoColors.primary,
                  strokeWidth: 2,
                  strokeColor: dotStroke,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: EmvoColors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionComparison(
    BuildContext context,
    AssessmentResult latest,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(EmvoDimensions.md),
      child: Column(
        children: latest.dimensionScores.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key.displayName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      entry.value.toInt().toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: EmvoColors.primary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: entry.value / 100,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getDimensionColor(entry.key),
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getDimensionColor(EQDimension dimension) {
    switch (dimension) {
      case EQDimension.selfAwareness:
        return EmvoColors.primary;
      case EQDimension.selfRegulation:
        return EmvoColors.secondary;
      case EQDimension.empathy:
        return EmvoColors.tertiary;
      case EQDimension.socialSkills:
        return EmvoColors.success;
    }
  }
}

class _AssessmentDeltaCard extends StatelessWidget {
  const _AssessmentDeltaCard({
    required this.previous,
    required this.latest,
  });

  final AssessmentResult previous;
  final AssessmentResult latest;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final overallDelta = latest.overallScore - previous.overallScore;
    final sign = overallDelta >= 0 ? '+' : '';
    return GlassContainer(
      padding: const EdgeInsets.all(EmvoDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Since your last assessment',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Overall EQ $sign${overallDelta.toStringAsFixed(1)} points',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          for (final d in EQDimension.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    d.displayName,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    _dimDeltaLabel(
                      (latest.dimensionScores[d] ?? 0) -
                          (previous.dimensionScores[d] ?? 0),
                    ),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _dimDeltaLabel(double delta) {
    if (delta.abs() < 0.05) return '0';
    final s = delta > 0 ? '+' : '';
    return '$s${delta.toStringAsFixed(1)}';
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.result});

  final AssessmentResult result;

  @override
  Widget build(BuildContext context) {
    final date = result.completedAt.toLocal();
    final formattedDate = '${date.day}/${date.month}/${date.year}';

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: EmvoColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              result.overallScore.toInt().toString(),
              style: const TextStyle(
                color: EmvoColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          'Assessment $formattedDate',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        subtitle: Text(
          '${result.dimensionScores.length} dimensions measured',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

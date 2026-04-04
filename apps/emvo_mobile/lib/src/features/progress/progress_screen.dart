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

    return Scaffold(
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
          Text(
            'EQ Journey',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildTrendChart(context, history),
          ),
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

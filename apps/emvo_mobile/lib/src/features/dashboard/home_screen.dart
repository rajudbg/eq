import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_assessment/emvo_assessment.dart';
import 'package:emvo_core/emvo_core.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../../providers/assessment_providers.dart';
import '../../routing/routing.dart';

int _dailyStreakFromHistory(List<AssessmentResult> history) {
  if (history.isEmpty) return 0;
  final daySet = history.map((e) {
    final d = e.completedAt.toLocal();
    return DateTime(d.year, d.month, d.day);
  }).toSet();
  final today = DateTime.now();
  var cursor = DateTime(today.year, today.month, today.day);
  if (!daySet.contains(cursor)) {
    cursor = cursor.subtract(const Duration(days: 1));
  }
  var streak = 0;
  while (daySet.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestResultAsync = ref.watch(latestResultProvider);
    final historyAsync = ref.watch(assessmentHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emvo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go(Routes.profile),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EmvoDimensions.paddingScreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: EmvoColors.onBackground.withValues(alpha: 0.6),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ready to grow?',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 24),
              latestResultAsync.when(
                data: (result) => result != null
                    ? _buildScoreCard(context, result)
                    : _buildNoDataCard(context),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => _buildNoDataCard(context),
              ),
              const SizedBox(height: 24),
              historyAsync.when(
                data: (history) => _buildStreakCard(context, history),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => _buildStreakCard(context, const []),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final isPremium = ref.watch(isPremiumProvider);
                  if (isPremium) return const SizedBox.shrink();

                  return GlassContainer(
                    margin: const EdgeInsets.only(bottom: 24),
                    color: EmvoColors.primary.withValues(alpha: 0.1),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: EmvoColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.star,
                          color: EmvoColors.primary,
                        ),
                      ),
                      title: const Text('Unlock Premium'),
                      subtitle: const Text(
                        'Get unlimited coaching & insights',
                      ),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () => context.push('/paywall'),
                    ),
                  ).animate().fadeIn();
                },
              ),
              const SizedBox(height: 24),
              historyAsync.when(
                data: (history) => _buildProgressSection(context, history),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              _buildDailyCheckIn(context),
              const SizedBox(height: 24),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.psychology,
                      label: 'Retake\nAssessment',
                      color: EmvoColors.primary,
                      onTap: () => context.go(Routes.assessment),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.chat_bubble,
                      label: 'Talk to\nCoach',
                      color: EmvoColors.secondary,
                      onTap: () => context.go(Routes.coach),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.trending_up,
                      label: 'View\nProgress',
                      color: EmvoColors.tertiary,
                      onTap: () => context.go(Routes.progress),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Recent Insights',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              latestResultAsync.maybeWhen(
                data: (result) {
                  if (result != null && result.insights.isNotEmpty) {
                    final i = result.insights.first;
                    return _buildInsightCard(
                      context,
                      icon: Icons.lightbulb,
                      title: i.dimension.displayName,
                      description: i.description,
                      color: EmvoColors.secondary,
                    );
                  }
                  return _buildInsightCard(
                    context,
                    icon: Icons.lightbulb,
                    title: 'Focus Area',
                    description:
                        'Work on pausing before reacting in stressful moments',
                    color: EmvoColors.secondary,
                  );
                },
                orElse: () => _buildInsightCard(
                  context,
                  icon: Icons.lightbulb,
                  title: 'Focus Area',
                  description:
                      'Work on pausing before reacting in stressful moments',
                  color: EmvoColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, AssessmentResult result) {
    final dims = EQDimension.values.take(2).toList();
    return GlassContainer(
      padding: const EdgeInsets.all(EmvoDimensions.lg),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your EQ Score',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              EmvoColors.onBackground.withValues(alpha: 0.6),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.overallScore.toInt().toString(),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: EmvoColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              AnimatedScoreRing(
                score: result.overallScore,
                size: 80,
                animated: false,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: dims.map((dim) {
              final v = result.dimensionScores[dim] ?? 0;
              return Column(
                children: [
                  Text(
                    v.toInt().toString(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: EmvoColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    dim.displayName.split(' ').first,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataCard(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(EmvoDimensions.lg),
      child: Column(
        children: [
          const Icon(
            Icons.assessment_outlined,
            size: 48,
            color: EmvoColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Take your first assessment',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Discover your emotional intelligence profile',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: EmvoColors.onBackground.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 16),
          AnimatedButton(
            text: 'Start Assessment',
            onPressed: () => context.go(Routes.assessment),
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, List<AssessmentResult> history) {
    final streak = _dailyStreakFromHistory(history);
    return GlassContainer(
      color: EmvoColors.secondary.withValues(alpha: 0.1),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: EmvoColors.secondary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.local_fire_department,
            color: EmvoColors.secondary,
          ),
        ),
        title: Text(
          streak > 0 ? '$streak Day Streak' : 'Start a streak',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          streak > 0
              ? 'Keep your momentum going!'
              : 'Complete an assessment on consecutive days',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: EmvoColors.secondary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '🔥 $streak',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(
    BuildContext context,
    List<AssessmentResult> history,
  ) {
    if (history.length < 2) {
      return GlassContainer(
        padding: const EdgeInsets.all(EmvoDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EQ progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              history.isEmpty
                  ? 'Finish another assessment to see your score trend.'
                  : 'Take one more assessment to unlock your trend line.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: EmvoColors.onBackground.withValues(alpha: 0.65),
                  ),
            ),
          ],
        ),
      );
    }

    final recent = history.length > 8 ? history.sublist(history.length - 8) : history;
    final spots = <FlSpot>[];
    for (var i = 0; i < recent.length; i++) {
      spots.add(FlSpot(i.toDouble(), recent[i].overallScore));
    }

    return GlassContainer(
      padding: const EdgeInsets.all(EmvoDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EQ progress',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Overall score across recent assessments',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: EmvoColors.onBackground.withValues(alpha: 0.65),
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: EmvoColors.onBackground.withValues(alpha: 0.08),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 25,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: EmvoColors.onBackground
                                  .withValues(alpha: 0.5),
                            ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= recent.length) {
                          return const SizedBox.shrink();
                        }
                        final d = recent[i].completedAt.toLocal();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${d.month}/${d.day}',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: EmvoColors.onBackground
                                      .withValues(alpha: 0.55),
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: EmvoColors.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: EmvoColors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'History (${history.length} total)',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: EmvoColors.onBackground.withValues(alpha: 0.55),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCheckIn(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(EmvoDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: EmvoColors.tertiary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: EmvoColors.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Daily Check-in',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'How are you feeling right now?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _EmotionChip(icon: Icons.sentiment_very_dissatisfied, label: 'Low'),
              _EmotionChip(icon: Icons.sentiment_dissatisfied, label: 'Down'),
              _EmotionChip(icon: Icons.sentiment_neutral, label: 'Okay'),
              _EmotionChip(icon: Icons.sentiment_satisfied, label: 'Good'),
              _EmotionChip(icon: Icons.sentiment_very_satisfied, label: 'Great'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(description),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}

class _EmotionChip extends StatelessWidget {
  const _EmotionChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: () {},
          color: EmvoColors.onBackground.withValues(alpha: 0.6),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(EmvoDimensions.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

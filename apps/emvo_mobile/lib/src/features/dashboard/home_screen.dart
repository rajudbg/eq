import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_assessment/emvo_assessment.dart';
import 'package:emvo_core/emvo_core.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../../providers/assessment_providers.dart';
import '../../providers/daily_checkin_provider.dart';
import '../../routing/routing.dart';
import '../../widgets/emvo_app_bar_title.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';

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
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const EmvoAppBarTitle(height: 28),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: EmvoAmbientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EmvoDimensions.paddingScreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.emvoOnSurface(0.6),
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
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
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
                          'Get unlimited coaching & full history',
                        ),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => context.push('/paywall'),
                      ),
                    ).animate().fadeIn();
                  },
                ),
                const SizedBox(height: 24),
                historyAsync.when(
                  data: (history) => _buildProgressSection(context, history, isPremium),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),
                const _DailyCheckInCard(),
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
                        icon: Icons.theater_comedy,
                        label: 'Practice\nScenario',
                        color: EmvoColors.tertiary,
                        onTap: () => {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening AI Scenario Simulator...')),
                          )
                        },
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
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, AssessmentResult result) {
    return Column(
      children: [
        EqRadarChart(
          selfAwareness: result.dimensionScores[EQDimension.selfAwareness] ?? 0,
          selfManagement: result.dimensionScores[EQDimension.selfRegulation] ?? 0,
          socialAwareness: result.dimensionScores[EQDimension.socialSkills] ?? 0,
          relationshipManagement: result.dimensionScores[EQDimension.empathy] ?? 0,
        ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 16),
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall EQ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context.emvoOnSurface(0.7),
                    fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  Text(
                    result.overallScore.toInt().toString(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: EmvoColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedScoreRing(
                    score: result.overallScore,
                    size: 40,
                    animated: true,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AnimatedButton(
          text: 'Share My EQ',
          onPressed: () {
            Share.share(
              'I just scored ${result.overallScore.toInt()} on my EQ Assessment in Emvo! 🚀\n\n'
              '🧠 Self Awareness: ${result.dimensionScores[EQDimension.selfAwareness]?.toInt() ?? 0}\n'
              '🛡️ Self Management: ${result.dimensionScores[EQDimension.selfRegulation]?.toInt() ?? 0}\n'
              '🤝 Social Awareness: ${result.dimensionScores[EQDimension.socialSkills]?.toInt() ?? 0}\n'
              '❤️ Relationship Management: ${result.dimensionScores[EQDimension.empathy]?.toInt() ?? 0}\n\n'
              'Can you beat my score?',
            );
          },
          width: double.infinity,
        ),
      ],
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
                  color: context.emvoOnSurface(0.6),
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

  Widget _buildStreakCard(
    BuildContext context,
    List<AssessmentResult> history,
  ) {
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
    bool isPremium,
  ) {
    Widget tappableCard(Widget card) {
      return Semantics(
        button: true,
        label: 'Open full EQ progress',
        child: Tooltip(
          message: 'Open Progress tab',
          child: GestureDetector(
            onTap: () => context.go(Routes.progress),
            behavior: HitTestBehavior.opaque,
            child: card,
          ),
        ),
      );
    }

    if (history.length < 2) {
      return tappableCard(
        GlassContainer(
          padding: const EdgeInsets.all(EmvoDimensions.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'EQ progress',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(Routes.progress),
                    child: const Text('Open'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                history.isEmpty
                    ? 'Finish another assessment to see your score trend.'
                    : 'Take one more assessment to unlock your trend line.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.emvoOnSurface(0.65),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to view your Progress screen',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final limitedHistory = isPremium ? history : (history.length > 3 ? history.sublist(history.length - 3) : history);
    final recent =
        limitedHistory.length > 8 ? limitedHistory.sublist(limitedHistory.length - 8) : limitedHistory;
    final spots = <FlSpot>[];
    for (var i = 0; i < recent.length; i++) {
      spots.add(FlSpot(i.toDouble(), recent[i].overallScore));
    }

    return tappableCard(
      GlassContainer(
        padding: const EdgeInsets.all(EmvoDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'EQ progress',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go(Routes.progress),
                  child: const Text('See all'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isPremium 
                  ? 'Overall score across recent assessments' 
                  : 'Showing last 3 scores. Unlock Premium for full history.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isPremium ? context.emvoOnSurface(0.65) : EmvoColors.primary,
                    fontWeight: isPremium ? FontWeight.normal : FontWeight.bold,
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
                      color: context.emvoOnSurface(0.08),
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
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: context.emvoOnSurface(0.5),
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
                                    color: context.emvoOnSurface(0.55),
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
                    color: context.emvoOnSurface(0.55),
                  ),
            ),
          ],
        ),
      ),
    );
  }

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

class _DailyCheckInCard extends ConsumerStatefulWidget {
  const _DailyCheckInCard();

  @override
  ConsumerState<_DailyCheckInCard> createState() => _DailyCheckInCardState();
}

class _DailyCheckInCardState extends ConsumerState<_DailyCheckInCard> {
  final _noteController = TextEditingController();

  Future<void> _submitDailyCheckIn(String label) async {
    await ref.read(dailyCheckInProvider.notifier).recordMood(label);
    
    // Check for App Store Review eligibility
    final history = ref.read(assessmentHistoryProvider).valueOrNull ?? [];
    final streak = _dailyStreakFromHistory(history);
    
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    _noteController.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Saved as “$label”. Your coach will use this in replies.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // If they have a 3 day streak, gracefully ask for a review
    if (streak >= 3) {
      if (await InAppReview.instance.isAvailable()) {
        InAppReview.instance.requestReview();
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkIn = ref.watch(dailyCheckInProvider);
    final scheme = Theme.of(context).colorScheme;

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
              Expanded(
                child: Text(
                  'Daily Check-in',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          if (checkIn != null) ...[
            const SizedBox(height: 8),
            Text(
              'Today: ${checkIn.moodLabel}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'How are you feeling right now?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: "What's on your mind? (Optional)",
              hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.emvoOnSurface(0.4),
                  ),
              filled: true,
              fillColor: context.emvoOnSurface(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            maxLines: 2,
            minLines: 1,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _EmotionChip(
                icon: Icons.sentiment_very_dissatisfied,
                label: 'Low',
                selected: checkIn?.moodLabel == 'Low',
                onTap: () => _submitDailyCheckIn('Low'),
              ),
              _EmotionChip(
                icon: Icons.sentiment_dissatisfied,
                label: 'Down',
                selected: checkIn?.moodLabel == 'Down',
                onTap: () => _submitDailyCheckIn('Down'),
              ),
              _EmotionChip(
                icon: Icons.sentiment_neutral,
                label: 'Okay',
                selected: checkIn?.moodLabel == 'Okay',
                onTap: () => _submitDailyCheckIn('Okay'),
              ),
              _EmotionChip(
                icon: Icons.sentiment_satisfied,
                label: 'Good',
                selected: checkIn?.moodLabel == 'Good',
                onTap: () => _submitDailyCheckIn('Good'),
              ),
              _EmotionChip(
                icon: Icons.sentiment_very_satisfied,
                label: 'Great',
                selected: checkIn?.moodLabel == 'Great',
                onTap: () => _submitDailyCheckIn('Great'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmotionChip extends StatelessWidget {
  const _EmotionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: label,
          style: IconButton.styleFrom(
            backgroundColor:
                selected ? scheme.primary.withValues(alpha: 0.18) : null,
          ),
          icon: Icon(icon),
          onPressed: onTap,
          color: selected ? scheme.primary : context.emvoOnSurface(0.62),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? scheme.primary : null,
              ),
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

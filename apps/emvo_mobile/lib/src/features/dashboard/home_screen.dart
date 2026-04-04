import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_assessment/emvo_assessment.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../../providers/assessment_providers.dart';
import '../../providers/daily_checkin_provider.dart';
import '../../providers/eq_action_plan_provider.dart';
import '../../providers/upcoming_situations_provider.dart';
import '../../providers/action_plan_celebration_provider.dart';
import '../../providers/retake_banner_snooze_provider.dart';
import '../../retention/action_plan_unlock.dart';
import '../../routing/routing.dart';
import 'action_plan_unlock_dialog.dart';
import 'dashboard_home_inputs_provider.dart';
import 'dashboard_home_state.dart';
import '../../widgets/emvo_app_bar_title.dart';
import '../../widgets/eq_action_plan_widgets.dart';
import '../../widgets/upcoming_situations_card.dart';
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

String _assessmentCadenceSubtitle(int consecutiveAssessmentDays) {
  if (consecutiveAssessmentDays <= 0) {
    return 'Assessment cadence: complete an assessment to start a run.';
  }
  return 'Assessment cadence: $consecutiveAssessmentDays consecutive '
      'day${consecutiveAssessmentDays == 1 ? '' : 's'} with a completed assessment '
      '(separate from your daily check-in streak).';
}

void _showRemindersSheet(BuildContext context, WidgetRef ref) {
  final situations = ref.read(upcomingSituationsProvider);
  showModalBottomSheet<void>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Reminders',
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Enable “Reminders & tips” in Settings for a daily EQ prompt and alerts '
              'before situations you add on Home.',
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
            ),
            if (situations.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '${situations.length} situation${situations.length == 1 ? '' : 's'} on your list.',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                ctx.push(Routes.settings);
              },
              child: const Text('Notification settings'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _RetakeBanner extends ConsumerWidget {
  const _RetakeBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassContainer(
      color: EmvoColors.secondary.withValues(alpha: 0.12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading:
                const Icon(Icons.flag_outlined, color: EmvoColors.secondary),
            title: const Text('Time to remeasure your EQ'),
            subtitle: const Text(
              'It’s been 30 days — retake the assessment to see score changes.',
            ),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => context.go(Routes.assessment),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextButton(
              onPressed: () =>
                  ref.read(retakeBannerSnoozeProvider.notifier).snoozeOneWeek(),
              child: const Text('Remind me in a week'),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _maybeCelebratePlanUnlock());
  }

  Future<void> _maybeCelebratePlanUnlock() async {
    if (!mounted) return;
    final history = ref.read(assessmentHistoryProvider).valueOrNull;
    if (history == null || history.isEmpty) return;
    final latest = history.last;
    final visible = actionPlanVisibleHabitCount(latest.completedAt);
    final prefs = ref.read(actionPlanCelebrationPrefsProvider);
    final last = await prefs.readLast();
    if (last.resultId != latest.id) {
      await prefs.write(latest.id, visible);
      return;
    }
    if (visible > last.visible) {
      await prefs.write(latest.id, visible);
      if (!mounted) return;
      await showActionPlanUnlockDialog(context, visibleHabitCount: visible);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AssessmentResult?>>(latestResultProvider,
        (previous, next) {
      next.whenData((r) {
        if (r != null) {
          ref.read(eqActionPlanProvider.notifier).ensureFromAssessment(r);
        }
      });
    });

    final latestResultAsync = ref.watch(latestResultProvider);
    final derivedAsync = ref.watch(dashboardHomeDerivedProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const EmvoAppBarTitle(height: 28),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Reminders',
            onPressed: () => _showRemindersSheet(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: EmvoAmbientBackground(
        child: SafeArea(
          child: derivedAsync.when(
            data: (derived) {
              final layout = derived.layout;
              final inputs = derived.inputs;
              final history = inputs.assessmentHistory;
              final result = inputs.latestResult;
              final checkIn = inputs.checkIn;

              final emphasizeCheckIn = checkIn.today == null &&
                  layout.sections.asMap().entries.any(
                        (e) =>
                            e.value == HomeDashboardSection.dailyCheckIn &&
                            (e.key == 0 ||
                                (e.key == 1 &&
                                    layout.sections[0] ==
                                        HomeDashboardSection.retakeBanner)),
                      );
              final emphasizeSituationDiscovery =
                  result != null && inputs.situations.isEmpty;

              final children = <Widget>[
                Text(
                  layout.headline,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: -0.3,
                      ),
                )
                    .animate()
                    .fadeIn(duration: 380.ms, curve: Curves.easeOutCubic)
                    .slideY(begin: 0.06, duration: 400.ms),
                const SizedBox(height: 6),
                Text(
                  layout.subline,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.emvoOnSurface(0.72),
                        height: 1.4,
                      ),
                ).animate().fadeIn(
                      duration: 400.ms,
                      delay: 50.ms,
                      curve: Curves.easeOutCubic,
                    ),
                if (layout.metaLine != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    layout.metaLine!,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ).animate().fadeIn(delay: 90.ms, duration: 380.ms),
                ],
                if (layout.primaryCtaHint != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    layout.primaryCtaHint!,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: context.emvoOnSurface(0.5),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
                const SizedBox(height: 22),
                ..._buildDashboardSections(
                  context,
                  ref,
                  layout: layout,
                  result: result,
                  history: history,
                  isPremium: inputs.isPremium,
                  latestResultAsync: latestResultAsync,
                  emphasizeCheckIn: emphasizeCheckIn,
                  checkIn: checkIn,
                  emphasizeSituationDiscovery: emphasizeSituationDiscovery,
                ),
              ];

              return SingleChildScrollView(
                padding: EmvoDimensions.paddingScreen,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => SingleChildScrollView(
              padding: EmvoDimensions.paddingScreen,
              child: latestResultAsync.when(
                data: (r) => r != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildScoreCard(context, r),
                          const SizedBox(height: 24),
                          _DailyCheckInCard(
                            compact:
                                ref.watch(dailyCheckInProvider).today != null,
                            emphasize: false,
                          ),
                        ],
                      )
                    : _buildNoDataCard(context),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => _buildNoDataCard(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDashboardSections(
    BuildContext context,
    WidgetRef ref, {
    required DashboardHomeLayout layout,
    required AssessmentResult? result,
    required List<AssessmentResult> history,
    required bool isPremium,
    required AsyncValue<AssessmentResult?> latestResultAsync,
    required bool emphasizeCheckIn,
    required DailyCheckInState checkIn,
    required bool emphasizeSituationDiscovery,
  }) {
    final widgets = <Widget>[];
    var gapBefore = false;

    void addGap() {
      if (gapBefore) widgets.add(const SizedBox(height: 24));
      gapBefore = true;
    }

    for (final section in layout.sections) {
      switch (section) {
        case HomeDashboardSection.retakeBanner:
          addGap();
          widgets.add(const _RetakeBanner());
        case HomeDashboardSection.dailyCheckIn:
          addGap();
          final compact = checkIn.today != null;
          widgets.add(
            _DailyCheckInCard(
              compact: compact,
              emphasize: emphasizeCheckIn && !compact,
            ),
          );
        case HomeDashboardSection.upcomingSituations:
          addGap();
          widgets.add(
            UpcomingSituationsCard(
              emphasizeEmptyGuidance: emphasizeSituationDiscovery,
            ),
          );
        case HomeDashboardSection.scoreSnapshot:
          if (result == null) {
            addGap();
            widgets.add(_buildNoDataCard(context));
          } else {
            addGap();
            widgets.add(_buildScoreCard(context, result));
          }
        case HomeDashboardSection.weeklyActionPlan:
          if (result != null) {
            addGap();
            widgets.add(EqDashboardActionPlanSummary(result: result));
          }
        case HomeDashboardSection.premiumUpsell:
          if (!isPremium) {
            addGap();
            widgets.add(
              GlassContainer(
                margin: const EdgeInsets.only(bottom: 0),
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
              ).animate().fadeIn(),
            );
          }
        case HomeDashboardSection.eqProgress:
          addGap();
          final cadence = _dailyStreakFromHistory(history);
          widgets.add(
            _buildProgressSection(
              context,
              history,
              isPremium,
              assessmentCadenceDays: cadence,
            ),
          );
        case HomeDashboardSection.quickActions:
          addGap();
          widgets.add(
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          );
          widgets.add(const SizedBox(height: 16));
          widgets.add(
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.psychology,
                    label: 'Retake\nAssessment',
                    color: EmvoColors.primary,
                    onTap: () => context.go(Routes.assessment),
                  )
                      .animate()
                      .scale(delay: 200.ms, begin: const Offset(0.9, 0.9))
                      .fadeIn(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.chat_bubble,
                    label: 'Talk to\nCoach',
                    color: EmvoColors.secondary,
                    onTap: () => context.go(Routes.coach),
                  )
                      .animate()
                      .scale(delay: 300.ms, begin: const Offset(0.9, 0.9))
                      .fadeIn(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.theater_comedy,
                    label: 'Practice\nScenario',
                    color: EmvoColors.tertiary,
                    onTap: () {
                      ref.read(assessmentNotifierProvider.notifier).reset();
                      context.go(Routes.assessment);
                    },
                  )
                      .animate()
                      .scale(delay: 400.ms, begin: const Offset(0.9, 0.9))
                      .fadeIn(),
                ),
              ],
            ),
          );
        case HomeDashboardSection.recentInsights:
          addGap();
          widgets.add(
            Text(
              'Recent Insights',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          );
          widgets.add(const SizedBox(height: 16));
          widgets.add(
            latestResultAsync.maybeWhen(
              data: (r) {
                if (r != null && r.insights.isNotEmpty) {
                  final i = r.insights.first;
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
          );
      }
    }

    return widgets;
  }

  Widget _buildScoreCard(BuildContext context, AssessmentResult result) {
    return Column(
      children: [
        EqRadarChart(
          selfAwareness: result.dimensionScores[EQDimension.selfAwareness] ?? 0,
          selfManagement:
              result.dimensionScores[EQDimension.selfRegulation] ?? 0,
          socialAwareness:
              result.dimensionScores[EQDimension.socialSkills] ?? 0,
          relationshipManagement:
              result.dimensionScores[EQDimension.empathy] ?? 0,
        ), // Radar chart defines its own internal entry animation now
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
                      fontWeight: FontWeight.w600,
                    ),
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

  Widget _buildProgressSection(
    BuildContext context,
    List<AssessmentResult> history,
    bool isPremium, {
    required int assessmentCadenceDays,
  }) {
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
                      'EQ snapshot',
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
                _assessmentCadenceSubtitle(assessmentCadenceDays),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: context.emvoOnSurface(0.55),
                    ),
              ),
              const SizedBox(height: 12),
              if (history.isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedScoreRing(
                      score: history.last.overallScore,
                      size: 100,
                      animated: false,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Take one more assessment to unlock your trend line — '
                        'the Progress tab shows the full path.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.emvoOnSurface(0.65),
                              height: 1.4,
                            ),
                      ),
                    ),
                  ],
                )
              else
                Text(
                  'Finish another assessment to see your score trend.',
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

    final limitedHistory = isPremium
        ? history
        : (history.length > 3 ? history.sublist(history.length - 3) : history);
    final recent = limitedHistory.length > 8
        ? limitedHistory.sublist(limitedHistory.length - 8)
        : limitedHistory;
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
                    'EQ snapshot',
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
              _assessmentCadenceSubtitle(assessmentCadenceDays),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: context.emvoOnSurface(0.55),
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              isPremium
                  ? 'Overall score across recent assessments'
                  : 'Showing last 3 scores. Unlock Premium for full history.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isPremium
                        ? context.emvoOnSurface(0.65)
                        : EmvoColors.primary,
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
}

class _DailyCheckInCard extends ConsumerStatefulWidget {
  const _DailyCheckInCard({
    this.compact = false,
    this.emphasize = false,
  });

  final bool compact;
  final bool emphasize;

  @override
  ConsumerState<_DailyCheckInCard> createState() => _DailyCheckInCardState();
}

class _DailyCheckInCardState extends ConsumerState<_DailyCheckInCard> {
  final _noteController = TextEditingController();

  Future<void> _submitDailyCheckIn(String label) async {
    final note = _noteController.text.trim();
    await ref.read(dailyCheckInProvider.notifier).recordMood(
          label,
          note: note.isEmpty ? null : note,
        );

    final checkStreak = ref.read(dailyCheckInProvider).streakDays;

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

    if (checkStreak >= 3) {
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
    final checkInState = ref.watch(dailyCheckInProvider);
    final today = checkInState.today;
    final scheme = Theme.of(context).colorScheme;
    final prompt = dailyPromptForDate(DateTime.now());

    if (widget.compact && today != null) {
      final note = today.note;
      return GlassContainer(
        padding: const EdgeInsets.all(EmvoDimensions.md + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: scheme.primary, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Today's check-in",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.35,
                        ),
                  ),
                ),
                if (checkInState.streakDays > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${checkInState.streakDays}d streak',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              today.moodLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (note != null && note.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                note,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.emvoOnSurface(0.72),
                      height: 1.35,
                    ),
              ),
            ],
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => context.go(Routes.coach),
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text('Talk to Coach'),
            ),
          ],
        ),
      );
    }

    Widget core = GlassContainer(
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
                  "Today's check-in",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              if (checkInState.streakDays > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${checkInState.streakDays}d streak',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
            ],
          ),
          if (today != null) ...[
            const SizedBox(height: 8),
            Text(
              'Logged: ${today.moodLabel}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            prompt.value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'How are you feeling right now?',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.emvoOnSurface(0.65),
                ),
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                selected: today?.moodLabel == 'Low',
                onTap: () => _submitDailyCheckIn('Low'),
              ),
              _EmotionChip(
                icon: Icons.sentiment_dissatisfied,
                label: 'Down',
                selected: today?.moodLabel == 'Down',
                onTap: () => _submitDailyCheckIn('Down'),
              ),
              _EmotionChip(
                icon: Icons.sentiment_neutral,
                label: 'Okay',
                selected: today?.moodLabel == 'Okay',
                onTap: () => _submitDailyCheckIn('Okay'),
              ),
              _EmotionChip(
                icon: Icons.sentiment_satisfied,
                label: 'Good',
                selected: today?.moodLabel == 'Good',
                onTap: () => _submitDailyCheckIn('Good'),
              ),
              _EmotionChip(
                icon: Icons.sentiment_very_satisfied,
                label: 'Great',
                selected: today?.moodLabel == 'Great',
                onTap: () => _submitDailyCheckIn('Great'),
              ),
            ],
          ),
        ],
      ),
    );

    // Single entrance pulse — avoids continuous animation jank on low-end devices.
    if (widget.emphasize) {
      core = core
          .animate()
          .scale(
            duration: 520.ms,
            begin: const Offset(0.985, 0.985),
            end: const Offset(1.014, 1.014),
            curve: Curves.easeOutCubic,
          )
          .then(delay: 80.ms)
          .scale(
            duration: 480.ms,
            begin: const Offset(1.014, 1.014),
            end: const Offset(1, 1),
            curve: Curves.easeInOutCubic,
          );
    }

    return core;
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

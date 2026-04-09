import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_assessment/emvo_assessment.dart';
import 'package:emvo_ui/emvo_ui.dart';

import '../providers/eq_action_plan_provider.dart';
import '../retention/action_plan_unlock.dart';

/// Full habit-style block on the results screen (below EQ analysis).
class EqWeeklyActionPlanCard extends ConsumerStatefulWidget {
  const EqWeeklyActionPlanCard({
    super.key,
    required this.resultId,
    required this.actionTexts,
  });

  final String resultId;
  final List<String> actionTexts;

  @override
  ConsumerState<EqWeeklyActionPlanCard> createState() =>
      _EqWeeklyActionPlanCardState();
}

class _EqWeeklyActionPlanCardState
    extends ConsumerState<EqWeeklyActionPlanCard> {
  void _syncAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(eqActionPlanProvider.notifier)
          .syncFromNarrative(widget.resultId, widget.actionTexts);
    });
  }

  @override
  void initState() {
    super.initState();
    // Updating global providers in initState can notify during mount and trip
    // `element._lifecycleState == active` — defer until after the frame.
    _syncAfterFrame();
  }

  @override
  void didUpdateWidget(covariant EqWeeklyActionPlanCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resultId != widget.resultId ||
        !listEquals(oldWidget.actionTexts, widget.actionTexts)) {
      _syncAfterFrame();
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(
      eqActionPlanProvider.select((m) => m[widget.resultId]),
    );
    if (plan == null) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    final anchor = planUnlockAnchor(ref, widget.resultId);
    final visible = actionPlanVisibleHabitCount(anchor);
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(EmvoDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.task_alt_rounded, color: scheme.primary, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This week’s action plan',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Habits unlock week by week so you can focus. Tap a row when you complete it — '
                      'progress syncs to your dashboard.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.65),
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: plan.progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor:
                  scheme.surfaceContainerHighest.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${plan.completedCount} of 3 completed · $visible of 3 unlocked',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < 3; i++)
            _ActionPlanRow(
              index: i,
              text: plan.items[i],
              done: i < plan.done.length && plan.done[i],
              locked: i >= visible,
              unlockHint: actionPlanUnlockHint(anchor, i),
              onToggle: () {
                if (i >= visible) return;
                HapticFeedback.lightImpact();
                ref
                    .read(eqActionPlanProvider.notifier)
                    .toggleDone(widget.resultId, i);
              },
            ),
        ],
      ),
    );
  }
}

class _ActionPlanRow extends StatelessWidget {
  const _ActionPlanRow({
    required this.index,
    required this.text,
    required this.done,
    required this.onToggle,
    this.locked = false,
    this.unlockHint = '',
  });

  final int index;
  final String text;
  final bool done;
  final VoidCallback onToggle;
  final bool locked;
  final String unlockHint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: locked
            ? scheme.surfaceContainerHighest.withValues(alpha: 0.2)
            : done
                ? EmvoColors.success.withValues(alpha: 0.12)
                : scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? EmvoColors.success
                        : locked
                            ? scheme.outline.withValues(alpha: 0.25)
                            : Colors.transparent,
                    border: Border.all(
                      color: done
                          ? EmvoColors.success
                          : scheme.outline.withValues(alpha: 0.45),
                      width: 2,
                    ),
                  ),
                  child: locked
                      ? Icon(
                          Icons.lock_outline,
                          size: 16,
                          color: scheme.onSurface.withValues(alpha: 0.45),
                        )
                      : done
                          ? const Icon(Icons.check,
                              size: 18, color: Colors.white)
                          : Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      scheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.4,
                              decoration: done
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: scheme.onSurface.withValues(
                                alpha: locked
                                    ? 0.45
                                    : done
                                        ? 0.5
                                        : 0.92,
                              ),
                            ),
                      ),
                      if (locked && unlockHint.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          unlockHint,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: scheme.primary.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact summary for Home / Progress (same toggles as results).
class EqDashboardActionPlanSummary extends ConsumerStatefulWidget {
  const EqDashboardActionPlanSummary({
    super.key,
    required this.result,
  });

  final AssessmentResult result;

  @override
  ConsumerState<EqDashboardActionPlanSummary> createState() =>
      _EqDashboardActionPlanSummaryState();
}

class _EqDashboardActionPlanSummaryState
    extends ConsumerState<EqDashboardActionPlanSummary> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(eqActionPlanProvider.notifier)
          .ensureFromAssessment(widget.result);
    });
  }

  @override
  void didUpdateWidget(covariant EqDashboardActionPlanSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.result.id != widget.result.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(eqActionPlanProvider.notifier)
            .ensureFromAssessment(widget.result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(
      eqActionPlanProvider.select((m) => m[widget.result.id]),
    );
    if (plan == null) {
      // Seeding runs once post-frame from initState / didUpdateWidget — avoid
      // scheduling a callback on every build (can assert on inactive elements).
      return const SizedBox(
        height: 72,
        child: Center(
          child: EmvoLoadingIndicator(size: EmvoLoaderSize.compact),
        ),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final visible = actionPlanVisibleHabitCount(widget.result.completedAt);
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(EmvoDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.checklist_rounded, color: scheme.primary, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your focus this week',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${plan.completedCount}/3 · $visible unlocked',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Based on your latest assessment — habits unlock each week.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.58),
                ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: plan.progress.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor:
                  scheme.surfaceContainerHighest.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < 3; i++)
            _DashboardActionTile(
              text: plan.items[i],
              done: i < plan.done.length && plan.done[i],
              locked: i >= visible,
              unlockHint: actionPlanUnlockHint(widget.result.completedAt, i),
              onTap: () {
                if (i >= visible) return;
                HapticFeedback.lightImpact();
                ref
                    .read(eqActionPlanProvider.notifier)
                    .toggleDone(widget.result.id, i);
              },
            ),
        ],
      ),
    );
  }
}

class _DashboardActionTile extends StatelessWidget {
  const _DashboardActionTile({
    required this.text,
    required this.done,
    required this.onTap,
    this.locked = false,
    this.unlockHint = '',
  });

  final String text;
  final bool done;
  final VoidCallback onTap;
  final bool locked;
  final String unlockHint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                locked
                    ? Icons.lock_outline
                    : done
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                size: 22,
                color: locked
                    ? scheme.outline.withValues(alpha: 0.5)
                    : done
                        ? EmvoColors.success
                        : scheme.outline.withValues(alpha: 0.55),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      maxLines: locked ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            height: 1.35,
                            decoration: done
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: scheme.onSurface.withValues(
                              alpha: locked
                                  ? 0.42
                                  : done
                                      ? 0.48
                                      : 0.88,
                            ),
                          ),
                    ),
                    if (locked && unlockHint.isNotEmpty)
                      Text(
                        unlockHint,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: scheme.primary.withValues(alpha: 0.85),
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

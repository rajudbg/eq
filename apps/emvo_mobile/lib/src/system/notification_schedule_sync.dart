import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_assessment/emvo_assessment.dart';
import 'package:emvo_core/emvo_core.dart';

import '../providers/assessment_providers.dart';
import '../providers/firebase_auth_providers.dart';
import '../providers/user_intent_provider.dart';
import '../providers/theme_settings_provider.dart';
import '../providers/upcoming_situations_provider.dart';
import '../retention/action_plan_unlock.dart';
import '../services/emvo_notification_service.dart';

DateTime _followUpAtForSituation(DateTime at) {
  final dayAfter =
      DateTime(at.year, at.month, at.day).add(const Duration(days: 1));
  return DateTime(dayAfter.year, dayAfter.month, dayAfter.day, 10, 0);
}

/// Keeps local notification schedules aligned with Riverpod state.
class NotificationScheduleSync extends ConsumerStatefulWidget {
  const NotificationScheduleSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NotificationScheduleSync> createState() =>
      _NotificationScheduleSyncState();
}

class _NotificationScheduleSyncState
    extends ConsumerState<NotificationScheduleSync> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncAll();
      _applyFirebaseCoachContext(ref.read(firebaseAuthUserProvider));
    });
  }

  void _applyFirebaseCoachContext(AsyncValue<User?> async) {
    // `currentUser` fills the gap before `authStateChanges` emits; it can be
    // stale after token refresh / remote sign-out / link upgrade — revisit when
    // account sync and forced refresh are implemented.
    // Never call [FirebaseAuth.instance] when [Firebase.apps] is empty (web /
    // failed init) — on web that throws a JS interop TypeError.
    User? user = async.valueOrNull;
    if (user == null && Firebase.apps.isNotEmpty) {
      try {
        user = FirebaseAuth.instance.currentUser;
      } catch (_) {
        return;
      }
    }
    if (user == null) return;
    ref.read(coachingRepositoryProvider).applyCoachingContext({
      'firebase': {
        'uid': user.uid,
        'isAnonymous': user.isAnonymous,
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(notificationsEnabledProvider, (_, __) => _syncAll());
    ref.listen<TimeOfDay>(dailyReminderTimeProvider, (_, __) {
      _rescheduleIfEnabled();
    });
    ref.listen<List<UpcomingSituation>>(upcomingSituationsProvider, (_, __) {
      _rescheduleIfEnabled();
    });
    ref.listen<AsyncValue<User?>>(
      firebaseAuthUserProvider,
      (_, next) => _applyFirebaseCoachContext(next),
    );
    ref.listen<AsyncValue<UserIntent?>>(userIntentProvider, (prev, next) {
      next.whenData((intent) {
        if (intent == null) return;
        ref.read(coachingRepositoryProvider).applyCoachingContext({
          'userIntent': intent.id,
          'userIntentLabel': intent.label,
        });
      });
    });
    ref.listen<AsyncValue<AssessmentResult?>>(
      latestResultProvider,
      (_, next) {
        next.whenData((AssessmentResult? result) {
          final repo = ref.read(coachingRepositoryProvider);
          if (result == null) return;
          final w = weakestDimension(result);
          repo.applyCoachingContext({
            'assessmentRetake': {
              'completedAt': result.completedAt.toIso8601String(),
              'retakeEligibleAt':
                  assessmentRetakeEligibleAt(result).toIso8601String(),
              'retakeDue': isAssessmentRetakeDue(result),
            },
            'growthEdges': {
              if (w != null) 'weakestDimension': w.name,
              if (w != null) 'weakestDimensionLabel': w.displayName,
            },
          });
        });
      },
    );
    return widget.child;
  }

  Future<void> _syncAll() async {
    final on = ref.read(notificationsEnabledProvider);
    if (!on) {
      await EmvoNotificationService.instance.cancelAll();
      return;
    }
    // Permission is requested when the user turns reminders on in Settings
    // or accepts the post-results nudge — not here (better conversion).
    await _rescheduleIfEnabled();
  }

  Future<void> _rescheduleIfEnabled() async {
    if (!ref.read(notificationsEnabledProvider)) return;
    final t = ref.read(dailyReminderTimeProvider);
    final situations = ref.read(upcomingSituationsProvider);
    await EmvoNotificationService.instance.rescheduleAllWithBudget(
      dailyReminder: t,
      situations: [
        for (final s in situations)
          (
            id: s.id,
            title: s.title,
            at: s.at,
            followUpAt: _followUpAtForSituation(s.at),
          ),
      ],
    );
  }
}

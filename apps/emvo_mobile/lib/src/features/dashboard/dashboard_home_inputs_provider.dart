import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_core/emvo_core.dart';

import '../../providers/assessment_providers.dart';
import '../../providers/daily_checkin_provider.dart';
import '../../providers/profile_display_name_provider.dart';
import '../../providers/retake_banner_snooze_provider.dart';
import '../../providers/upcoming_situations_provider.dart';
import '../../retention/action_plan_unlock.dart';
import 'dashboard_home_state.dart';

/// Single rebuild surface for Home: all [DashboardHomeInputs] + [computeDashboardLayout].
@immutable
class DashboardHomeDerived {
  const DashboardHomeDerived({
    required this.inputs,
    required this.layout,
  });

  final DashboardHomeInputs inputs;
  final DashboardHomeLayout layout;
}

bool _retakeSnoozed(DateTime? until) =>
    until != null && until.isAfter(DateTime.now());

/// Async only because assessment history loads from storage.
final dashboardHomeDerivedProvider =
    Provider<AsyncValue<DashboardHomeDerived>>((ref) {
  final historyAsync = ref.watch(assessmentHistoryProvider);

  if (historyAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (historyAsync.hasError) {
    return AsyncValue.error(
      historyAsync.error!,
      historyAsync.stackTrace ?? StackTrace.empty,
    );
  }

  final history = historyAsync.requireValue;
  final latestAsync = ref.watch(latestResultProvider);
  final result = latestAsync.valueOrNull;

  final inputs = DashboardHomeInputs(
    now: DateTime.now(),
    displayName: ref.watch(profileDisplayNameProvider),
    checkIn: ref.watch(dailyCheckInProvider),
    situations: ref.watch(upcomingSituationsProvider),
    latestResult: result,
    assessmentHistory: history,
    retakeDue: result != null && isAssessmentRetakeDue(result),
    retakeSnoozed: _retakeSnoozed(ref.watch(retakeBannerSnoozeProvider)),
    isPremium: ref.watch(isPremiumProvider),
  );

  return AsyncValue.data(
    DashboardHomeDerived(
      inputs: inputs,
      layout: computeDashboardLayout(inputs),
    ),
  );
});

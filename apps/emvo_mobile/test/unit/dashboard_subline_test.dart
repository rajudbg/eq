import 'package:flutter_test/flutter_test.dart';
import 'package:emvo_mobile/src/features/dashboard/dashboard_home_state.dart';

void main() {
  group('resolveDashboardSubline precedence', () {
    test('retake beats everything else', () {
      final r = resolveDashboardSubline(
        retakeShow: true,
        tomorrowTitle: 'Board meeting',
        reflectedToday: false,
        urgentTitle: 'Pitch',
        streak: 14,
        needCheckIn: true,
        recovery: true,
      );
      expect(r.rule, DashboardSublinePrecedence.retakeDue);
    });

    test('tomorrow beats urgent and milestone', () {
      final r = resolveDashboardSubline(
        retakeShow: false,
        tomorrowTitle: '1:1',
        reflectedToday: false,
        urgentTitle: 'Big pitch',
        streak: 7,
        needCheckIn: true,
        recovery: true,
      );
      expect(r.rule, DashboardSublinePrecedence.situationTomorrow);
    });

    test('reflected today beats urgent and milestone', () {
      final r = resolveDashboardSubline(
        retakeShow: false,
        tomorrowTitle: null,
        reflectedToday: true,
        urgentTitle: 'Interview',
        streak: 14,
        needCheckIn: false,
        recovery: false,
      );
      expect(r.rule, DashboardSublinePrecedence.reflectedToday);
    });

    test('urgent beats streak milestone when check-in still needed', () {
      final r = resolveDashboardSubline(
        retakeShow: false,
        tomorrowTitle: null,
        reflectedToday: false,
        urgentTitle: 'Surgery',
        streak: 7,
        needCheckIn: true,
        recovery: false,
      );
      expect(r.rule, DashboardSublinePrecedence.urgentSituation);
    });

    test('milestone beats recovery', () {
      final r = resolveDashboardSubline(
        retakeShow: false,
        tomorrowTitle: null,
        reflectedToday: false,
        urgentTitle: null,
        streak: 14,
        needCheckIn: true,
        recovery: true,
      );
      expect(r.rule, DashboardSublinePrecedence.streakMilestone);
    });

    test('recovery beats plain needCheckIn', () {
      final r = resolveDashboardSubline(
        retakeShow: false,
        tomorrowTitle: null,
        reflectedToday: false,
        urgentTitle: null,
        streak: 3,
        needCheckIn: true,
        recovery: true,
      );
      expect(r.rule, DashboardSublinePrecedence.checkInRecovery);
    });
  });
}

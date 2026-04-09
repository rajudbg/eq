import 'package:emvo_assessment/emvo_assessment.dart';

import '../../providers/daily_checkin_provider.dart';
import '../../providers/upcoming_situations_provider.dart';

/// Ordered blocks on Home — computed from journey state (no I/O).
enum HomeDashboardSection {
  retakeBanner,
  dailyCheckIn,
  microLearning,
  eqChallenge,
  weeklyPulse,
  upcomingSituations,
  scoreSnapshot,
  weeklyActionPlan,
  premiumUpsell,
  eqProgress,
  quickActions,
  recentInsights,
}

/// Inputs snapshot for [computeDashboardLayout] (assemble in UI from providers).
class DashboardHomeInputs {
  const DashboardHomeInputs({
    required this.now,
    this.displayName,
    required this.checkIn,
    required this.situations,
    required this.latestResult,
    required this.assessmentHistory,
    required this.retakeDue,
    required this.retakeSnoozed,
    required this.isPremium,
    this.pulseCompletedThisWeek = false,
  });

  final DateTime now;
  final String? displayName;
  final DailyCheckInState checkIn;
  final List<UpcomingSituation> situations;
  final AssessmentResult? latestResult;
  final List<AssessmentResult> assessmentHistory;
  final bool retakeDue;
  final bool retakeSnoozed;
  final bool isPremium;
  final bool pulseCompletedThisWeek;
}

class DashboardHomeLayout {
  const DashboardHomeLayout({
    required this.greetingPrefix,
    required this.headline,
    required this.subline,
    required this.metaLine,
    required this.primaryCtaHint,
    required this.sections,
  });

  /// e.g. "Good morning" (no comma)
  final String greetingPrefix;
  final String headline;
  final String subline;

  /// Day N · check-in streak (or partial).
  final String? metaLine;
  final String? primaryCtaHint;
  final List<HomeDashboardSection> sections;
}

int? journeyDayNumber(DateTime now, List<AssessmentResult> historyOldestFirst) {
  if (historyOldestFirst.isEmpty) return null;
  final first = historyOldestFirst.first.completedAt.toLocal();
  final start = DateTime(first.year, first.month, first.day);
  final today = DateTime(now.year, now.month, now.day);
  final d = today.difference(start).inDays;
  return d + 1;
}

bool _urgentUpcoming(UpcomingSituation s, DateTime now) {
  if (s.isPast) return false;
  final end = now.add(const Duration(hours: 48));
  return !s.at.isBefore(now) && s.at.isBefore(end);
}

UpcomingSituation? _nextUrgentSituation(
    List<UpcomingSituation> list, DateTime now) {
  final urgent = list.where((s) => _urgentUpcoming(s, now)).toList();
  if (urgent.isEmpty) return null;
  urgent.sort((a, b) => a.at.compareTo(b.at));
  return urgent.first;
}

bool _situationTomorrow(UpcomingSituation s, DateTime now) {
  if (s.isPast) return false;
  final l = now.toLocal();
  final t = DateTime(l.year, l.month, l.day);
  final tomorrow = t.add(const Duration(days: 1));
  final a = s.at.toLocal();
  final ad = DateTime(a.year, a.month, a.day);
  return ad == tomorrow;
}

bool suggestCheckInRecovery(DailyCheckInState s) {
  if (s.today != null || s.recentEntries.isEmpty) return false;
  final last = s.recentEntries.first;
  final parts = last.localDate.split('-');
  if (parts.length != 3) return false;
  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null) return false;
  final lastDay = DateTime(y, m, d);
  final today = DateTime.now();
  final todayD = DateTime(today.year, today.month, today.day);
  final daysSince = todayD.difference(lastDay).inDays;
  return daysSince >= 2;
}

/// Auditable precedence for the Home hero **subline** (first match wins).
///
/// 1. [retakeDue] — 30-day remeasure
/// 2. [situationTomorrow] — calendar tomorrow (specific prep beats generic urgent)
/// 3. [reflectedToday] — already checked in
/// 4. [urgentSituation] — within next 48h (not covered by tomorrow branch)
/// 5. [streakMilestone] — multiple of 7, still need today’s check-in
/// 6. [checkInRecovery] — grace exhausted / gap, need check-in
/// 7. [needCheckIn] — default morning nudge
/// 8. [fallback] — generic
enum DashboardSublinePrecedence {
  retakeDue,
  situationTomorrow,
  reflectedToday,
  urgentSituation,
  streakMilestone,
  checkInRecovery,
  needCheckIn,
  fallback,
}

/// Returns chosen rule (for tests / logging) plus copy.
({DashboardSublinePrecedence rule, String subline, String? primaryCtaHint})
    resolveDashboardSubline({
  required bool retakeShow,
  required String? tomorrowTitle,
  required bool reflectedToday,
  required String? urgentTitle,
  required int streak,
  required bool needCheckIn,
  required bool recovery,
}) {
  if (retakeShow) {
    return (
      rule: DashboardSublinePrecedence.retakeDue,
      subline:
          'Ready to see how far you have come? Your 30-day remeasure is here.',
      primaryCtaHint: 'Retake assessment',
    );
  }
  if (tomorrowTitle != null) {
    return (
      rule: DashboardSublinePrecedence.situationTomorrow,
      subline: 'Your "$tomorrowTitle" is tomorrow. How are you feeling?',
      primaryCtaHint: 'Reflect or talk to Coach',
    );
  }
  if (reflectedToday) {
    return (
      rule: DashboardSublinePrecedence.reflectedToday,
      subline: 'You reflected today. That is the work.',
      primaryCtaHint: null,
    );
  }
  if (urgentTitle != null) {
    return (
      rule: DashboardSublinePrecedence.urgentSituation,
      subline:
          'Something big is coming up — "$urgentTitle". Want a quick prep?',
      primaryCtaHint: 'Prepare with Coach',
    );
  }
  if (streak >= 7 && streak % 7 == 0 && needCheckIn) {
    return (
      rule: DashboardSublinePrecedence.streakMilestone,
      subline:
          '$streak days straight. Most people do not stick with it — keep going?',
      primaryCtaHint: 'Today\'s check-in',
    );
  }
  if (recovery && needCheckIn) {
    return (
      rule: DashboardSublinePrecedence.checkInRecovery,
      subline: 'Every streak restarts somewhere. Want a 30-second check-in?',
      primaryCtaHint: 'Check in',
    );
  }
  if (needCheckIn) {
    return (
      rule: DashboardSublinePrecedence.needCheckIn,
      subline: 'How are you walking into today?',
      primaryCtaHint: 'Today\'s check-in',
    );
  }
  return (
    rule: DashboardSublinePrecedence.fallback,
    subline: 'One small reflection keeps your EQ sharp.',
    primaryCtaHint: null,
  );
}

DashboardHomeLayout computeDashboardLayout(DashboardHomeInputs in_) {
  final now = in_.now.toLocal();
  final hour = now.hour;
  final greetingPrefix = hour < 12
      ? 'Good morning'
      : hour < 17
          ? 'Good afternoon'
          : 'Good evening';

  final trimmedName = in_.displayName?.trim();
  final firstName = (trimmedName != null && trimmedName.isNotEmpty)
      ? trimmedName.split(RegExp(r'\s+')).first
      : null;
  final headline =
      firstName != null ? '$greetingPrefix, $firstName.' : '$greetingPrefix.';

  final journey = journeyDayNumber(now, in_.assessmentHistory);
  final streak = in_.checkIn.streakDays;
  String? metaLine;
  if (journey != null && journey > 0) {
    if (streak > 0) {
      metaLine = 'Day $journey · ${streak}d check-in streak';
    } else {
      metaLine = 'Day $journey on your journey';
    }
  } else if (streak > 0) {
    metaLine = '${streak}d check-in streak';
  }

  final urgent = _nextUrgentSituation(in_.situations, now);
  final urgentTitle = urgent?.title;
  final needCheckIn = in_.checkIn.today == null;
  final retakeShow = in_.retakeDue && !in_.retakeSnoozed;
  final recovery = suggestCheckInRecovery(in_.checkIn);

  final tomorrowSorted = in_.situations
      .where((s) => !s.isPast && _situationTomorrow(s, now))
      .toList()
    ..sort((a, b) => a.at.compareTo(b.at));
  final tomorrowTitle =
      tomorrowSorted.isNotEmpty ? tomorrowSorted.first.title : null;

  final sub = resolveDashboardSubline(
    retakeShow: retakeShow,
    tomorrowTitle: tomorrowTitle,
    reflectedToday: in_.checkIn.today != null,
    urgentTitle: urgentTitle,
    streak: streak,
    needCheckIn: needCheckIn,
    recovery: recovery,
  );
  final subline = sub.subline;
  final primaryCtaHint = sub.primaryCtaHint;

  final sections = <HomeDashboardSection>[];

  if (retakeShow) {
    sections.add(HomeDashboardSection.retakeBanner);
  }
  if (needCheckIn) {
    sections.add(HomeDashboardSection.dailyCheckIn);
  }
  if (urgent != null) {
    sections.add(HomeDashboardSection.upcomingSituations);
  }

  // Micro-learning: always show for daily engagement.
  sections.add(HomeDashboardSection.microLearning);

  // Monthly challenge: always show.
  sections.add(HomeDashboardSection.eqChallenge);

  if (in_.latestResult != null) {
    sections.add(HomeDashboardSection.scoreSnapshot);

    // Weekly pulse: show when not yet completed this week.
    if (!in_.pulseCompletedThisWeek) {
      sections.add(HomeDashboardSection.weeklyPulse);
    }

    sections.add(HomeDashboardSection.weeklyActionPlan);
  }

  if (!in_.isPremium) {
    sections.add(HomeDashboardSection.premiumUpsell);
  }

  if (in_.latestResult != null) {
    sections.add(HomeDashboardSection.eqProgress);
  }

  if (urgent == null) {
    sections.add(HomeDashboardSection.upcomingSituations);
  }
  if (!needCheckIn) {
    sections.add(HomeDashboardSection.dailyCheckIn);
  }

  sections.add(HomeDashboardSection.quickActions);
  sections.add(HomeDashboardSection.recentInsights);

  return DashboardHomeLayout(
    greetingPrefix: greetingPrefix,
    headline: headline,
    subline: subline,
    metaLine: metaLine,
    primaryCtaHint: primaryCtaHint,
    sections: sections,
  );
}

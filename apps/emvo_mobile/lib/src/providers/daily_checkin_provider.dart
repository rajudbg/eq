import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_core/emvo_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/coaching/coaching_providers.dart';

const _kMood = 'daily_checkin.mood';
const _kDay = 'daily_checkin.local_date';

String _localDateString(DateTime d) {
  final l = d.toLocal();
  final m = l.month.toString().padLeft(2, '0');
  final day = l.day.toString().padLeft(2, '0');
  return '${l.year}-$m-$day';
}

/// Today’s self-reported mood from the home Daily Check-in (calendar day).
class DailyCheckIn {
  const DailyCheckIn({
    required this.moodLabel,
    required this.localDate,
  });

  final String moodLabel;
  final String localDate;
}

class DailyCheckInNotifier extends StateNotifier<DailyCheckIn?> {
  DailyCheckInNotifier(this._ref) : super(null) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final storedDay = prefs.getString(_kDay);
    final mood = prefs.getString(_kMood);
    final today = _localDateString(DateTime.now());
    if (mood == null ||
        mood.isEmpty ||
        storedDay == null ||
        storedDay != today) {
      state = null;
      return;
    }
    state = DailyCheckIn(moodLabel: mood, localDate: storedDay);
    _pushToCoaching(mood, storedDay);
    _invalidateCoachUi();
  }

  void _pushToCoaching(String moodLabel, String localDate) {
    _ref.read(coachingRepositoryProvider).applyCoachingContext({
      'dailyCheckIn': {
        'moodLabel': moodLabel,
        'localDate': localDate,
      },
    });
  }

  void _invalidateCoachUi() {
    _ref.invalidate(coachingSessionProvider);
    _ref.invalidate(suggestedPromptsProvider);
  }

  /// Persists check-in for today and merges into active coaching session context.
  Future<void> recordMood(String moodLabel) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _localDateString(DateTime.now());
    await prefs.setString(_kDay, today);
    await prefs.setString(_kMood, moodLabel);

    state = DailyCheckIn(moodLabel: moodLabel, localDate: today);

    _ref.read(coachingRepositoryProvider).applyCoachingContext({
      'dailyCheckIn': {
        'moodLabel': moodLabel,
        'localDate': today,
        'checkedInAt': DateTime.now().toIso8601String(),
      },
    });
    _invalidateCoachUi();
  }

  Future<void> refreshFromStorage() => _load();
}

final dailyCheckInProvider =
    StateNotifierProvider<DailyCheckInNotifier, DailyCheckIn?>((ref) {
  return DailyCheckInNotifier(ref);
});

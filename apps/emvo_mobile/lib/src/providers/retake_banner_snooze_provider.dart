import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kSnoozeUntil = 'retake_banner.snooze_until_iso';

class RetakeBannerSnoozeNotifier extends StateNotifier<DateTime?> {
  RetakeBannerSnoozeNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSnoozeUntil);
    if (raw == null || raw.isEmpty) {
      state = null;
      return;
    }
    final t = DateTime.tryParse(raw);
    if (t == null || !t.isAfter(DateTime.now())) {
      state = null;
      await prefs.remove(_kSnoozeUntil);
      return;
    }
    state = t;
  }

  /// Hide the 30-day retake banner for 7 days.
  Future<void> snoozeOneWeek() async {
    final until = DateTime.now().add(const Duration(days: 7));
    state = until;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSnoozeUntil, until.toIso8601String());
  }

  bool get isSnoozed => state != null && state!.isAfter(DateTime.now());
}

final retakeBannerSnoozeProvider =
    StateNotifierProvider<RetakeBannerSnoozeNotifier, DateTime?>((ref) {
  return RetakeBannerSnoozeNotifier();
});

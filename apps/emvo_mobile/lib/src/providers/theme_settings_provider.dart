import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/emvo_notification_service.dart';

const _kThemeMode = 'settings.theme_mode';
const _kCoachConcise = 'settings.coach_concise_replies';
const _kNotifications = 'settings.notifications_enabled';
const _kDailyReminderHour = 'settings.daily_reminder_hour';
const _kDailyReminderMinute = 'settings.daily_reminder_minute';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kThemeMode);
    state = switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kThemeMode,
      switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      },
    );
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class CoachConciseNotifier extends StateNotifier<bool> {
  CoachConciseNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_kCoachConcise) ?? false;
  }

  Future<void> setConcise(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kCoachConcise, value);
  }
}

final coachConciseRepliesProvider =
    StateNotifierProvider<CoachConciseNotifier, bool>((ref) {
  return CoachConciseNotifier();
});

class NotificationsSettingNotifier extends StateNotifier<bool> {
  NotificationsSettingNotifier() : super(true) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_kNotifications) ?? true;
  }

  Future<void> setEnabled(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotifications, value);
    if (value) {
      await EmvoNotificationService.instance.ensureRuntimePermissions();
    }
  }
}

final notificationsEnabledProvider =
    StateNotifierProvider<NotificationsSettingNotifier, bool>((ref) {
  return NotificationsSettingNotifier();
});

/// Local time for the daily EQ check-in notification (when master switch is on).
class DailyReminderTimeNotifier extends StateNotifier<TimeOfDay> {
  DailyReminderTimeNotifier() : super(const TimeOfDay(hour: 9, minute: 0)) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final h = prefs.getInt(_kDailyReminderHour);
    final m = prefs.getInt(_kDailyReminderMinute);
    if (h != null && m != null && h >= 0 && h < 24 && m >= 0 && m < 60) {
      state = TimeOfDay(hour: h, minute: m);
    }
  }

  Future<void> setTime(TimeOfDay t) async {
    state = t;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kDailyReminderHour, t.hour);
    await prefs.setInt(_kDailyReminderMinute, t.minute);
  }
}

final dailyReminderTimeProvider =
    StateNotifierProvider<DailyReminderTimeNotifier, TimeOfDay>((ref) {
  return DailyReminderTimeNotifier();
});

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Situation reminder IDs start here; daily budget slots use [_kDailyIdStart]..[_kDailyIdEnd].
const _kDailyIdStart = 91001;
const _kDailyIdEnd = 91128;
const _kSituationBaseId = 92000;

/// Max local notifications scheduled for the same calendar day (fatigue guard).
const kEmvoMaxNotificationsPerDay = 2;

class _ScheduledPing {
  _ScheduledPing({
    required this.id,
    required this.when,
    required this.priority,
    required this.title,
    required this.body,
    required this.androidChannelId,
    required this.androidChannelName,
    required this.androidDescription,
    required this.importance,
  });

  final int id;
  final tz.TZDateTime when;
  final int priority;
  final String title;
  final String body;
  final String androidChannelId;
  final String androidChannelName;
  final String androidDescription;
  final Importance importance;
}

/// Schedules reminders with a per-day cap (priority: situation pre > follow-up > daily).
class EmvoNotificationService {
  EmvoNotificationService._();
  static final EmvoNotificationService instance = EmvoNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (kIsWeb || _initialized) return;

    tz_data.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(
        android: android,
        iOS: ios,
        macOS: DarwinInitializationSettings(),
      ),
    );
    _initialized = true;
  }

  Future<bool> ensureRuntimePermissions() async {
    if (kIsWeb) return false;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
    return granted ?? true;
  }

  int _situationPreId(String situationId) =>
      _kSituationBaseId + (situationId.hashCode & 0xfff);

  int _situationFollowUpId(String situationId) =>
      _kSituationBaseId + 0x1000 + (situationId.hashCode & 0xfff);

  Future<void> _cancelIdRange(int from, int to) async {
    if (kIsWeb) return;
    for (var id = from; id <= to; id++) {
      await _plugin.cancel(id);
    }
  }

  /// Cancels all Emvo-scheduled IDs, then applies [kEmvoMaxNotificationsPerDay]
  /// per calendar day (local) by priority.
  Future<void> rescheduleAllWithBudget({
    required TimeOfDay dailyReminder,
    required List<({String id, String title, DateTime at, DateTime followUpAt})>
        situations,
  }) async {
    if (kIsWeb || !_initialized) return;

    await _cancelIdRange(_kDailyIdStart, _kDailyIdEnd);
    await _cancelIdRange(_kSituationBaseId, _kSituationBaseId + 0x1fff);

    final nowLocal = DateTime.now();
    final pings = <_ScheduledPing>[];

    for (final s in situations) {
      final preAt = s.at.subtract(const Duration(hours: 1));
      final preSchedule = preAt.isAfter(nowLocal) ? preAt : s.at;
      if (preSchedule.isAfter(nowLocal)) {
        pings.add(
          _ScheduledPing(
            id: _situationPreId(s.id),
            when: tz.TZDateTime.from(preSchedule, tz.local),
            priority: 30,
            title: 'Coming up: ${s.title}',
            body: 'Take a breath — you planned to use your EQ skills here.',
            androidChannelId: 'emvo_situations',
            androidChannelName: 'Situation reminders',
            androidDescription: 'Reminders before situations you log in Emvo',
            importance: Importance.defaultImportance,
          ),
        );
      }
      if (s.followUpAt.isAfter(nowLocal)) {
        pings.add(
          _ScheduledPing(
            id: _situationFollowUpId(s.id),
            when: tz.TZDateTime.from(s.followUpAt, tz.local),
            priority: 20,
            title: 'How did it go?',
            body: 'Reflect on “${s.title}” — open Emvo when you can.',
            androidChannelId: 'emvo_situations',
            androidChannelName: 'Situation reminders',
            androidDescription: 'Follow-ups after situations you log',
            importance: Importance.defaultImportance,
          ),
        );
      }
    }

    const lookaheadDays = 14;
    var slot = 0;
    for (var i = 0; i < lookaheadDays; i++) {
      final day = DateTime(nowLocal.year, nowLocal.month, nowLocal.day)
          .add(Duration(days: i));
      var scheduled = DateTime(
        day.year,
        day.month,
        day.day,
        dailyReminder.hour,
        dailyReminder.minute,
      );
      if (!scheduled.isAfter(nowLocal)) continue;
      if (slot >= _kDailyIdEnd - _kDailyIdStart) break;
      pings.add(
        _ScheduledPing(
          id: _kDailyIdStart + slot,
          when: tz.TZDateTime.from(scheduled, tz.local),
          priority: 10,
          title: 'Daily EQ check-in',
          body:
              'Name one emotion you felt strongly today — it takes under a minute.',
          androidChannelId: 'emvo_daily',
          androidChannelName: 'Daily check-in',
          androidDescription: 'Gentle daily EQ micro-prompts',
          importance: Importance.low,
        ),
      );
      slot++;
    }

    final byDay = <String, List<_ScheduledPing>>{};
    for (final p in pings) {
      final d = p.when;
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      byDay.putIfAbsent(key, () => []).add(p);
    }

    for (final entry in byDay.entries) {
      final list = entry.value
        ..sort((a, b) => b.priority.compareTo(a.priority));
      final kept = list.take(kEmvoMaxNotificationsPerDay).toList();
      for (final p in kept) {
        await _plugin.zonedSchedule(
          p.id,
          p.title,
          p.body,
          p.when,
          NotificationDetails(
            android: AndroidNotificationDetails(
              p.androidChannelId,
              p.androidChannelName,
              channelDescription: p.androidDescription,
              importance: p.importance,
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }
}

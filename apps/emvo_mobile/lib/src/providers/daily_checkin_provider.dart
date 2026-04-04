import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_core/emvo_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/coaching/coaching_providers.dart'
    show coachingSessionProvider, suggestedPromptsProvider;

const _kMood = 'daily_checkin.mood';
const _kDay = 'daily_checkin.local_date';
const _kNote = 'daily_checkin.note';
const _kPromptId = 'daily_checkin.prompt_id';
const _kPromptText = 'daily_checkin.prompt_text';
const _kHistory = 'daily_checkin.history_json';
const _kMaxNoteChars = 50;
const _kMaxHistoryEntries = 14;

String _localDateString(DateTime d) {
  final l = d.toLocal();
  final m = l.month.toString().padLeft(2, '0');
  final day = l.day.toString().padLeft(2, '0');
  return '${l.year}-$m-$day';
}

/// Rotating micro-prompts (one primary line + id for analytics/coach).
final dailyCheckInPrompts = <MapEntry<String, String>>[
  const MapEntry(
    'emotion_one',
    'Name one emotion you felt strongly today.',
  ),
  const MapEntry(
    'read_room',
    'Rate how well you read the room in your last conversation (1–10 mentally).',
  ),
  const MapEntry(
    'trigger',
    'What usually triggers your stress first — people, time pressure, or uncertainty?',
  ),
  const MapEntry(
    'repair',
    'Did you repair or avoid after tension today? One sentence.',
  ),
  const MapEntry(
    'empathy_guess',
    'Guess one feeling someone else showed today without them naming it.',
  ),
  const MapEntry(
    'pause',
    'Where could you have paused one breath longer before responding?',
  ),
  const MapEntry(
    'proud',
    'What’s one small EQ win from today, even if tiny?',
  ),
];

int _dayOfYear(DateTime d) => d.difference(DateTime(d.year, 1, 1)).inDays;

MapEntry<String, String> dailyPromptForDate(DateTime date) {
  final i =
      (date.year * 400 + _dayOfYear(date)).abs() % dailyCheckInPrompts.length;
  return dailyCheckInPrompts[i];
}

class DailyCheckInEntry {
  const DailyCheckInEntry({
    required this.localDate,
    required this.moodLabel,
    this.note,
    this.promptId,
    this.promptText,
  });

  final String localDate;
  final String moodLabel;
  final String? note;
  final String? promptId;
  final String? promptText;

  Map<String, dynamic> toJson() => {
        'localDate': localDate,
        'moodLabel': moodLabel,
        'note': note,
        'promptId': promptId,
        'promptText': promptText,
      };

  static DailyCheckInEntry? fromJsonMap(Map<String, dynamic>? m) {
    if (m == null) return null;
    final d = m['localDate']?.toString();
    final mood = m['moodLabel']?.toString();
    if (d == null || mood == null) return null;
    return DailyCheckInEntry(
      localDate: d,
      moodLabel: mood,
      note: _capNoteStatic(m['note']?.toString()),
      promptId: m['promptId']?.toString(),
      promptText: m['promptText']?.toString(),
    );
  }
}

String? _capNoteStatic(String? raw) {
  if (raw == null) return null;
  final t = raw.trim();
  if (t.isEmpty) return null;
  if (t.length <= _kMaxNoteChars) return t;
  return t.substring(0, _kMaxNoteChars);
}

/// Today’s check-in plus streak; history feeds the coach.
class DailyCheckInState {
  const DailyCheckInState({
    this.today,
    this.streakDays = 0,
    this.recentEntries = const [],
  });

  final DailyCheckInEntry? today;
  final int streakDays;
  final List<DailyCheckInEntry> recentEntries;

  String? get moodLabel => today?.moodLabel;
  String? get localDate => today?.localDate;
}

class DailyCheckInNotifier extends StateNotifier<DailyCheckInState> {
  DailyCheckInNotifier(this._ref) : super(const DailyCheckInState()) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final historyRaw = prefs.getString(_kHistory);
    var history = <DailyCheckInEntry>[];
    if (historyRaw != null && historyRaw.isNotEmpty) {
      try {
        final list = jsonDecode(historyRaw) as List<dynamic>;
        history = list
            .whereType<Map>()
            .map(
              (e) => DailyCheckInEntry.fromJsonMap(
                Map<String, dynamic>.from(e),
              ),
            )
            .whereType<DailyCheckInEntry>()
            .toList();
        final trimmed =
            history.sortedByDateDesc().take(_kMaxHistoryEntries).toList();
        if (trimmed.length != history.length) {
          history = trimmed;
          await prefs.setString(
            _kHistory,
            jsonEncode(history.map((e) => e.toJson()).toList()),
          );
        } else {
          history = trimmed;
        }
      } catch (_) {}
    }

    final storedDay = prefs.getString(_kDay);
    final mood = prefs.getString(_kMood);
    final today = _localDateString(DateTime.now());
    DailyCheckInEntry? todayEntry;
    if (mood != null &&
        mood.isNotEmpty &&
        storedDay != null &&
        storedDay == today) {
      todayEntry = DailyCheckInEntry(
        localDate: storedDay,
        moodLabel: mood,
        note: _capNoteStatic(prefs.getString(_kNote)),
        promptId: prefs.getString(_kPromptId),
        promptText: prefs.getString(_kPromptText),
      );
    }

    final streak = _streakFromHistory(history, todayEntry);
    state = DailyCheckInState(
      today: todayEntry,
      streakDays: streak,
      recentEntries: history,
    );
    _pushToCoaching();
  }

  int _streakFromHistory(
    List<DailyCheckInEntry> history,
    DailyCheckInEntry? todayEntry,
  ) {
    final days = <String>{for (final e in history) e.localDate};
    if (todayEntry != null) days.add(todayEntry.localDate);
    if (days.isEmpty) return 0;

    var cursorDay =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    var key = _localDateString(cursorDay);
    if (!days.contains(key)) {
      cursorDay = cursorDay.subtract(const Duration(days: 1));
      key = _localDateString(cursorDay);
    }
    var streak = 0;
    var graceDaysLeft = 1;
    while (true) {
      if (days.contains(key)) {
        streak++;
        cursorDay = cursorDay.subtract(const Duration(days: 1));
        key = _localDateString(cursorDay);
        continue;
      }
      if (graceDaysLeft > 0) {
        graceDaysLeft--;
        cursorDay = cursorDay.subtract(const Duration(days: 1));
        key = _localDateString(cursorDay);
        continue;
      }
      break;
    }
    return streak;
  }

  void _pushToCoaching() {
    final t = state.today;
    final recent = state.recentEntries
        .sortedByDateDesc()
        .take(7)
        .map((e) => e.toJson())
        .toList();
    _ref.read(coachingRepositoryProvider).applyCoachingContext({
      'dailyCheckIn': {
        if (t != null) ...{
          'moodLabel': t.moodLabel,
          'localDate': t.localDate,
          'note': t.note,
          'promptId': t.promptId,
          'promptText': t.promptText,
        },
        'streakDays': state.streakDays,
        'recentCheckIns': recent,
      },
    });
  }

  void _invalidateCoachUi() {
    _ref.invalidate(coachingSessionProvider);
    _ref.invalidate(suggestedPromptsProvider);
  }

  Future<void> refreshFromStorage() => _load();

  Future<void> recordMood(
    String moodLabel, {
    String? note,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _localDateString(DateTime.now());
    final prompt = dailyPromptForDate(DateTime.now());

    final rawNote = note?.trim();
    final capped = (rawNote == null || rawNote.isEmpty)
        ? null
        : (rawNote.length > _kMaxNoteChars
            ? rawNote.substring(0, _kMaxNoteChars)
            : rawNote);

    await prefs.setString(_kDay, today);
    await prefs.setString(_kMood, moodLabel);
    if (capped != null) {
      await prefs.setString(_kNote, capped);
    } else {
      await prefs.remove(_kNote);
    }
    await prefs.setString(_kPromptId, prompt.key);
    await prefs.setString(_kPromptText, prompt.value);

    final entry = DailyCheckInEntry(
      localDate: today,
      moodLabel: moodLabel,
      note: capped,
      promptId: prompt.key,
      promptText: prompt.value,
    );

    var history = List<DailyCheckInEntry>.from(
      state.recentEntries.where((e) => e.localDate != today),
    );
    history.add(entry);
    history = history.sortedByDateDesc().take(_kMaxHistoryEntries).toList();
    await prefs.setString(
      _kHistory,
      jsonEncode(history.map((e) => e.toJson()).toList()),
    );

    final streak = _streakFromHistory(history, entry);
    state = DailyCheckInState(
      today: entry,
      streakDays: streak,
      recentEntries: history,
    );

    _ref.read(coachingRepositoryProvider).applyCoachingContext({
      'dailyCheckIn': {
        'moodLabel': moodLabel,
        'localDate': today,
        'note': entry.note,
        'promptId': prompt.key,
        'promptText': prompt.value,
        'checkedInAt': DateTime.now().toIso8601String(),
        'streakDays': streak,
        'recentCheckIns':
            history.sortedByDateDesc().take(7).map((e) => e.toJson()).toList(),
      },
    });
    _invalidateCoachUi();
  }
}

extension on List<DailyCheckInEntry> {
  List<DailyCheckInEntry> sortedByDateDesc() {
    final copy = List<DailyCheckInEntry>.from(this);
    copy.sort((a, b) => b.localDate.compareTo(a.localDate));
    return copy;
  }
}

final dailyCheckInProvider =
    StateNotifierProvider<DailyCheckInNotifier, DailyCheckInState>((ref) {
  return DailyCheckInNotifier(ref);
});

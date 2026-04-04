import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emvo_core/emvo_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kPrefsKey = 'emvo.upcoming_situations.v1';

/// Something the user is preparing for — drives reminders and coach context.
class UpcomingSituation {
  const UpcomingSituation({
    required this.id,
    required this.title,
    required this.at,
    this.note,
    this.followUpNote,
    this.followUpRecordedAtIso,
    this.preparedAtIso,
  });

  final String id;
  final String title;
  final DateTime at;
  final String? note;
  final String? followUpNote;
  final String? followUpRecordedAtIso;

  /// User tapped "I am prepared" on Home — lightweight acknowledgment.
  final String? preparedAtIso;

  bool get isPast => at.isBefore(DateTime.now());

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'at': at.toIso8601String(),
        'note': note,
        'followUpNote': followUpNote,
        'followUpRecordedAt': followUpRecordedAtIso,
        'preparedAt': preparedAtIso,
      };

  static UpcomingSituation fromJson(Map<String, dynamic> m) {
    return UpcomingSituation(
      id: m['id']?.toString() ?? '',
      title: m['title']?.toString() ?? '',
      at: DateTime.tryParse(m['at']?.toString() ?? '') ?? DateTime.now(),
      note: m['note']?.toString(),
      followUpNote: m['followUpNote']?.toString(),
      followUpRecordedAtIso: m['followUpRecordedAt']?.toString(),
      preparedAtIso: m['preparedAt']?.toString(),
    );
  }

  UpcomingSituation copyWith({
    String? title,
    DateTime? at,
    String? note,
    String? followUpNote,
    String? followUpRecordedAtIso,
    String? preparedAtIso,
  }) {
    return UpcomingSituation(
      id: id,
      title: title ?? this.title,
      at: at ?? this.at,
      note: note ?? this.note,
      followUpNote: followUpNote ?? this.followUpNote,
      followUpRecordedAtIso:
          followUpRecordedAtIso ?? this.followUpRecordedAtIso,
      preparedAtIso: preparedAtIso ?? this.preparedAtIso,
    );
  }
}

class UpcomingSituationsNotifier
    extends StateNotifier<List<UpcomingSituation>> {
  UpcomingSituationsNotifier(this._ref) : super(const []) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPrefsKey);
    if (raw == null || raw.isEmpty) {
      state = const [];
      _pushCoachContext();
      return;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      state = list
          .whereType<Map>()
          .map((e) => UpcomingSituation.fromJson(Map<String, dynamic>.from(e)))
          .where((s) => s.id.isNotEmpty && s.title.trim().isNotEmpty)
          .toList();
    } catch (_) {
      state = const [];
    }
    _pushCoachContext();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kPrefsKey,
      jsonEncode(state.map((e) => e.toJson()).toList()),
    );
    _pushCoachContext();
  }

  void _pushCoachContext() {
    final items = <Map<String, Object?>>[
      for (final s in state)
        {
          'title': s.title,
          'at': s.at.toIso8601String(),
          'note': s.note,
          'followUpNote': s.followUpNote,
          'isPast': s.isPast,
          'preparedAt': s.preparedAtIso,
        },
    ];
    final needsFollowUp = state
        .where(
          (s) =>
              s.isPast &&
              (s.followUpNote == null || s.followUpNote!.trim().isEmpty),
        )
        .map((s) => s.title)
        .toList();
    _ref.read(coachingRepositoryProvider).applyCoachingContext({
      'upcomingSituations': {
        'items': items,
        'titlesNeedingFollowUp': needsFollowUp,
      },
    });
  }

  Future<void> add({
    required String title,
    required DateTime at,
    String? note,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    state = [
      ...state,
      UpcomingSituation(
        id: id,
        title: title.trim(),
        at: at,
        note: note?.trim().isEmpty == true ? null : note?.trim(),
      ),
    ];
    await _persist();
  }

  Future<void> setFollowUp(String id, String note) async {
    state = [
      for (final s in state)
        if (s.id == id)
          s.copyWith(
            followUpNote: note.trim(),
            followUpRecordedAtIso: DateTime.now().toIso8601String(),
          )
        else
          s,
    ];
    await _persist();
  }

  Future<void> remove(String id) async {
    state = state.where((s) => s.id != id).toList();
    await _persist();
  }

  Future<void> markPrepared(String id) async {
    final iso = DateTime.now().toIso8601String();
    state = [
      for (final s in state)
        if (s.id == id) s.copyWith(preparedAtIso: iso) else s,
    ];
    await _persist();
  }
}

final upcomingSituationsProvider =
    StateNotifierProvider<UpcomingSituationsNotifier, List<UpcomingSituation>>(
  (ref) => UpcomingSituationsNotifier(ref),
);

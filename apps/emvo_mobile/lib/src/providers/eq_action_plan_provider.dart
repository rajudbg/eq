import 'dart:convert';

import 'package:emvo_assessment/emvo_assessment.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kV2 = 'eq.action_plan.v2';
const _kV1Legacy = 'eq.actionables.checked.v1';

/// Three EQ habits for one assessment result; persisted locally.
class EqActionPlanRecord {
  const EqActionPlanRecord({
    required this.resultId,
    required this.items,
    required this.done,
  });

  final String resultId;
  final List<String> items;
  final List<bool> done;

  int get completedCount => done.where((e) => e).length;
  double get progress => completedCount / 3.0;

  EqActionPlanRecord copyWith({
    List<String>? items,
    List<bool>? done,
  }) {
    return EqActionPlanRecord(
      resultId: resultId,
      items: items ?? this.items,
      done: done ?? this.done,
    );
  }

  Map<String, dynamic> toJson() => {
        'items': items,
        'done': done,
      };

  static EqActionPlanRecord fromJson(String id, Map<String, dynamic> m) {
    final rawItems = (m['items'] as List?)?.map((e) => e.toString()).toList();
    final rawDone = (m['done'] as List?)?.map((e) => e == true).toList();
    return EqActionPlanRecord(
      resultId: id,
      items: _padThreeStrings(rawItems ?? const []),
      done: _padThreeBools(rawDone ?? const []),
    );
  }
}

List<String> _padThreeStrings(List<String> raw) {
  final out = raw.map((s) => s.trim()).where((s) => s.isNotEmpty).take(3).toList();
  const fallbacks = [
    'Name one emotion before you react in a tense moment today',
    'After a stressful exchange, write what you felt vs. what you needed',
    'Open the coach and rehearse your first sentence before a hard conversation',
  ];
  for (var i = out.length; i < 3; i++) {
    out.add(fallbacks[i]);
  }
  return out.sublist(0, 3);
}

List<bool> _padThreeBools(List<bool> raw) {
  final out = List<bool>.from(raw);
  while (out.length < 3) {
    out.add(false);
  }
  return out.sublist(0, 3);
}

List<String> _normalizeFromNarrative(List<String> raw) {
  final cleaned = raw
      .map((s) => s.replaceAll('**', '').trim())
      .where((s) => s.isNotEmpty)
      .take(3)
      .toList();
  return _padThreeStrings(cleaned);
}

bool _itemsMatchBySlot(List<String> a, List<String> b) {
  if (a.length < 3 || b.length < 3) return false;
  for (var i = 0; i < 3; i++) {
    if (a[i].trim() != b[i].trim()) return false;
  }
  return true;
}

List<bool> _mergeDoneForNewTexts(
  EqActionPlanRecord? previous,
  List<String> newTexts,
  List<bool>? legacyV1,
) {
  if (previous != null &&
      previous.items.length == 3 &&
      _itemsMatchBySlot(previous.items, newTexts)) {
    return _padThreeBools(previous.done);
  }
  if (previous != null && previous.items.length == 3) {
    return List.generate(3, (i) {
      if (i < previous.items.length &&
          i < newTexts.length &&
          previous.items[i].trim() == newTexts[i].trim()) {
        return i < previous.done.length ? previous.done[i] : false;
      }
      return false;
    });
  }
  return _padThreeBools(legacyV1 ?? const []);
}

/// Stores weekly EQ action items + completion (habit-style), keyed by assessment result id.
class EqActionPlanNotifier extends StateNotifier<Map<String, EqActionPlanRecord>> {
  EqActionPlanNotifier() : super({}) {
    _load();
  }

  final Map<String, List<bool>> _legacyV1Done = {};

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final v2 = prefs.getString(_kV2);
    if (v2 != null && v2.isNotEmpty) {
      try {
        final decoded = jsonDecode(v2) as Map<String, dynamic>;
        final plans = decoded['plans'] as Map<String, dynamic>? ?? {};
        final next = <String, EqActionPlanRecord>{};
        for (final e in plans.entries) {
          if (e.value is Map<String, dynamic>) {
            next[e.key] =
                EqActionPlanRecord.fromJson(e.key, Map<String, dynamic>.from(e.value as Map));
          }
        }
        // In-memory updates (e.g. ensure before load finished) win over stale disk.
        state = {...next, ...state};
      } catch (_) {}
    }
    final v1 = prefs.getString(_kV1Legacy);
    if (v1 != null && v1.isNotEmpty) {
      try {
        final decoded = jsonDecode(v1) as Map<String, dynamic>;
        for (final e in decoded.entries) {
          if (e.value is List) {
            _legacyV1Done[e.key] =
                (e.value as List).map((x) => x == true).toList();
          }
        }
      } catch (_) {}
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final plans = <String, dynamic>{};
    for (final e in state.entries) {
      plans[e.key] = e.value.toJson();
    }
    await prefs.setString(_kV2, jsonEncode({'plans': plans}));
    await prefs.remove(_kV1Legacy);
  }

  EqActionPlanRecord? planFor(String resultId) => state[resultId];

  /// Seed from assessment recommendations when the user has not opened results yet.
  void ensureFromAssessment(AssessmentResult result) {
    final existing = state[result.id];
    if (existing != null &&
        existing.items.every((t) => t.trim().isNotEmpty)) {
      return;
    }
    final recs = result.recommendations
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .take(3)
        .toList();
    final texts = _padThreeStrings(recs);
    final done = _mergeDoneForNewTexts(
      existing,
      texts,
      _legacyV1Done[result.id],
    );
    _legacyV1Done.remove(result.id);
    state = Map<String, EqActionPlanRecord>.from(state)
      ..[result.id] = EqActionPlanRecord(
        resultId: result.id,
        items: texts,
        done: done,
      );
    _persist();
  }

  /// Prefer narrative / analysis actions when available (results screen).
  void syncFromNarrative(String resultId, List<String> actions) {
    final texts = _normalizeFromNarrative(actions);
    final existing = state[resultId];
    final done = _mergeDoneForNewTexts(
      existing,
      texts,
      _legacyV1Done[resultId],
    );
    _legacyV1Done.remove(resultId);
    final next = EqActionPlanRecord(
      resultId: resultId,
      items: texts,
      done: done,
    );
    if (existing != null &&
        listEquals(existing.items, next.items) &&
        listEquals(existing.done, next.done)) {
      return;
    }
    state = Map<String, EqActionPlanRecord>.from(state)..[resultId] = next;
    _persist();
  }

  Future<void> toggleDone(String resultId, int index) async {
    final r = state[resultId];
    if (r == null || index < 0 || index >= 3) return;
    final nextDone = List<bool>.from(r.done);
    nextDone[index] = !nextDone[index];
    state = Map<String, EqActionPlanRecord>.from(state)
      ..[resultId] = r.copyWith(done: nextDone);
    await _persist();
  }
}

final eqActionPlanProvider =
    StateNotifierProvider<EqActionPlanNotifier, Map<String, EqActionPlanRecord>>(
  (ref) => EqActionPlanNotifier(),
);

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kUserIntent = 'onboarding.user_intent_id';

/// Why the user opened Emvo — feeds coach context and analytics.
enum UserIntent {
  workRelationships(
    'work_relationships',
    'Work relationships',
    Icons.groups_2_outlined,
  ),
  managingReactions(
    'managing_reactions',
    'Managing my reactions',
    Icons.self_improvement_outlined,
  ),
  leadershipCommunication(
    'leadership_communication',
    'Leadership & communication',
    Icons.record_voice_over_outlined,
  ),
  personalGrowth(
    'personal_growth',
    'Personal growth',
    Icons.auto_awesome_outlined,
  );

  const UserIntent(this.id, this.label, this.icon);

  final String id;
  final String label;
  final IconData icon;

  static UserIntent? fromId(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final v in UserIntent.values) {
      if (v.id == raw) return v;
    }
    return null;
  }
}

class UserIntentNotifier extends StateNotifier<UserIntent?> {
  UserIntentNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = UserIntent.fromId(prefs.getString(_kUserIntent));
  }

  Future<void> setIntent(UserIntent intent) async {
    state = intent;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserIntent, intent.id);
  }

  Future<void> clear() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserIntent);
  }
}

final userIntentProvider =
    StateNotifierProvider<UserIntentNotifier, UserIntent?>((ref) {
  return UserIntentNotifier();
});

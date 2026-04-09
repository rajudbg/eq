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

/// Hydrates [UserIntent] from disk. While [AsyncLoading], consumers must not
/// start flows that depend on intent (e.g. assessment question packs).
class UserIntentNotifier extends AsyncNotifier<UserIntent?> {
  @override
  Future<UserIntent?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return UserIntent.fromId(prefs.getString(_kUserIntent));
  }

  Future<void> setIntent(UserIntent intent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserIntent, intent.id);
    state = AsyncValue.data(intent);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserIntent);
    state = const AsyncValue.data(null);
  }
}

final userIntentProvider =
    AsyncNotifierProvider<UserIntentNotifier, UserIntent?>(
  UserIntentNotifier.new,
);

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_auth_providers.dart';

String? _nameFromFirebaseUser(User? user) {
  if (user == null || user.isAnonymous) return null;
  final dn = user.displayName?.trim();
  if (dn != null && dn.isNotEmpty) return dn;
  final email = user.email?.trim();
  if (email != null && email.contains('@')) {
    return email.split('@').first;
  }
  return null;
}

/// [profileDisplayNameProvider] if set; otherwise Google/Apple/email account
/// name from Firebase ([User.displayName] or email local-part before `@`).
final effectiveProfileDisplayNameProvider = Provider<String?>((ref) {
  final custom = ref.watch(profileDisplayNameProvider);
  if (custom != null && custom.isNotEmpty) return custom;

  final user = ref.watch(firebaseAuthUserProvider).valueOrNull;
  return _nameFromFirebaseUser(user);
});

const _kDisplayName = 'profile.display_name';

class ProfileDisplayNameNotifier extends StateNotifier<String?> {
  ProfileDisplayNameNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kDisplayName);
    state = (raw == null || raw.trim().isEmpty) ? null : raw.trim();
  }

  Future<void> setDisplayName(String? value) async {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      state = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kDisplayName);
      return;
    }
    state = trimmed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDisplayName, trimmed);
  }
}

final profileDisplayNameProvider =
    StateNotifierProvider<ProfileDisplayNameNotifier, String?>((ref) {
  return ProfileDisplayNameNotifier();
});

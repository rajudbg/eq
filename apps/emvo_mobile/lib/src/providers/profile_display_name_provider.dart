import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

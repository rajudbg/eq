import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kOnboardingCompleted = 'onboarding.completed';
const _kAssessmentCompleted = 'assessment.completed';
const _kUserAuthenticated = 'auth.user_id';

/// Tracks whether user has completed onboarding
class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_kOnboardingCompleted) ?? false;
  }

  Future<void> completeOnboarding() async {
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingCompleted, true);
  }

  Future<void> reset() async {
    state = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingCompleted, false);
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier();
});

/// Tracks whether user has completed the EQ assessment
class AssessmentCompletionNotifier extends StateNotifier<bool> {
  AssessmentCompletionNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_kAssessmentCompleted) ?? false;
  }

  Future<void> completeAssessment() async {
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAssessmentCompleted, true);
  }

  Future<void> reset() async {
    state = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAssessmentCompleted, false);
  }
}

final assessmentCompletionProvider =
    StateNotifierProvider<AssessmentCompletionNotifier, bool>((ref) {
  return AssessmentCompletionNotifier();
});

/// Linked-account flag (Apple / Google / email) stored in prefs.
///
/// Firebase anonymous auth runs separately in [main] via
/// [ensureFirebaseAppAndAnonymousUser]; use [firebaseUidProvider] for the
/// stable guest UID before link.
class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_kUserAuthenticated) != null;
  }

  Future<void> signIn(String userId) async {
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserAuthenticated, userId);
  }

  Future<void> signOut() async {
    state = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserAuthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});

const _kEqDimensionsIntroSeen = 'onboarding.eq_dimensions_intro_seen';

/// First-run primer for the four EQ dimensions (Welcome → intro → Intent).
class EqDimensionsIntroNotifier extends StateNotifier<bool> {
  EqDimensionsIntroNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getBool(_kEqDimensionsIntroSeen) ?? false;
    if (state != v) state = v;
  }

  Future<void> markSeen() async {
    if (state) return;
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEqDimensionsIntroSeen, true);
  }

  /// Cleared when the user abandons the assessment before completion
  /// (same moment as [OnboardingNotifier.reset]).
  Future<void> reset() async {
    state = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kEqDimensionsIntroSeen);
  }
}

final eqDimensionsIntroSeenProvider =
    StateNotifierProvider<EqDimensionsIntroNotifier, bool>((ref) {
  return EqDimensionsIntroNotifier();
});

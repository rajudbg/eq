import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Only non-null after [Firebase.initializeApp] succeeded (mobile). On web or
/// when bootstrap skipped/failed, stays null so we never touch
/// [FirebaseAuth.instance] (that crashes on web without a JS SDK app).
final firebaseAuthProvider = Provider<FirebaseAuth?>((ref) {
  if (Firebase.apps.isEmpty) return null;
  try {
    return FirebaseAuth.instance;
  } catch (_) {
    return null;
  }
});

/// Auth state stream — anonymous user from bootstrap, then linked after
/// [User.linkWithCredential] when you wire account upgrade.
final firebaseAuthUserProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  if (auth == null) {
    return Stream<User?>.value(null);
  }
  try {
    return auth.authStateChanges();
  } catch (_) {
    return Stream<User?>.value(null);
  }
});

/// Current Firebase UID, if a session exists (anonymous counts).
final firebaseUidProvider = Provider<String?>((ref) {
  return ref.watch(firebaseAuthUserProvider).valueOrNull?.uid;
});

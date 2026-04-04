import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:emvo_mobile/firebase_options.dart';

/// Initializes Firebase and signs in anonymously on first launch so a stable
/// [User.uid] exists before onboarding or the assessment flow runs.
///
/// Called from [main] before [runApp]. Failures are logged only; the app
/// continues in offline/guest mode without Firebase.
Future<void> ensureFirebaseAppAndAnonymousUser() async {
  if (!_firebaseTargetSupported) {
    if (kDebugMode) {
      debugPrint('Firebase bootstrap skipped (platform not Android / iOS).');
    }
    return;
  }

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } on FirebaseException catch (e, st) {
    debugPrint('Firebase.initializeApp failed: ${e.message}\n$st');
    return;
  } catch (e, st) {
    debugPrint('Firebase.initializeApp failed: $e\n$st');
    return;
  }

  try {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
    if (kDebugMode) {
      final u = auth.currentUser;
      debugPrint(
        'Firebase session: uid=${u?.uid}, anonymous=${u?.isAnonymous}',
      );
    }
  } catch (e, st) {
    debugPrint('Firebase anonymous sign-in failed: $e\n$st');
  }
}

bool get _firebaseTargetSupported =>
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

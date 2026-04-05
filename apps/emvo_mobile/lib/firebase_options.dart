// Synced with `android/app/google-services.json` and
// `ios/Runner/GoogleService-Info.plist` (project `emvo-e882b`).
// Re-run `flutterfire configure` after adding apps/flavors or web.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are only wired for iOS and Android '
          '($defaultTargetPlatform). Run flutterfire configure to add more.',
        );
    }
  }

  /// Matches the **dev** Android client in `google-services.json`
  /// (`com.emvo.emvo_mobile.dev`). Add prod/staging clients in Firebase and
  /// merge `google-services.json`, or use flavor-specific JSON if needed.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBL5JMdIUjH7FJ96PbXcDbrW3VbPVmmxyU',
    appId: '1:432397815558:android:abff7ef8bb5c1cd4e2d887',
    messagingSenderId: '432397815558',
    projectId: 'emvo-e882b',
    storageBucket: 'emvo-e882b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAwiFuQiuYCovNnaOdlHGeK8nUm5beW81A',
    appId: '1:432397815558:ios:322d7fc81cb11393e2d887',
    messagingSenderId: '432397815558',
    projectId: 'emvo-e882b',
    storageBucket: 'emvo-e882b.firebasestorage.app',
    iosBundleId: 'com.emvo.emvoMobile',
  );
}

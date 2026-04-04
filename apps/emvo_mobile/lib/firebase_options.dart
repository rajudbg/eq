// Generated-style options: replace with real values from Firebase Console or run:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Until then, anonymous sign-in is attempted but will fail at runtime until
// apiKey / appId / projectId match your Firebase project (see also
// android/app/google-services.json).

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  /// Mobile-only: Emvo is not shipping web; `flutterfire configure` will still
  /// regenerate this file if you add web later.
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'replace-me',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'emvo-app-placeholder',
    storageBucket: 'emvo-app-placeholder.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'replace-me',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'emvo-app-placeholder',
    storageBucket: 'emvo-app-placeholder.appspot.com',
    iosBundleId: 'com.emvo.emvoMobile',
  );
}

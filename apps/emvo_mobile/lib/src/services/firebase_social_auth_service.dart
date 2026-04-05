import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Firebase Auth flows for Google, Apple, Facebook, and email/password.
///
/// Enable each provider in the Firebase Console and complete native setup:
/// - **Google**: SHA-1/256 on Android, URL schemes on iOS (`GoogleService-Info.plist`).
/// - **Apple**: Sign in with Apple capability + Firebase Apple provider.
/// - **Facebook**: App ID / client token in Android `strings.xml` + iOS `Info.plist`.
class FirebaseSocialAuthService {
  FirebaseSocialAuthService(this._auth);

  final FirebaseAuth _auth;

  static bool get appleSignInAvailable =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  /// Prefer linking to the current anonymous session so Firestore/coach UIDs stay stable.
  Future<UserCredential> _linkOrSignIn(AuthCredential credential) async {
    final user = _auth.currentUser;
    if (user != null && user.isAnonymous) {
      try {
        return await user.linkWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'credential-already-in-use' ||
            e.code == 'email-already-in-use' ||
            e.code == 'provider-already-linked') {
          await _auth.signOut();
          return _auth.signInWithCredential(credential);
        }
        rethrow;
      }
    }
    return _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      scopes: const ['email', 'profile'],
    );
    final account = await googleSignIn.signIn();
    if (account == null) {
      throw FirebaseAuthException(
        code: 'google-sign-in-aborted',
        message: 'Google sign-in was cancelled',
      );
    }
    final auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    final cred = await _linkOrSignIn(credential);
    await _applyGoogleProfileToUser(cred.user, account);
    return cred;
  }

  /// Firebase often omits [User.displayName] after link/sign-in; Google’s
  /// account still exposes it, so we copy it when the profile is blank.
  Future<void> _applyGoogleProfileToUser(
    User? user,
    GoogleSignInAccount account,
  ) async {
    if (user == null) return;
    final googleName = account.displayName?.trim();
    if (googleName == null || googleName.isEmpty) return;
    final current = user.displayName?.trim();
    if (current != null && current.isNotEmpty) return;
    await user.updateDisplayName(googleName);
    await user.reload();
  }

  Future<UserCredential> signInWithApple() async {
    if (!appleSignInAvailable) {
      throw UnsupportedError('Apple Sign-In is only available on iOS and macOS');
    }
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    final appleCred = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final idToken = appleCred.identityToken;
    if (idToken == null || idToken.isEmpty) {
      throw FirebaseAuthException(
        code: 'apple-missing-id-token',
        message: 'Apple did not return an ID token',
      );
    }

    final oauth = OAuthProvider('apple.com').credential(
      idToken: idToken,
      rawNonce: rawNonce,
    );
    final cred = await _linkOrSignIn(oauth);
    await _applyAppleNameToUser(cred.user, appleCred);
    return cred;
  }

  /// Apple only returns name on the first authorization; copy it if Firebase
  /// has no display name yet.
  Future<void> _applyAppleNameToUser(
    User? user,
    AuthorizationCredentialAppleID appleCred,
  ) async {
    if (user == null) return;
    final given = appleCred.givenName?.trim();
    final family = appleCred.familyName?.trim();
    String? built;
    if (given != null && given.isNotEmpty) {
      built = family != null && family.isNotEmpty ? '$given $family' : given;
    }
    if (built == null || built.isEmpty) return;
    final current = user.displayName?.trim();
    if (current != null && current.isNotEmpty) return;
    await user.updateDisplayName(built);
    await user.reload();
  }

  Future<UserCredential> signInWithFacebook() async {
    final result = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );
    if (result.status == LoginStatus.cancelled) {
      throw FirebaseAuthException(
        code: 'facebook-sign-in-aborted',
        message: 'Facebook sign-in was cancelled',
      );
    }
    if (result.status != LoginStatus.success) {
      throw FirebaseAuthException(
        code: 'facebook-login-failed',
        message: result.message ?? 'Facebook login failed',
      );
    }
    final token = result.accessToken?.tokenString;
    if (token == null || token.isEmpty) {
      throw FirebaseAuthException(
        code: 'facebook-missing-token',
        message: 'Facebook did not return an access token',
      );
    }
    final credential = FacebookAuthProvider.credential(token);
    return _linkOrSignIn(credential);
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = EmailAuthProvider.credential(
      email: email.trim(),
      password: password,
    );
    return _linkOrSignIn(credential);
  }

  /// Links email/password onto an anonymous session when possible; otherwise
  /// creates a new Firebase user.
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    final user = _auth.currentUser;
    if (user != null && user.isAnonymous) {
      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password,
      );
      return user.linkWithCredential(credential);
    }
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

// Retention cloud sync contract (Phase B) — see class doc below.

/// When the Emvo HTTP API is wired, implement [RetentionCloudSyncPort] to upload
/// assessment history, situations, check-ins, and action-plan state per user,
/// and optionally handle FCM. Local `applyCoachingContext` keys should stay stable.
///
/// **Profile / greeting:** today the Home greeting name may live in device prefs;
/// once accounts exist, pull the canonical display name (and related profile fields)
/// from the authenticated user profile during [pullAndMerge] so new devices stay
/// consistent without re-entering a local-only name.
///
/// **Identity:** the app boots a Firebase anonymous session early so
/// [FirebaseAuth.instance.currentUser] (and coaching context `firebase.uid`)
/// are stable for correlating local data before optional link-with-credential.
abstract class RetentionCloudSyncPort {
  Future<void> pushLocalSnapshot();
  Future<void> pullAndMerge();
}

/// Versioned envelope for the offline user-session cache, plus the rules for
/// deciding whether a cached session may be handed to the Firebase account
/// that is active right now.
///
/// ## Why this exists
///
/// The cache used to be a bare `UnifiedUser.toJson()` map, and every
/// "is this cache mine?" check compared `UnifiedUser.uid` against
/// `FirebaseUser.uid`. Those are two different identifiers:
///
///   * `UnifiedUser.uid` holds the **backend account GUID** whenever the
///     profile came from `/auth/me` — which is every normal signed-in player.
///   * It holds a **Firebase UID** only in the uncommon case where the profile
///     was rebuilt locally from the Firebase user because the backend was
///     unreachable.
///   * It holds an `offline_…` id for a pure local guest.
///
/// So for essentially every real player the comparison failed, the perfectly
/// good cache was rejected, and an offline launch fell through to rebuilding
/// the profile from the long-dead `guest_user_data` key — showing a freshly
/// generated username and a high score of 0, and then **overwriting the good
/// cache with that reconstruction**.
///
/// The fix is not to change what `uid` means — the backend GUID is what API
/// calls and sync ownership are keyed on, and it must stay. It is to record
/// both identifiers next to the profile, so ownership is answered by the
/// identifier that actually answers it.
///
/// ## Format
///
/// ```json
/// {
///   "v": 2,
///   "firebaseUid": "<Firebase UID, or null for a pure local guest>",
///   "backendUserId": "<backend GUID, or null when never authenticated>",
///   "user": { ...UnifiedUser.toJson()... }
/// }
/// ```
///
/// Anything without a `v` key is a legacy bare-profile cache. See
/// [CachedUserSession.ownedByFirebaseUser] for how those are handled.
library;

import 'dart:convert';

/// Current envelope version. Bump when the shape changes incompatibly.
const int kCachedSessionSchemaVersion = 2;

/// A parsed cached session: the stored profile plus the identifiers needed to
/// decide who it belongs to.
class CachedUserSession {
  /// The raw `UnifiedUser.toJson()` map. Kept as JSON so this unit stays free
  /// of any dependency on the user model (and therefore trivially testable).
  final Map<String, dynamic> userJson;

  /// The Firebase UID that owned this session, or null for a pure local guest
  /// that never had a Firebase user. Always null for [isLegacy] sessions.
  final String? firebaseUid;

  /// The backend account GUID. Recorded for diagnostics and for migrating
  /// callers that still key ownership off the backend id — never used to
  /// answer "is this the current Firebase account?".
  final String? backendUserId;

  /// True when this came from the pre-v2 format, which stored no identifiers.
  final bool isLegacy;

  const CachedUserSession({
    required this.userJson,
    this.firebaseUid,
    this.backendUserId,
    this.isLegacy = false,
  });

  /// Whatever `uid` the cached profile carries — a backend GUID, a Firebase
  /// UID, or an `offline_…` guest id, depending on which path wrote it.
  String? get cachedUid {
    final uid = userJson['uid'];
    return uid is String && uid.isNotEmpty ? uid : null;
  }

  /// True when this session provably belongs to no Firebase account — a pure
  /// local guest. Legacy sessions are excluded: they record nothing, so their
  /// silence is not evidence.
  bool get isGuestOwned => !isLegacy && firebaseUid == null;

  /// Whether this cache may be handed to the Firebase account [uid].
  ///
  /// For a v2 session this is a straight comparison against the recorded
  /// owner. For a legacy session there is no recorded owner, and the only one
  /// we can *prove* belongs to this account is a cache whose stored uid IS the
  /// Firebase uid — i.e. one written by the local rebuild path, which is the
  /// single writer that ever stored a Firebase UID in that field.
  ///
  /// A legacy cache holding a backend GUID or an `offline_…` id says nothing
  /// about which Firebase account wrote it. Binding it to whoever happens to
  /// be signed in now is how one player ends up looking at another player's
  /// profile, so those stay unattributed until an online load can migrate
  /// them — see [CacheRestoreDecision.rebuildKeepCache].
  bool ownedByFirebaseUser(String uid) {
    if (!isLegacy) return firebaseUid != null && firebaseUid == uid;
    return cachedUid != null && cachedUid == uid;
  }

  /// Parse a stored cache string. Returns null when the payload is absent,
  /// unreadable, or not a JSON object — the caller then treats it as "no
  /// cache", which is always safe.
  static CachedUserSession? parse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;

      final version = decoded['v'];
      if (version is! int) {
        // Legacy: the whole document IS the profile.
        return CachedUserSession(userJson: decoded, isLegacy: true);
      }

      final user = decoded['user'];
      if (user is! Map<String, dynamic>) return null;

      return CachedUserSession(
        userJson: user,
        firebaseUid: _nonEmpty(decoded['firebaseUid']),
        backendUserId: _nonEmpty(decoded['backendUserId']),
      );
    } catch (_) {
      return null;
    }
  }

  /// Build the envelope to persist for [userJson] under the given owners.
  static Map<String, dynamic> envelope({
    required Map<String, dynamic> userJson,
    String? firebaseUid,
    String? backendUserId,
  }) {
    return {
      'v': kCachedSessionSchemaVersion,
      'firebaseUid': firebaseUid,
      'backendUserId': backendUserId,
      'user': userJson,
    };
  }

  static String? _nonEmpty(Object? value) {
    if (value is String && value.isNotEmpty) return value;
    return null;
  }
}

/// What to do with a cached session when a profile is needed and the backend
/// cannot be reached.
enum CacheRestoreDecision {
  /// The cache belongs to this session — use it.
  restoreCached,

  /// The cache belongs to somebody else (or there is none). Rebuild the
  /// profile locally and persist that rebuild as the new cache.
  rebuildAndCache,

  /// A legacy cache we cannot attribute. Rebuild the profile for this session,
  /// but **leave the cache alone**: it may well belong to this very account —
  /// we simply cannot prove it while offline — and the rebuild is seeded from
  /// a stale `guest_user_data` key. Overwriting a real profile with that is
  /// the data loss this whole envelope exists to stop. The next successful
  /// online load rewrites it in v2 form, and the ambiguity is gone for good.
  rebuildKeepCache,
}

/// Decide how to treat [session] for the Firebase account [firebaseUid]
/// (null when no Firebase user is signed in).
///
/// Pure, so the offline-restore behaviour can be tested without Firebase.
CacheRestoreDecision decideCacheRestore({
  required CachedUserSession? session,
  required String? firebaseUid,
}) {
  if (session == null) return CacheRestoreDecision.rebuildAndCache;

  // No Firebase session at all: there is no other account on this device that
  // the cache could belong to, so the last known profile is the right one to
  // show. This is the ordinary offline-guest launch.
  if (firebaseUid == null) return CacheRestoreDecision.restoreCached;

  if (session.ownedByFirebaseUser(firebaseUid)) {
    return CacheRestoreDecision.restoreCached;
  }

  return session.isLegacy
      ? CacheRestoreDecision.rebuildKeepCache
      : CacheRestoreDecision.rebuildAndCache;
}

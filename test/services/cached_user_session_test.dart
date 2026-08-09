import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/services/auth/cached_user_session.dart';

/// The identifiers involved. The whole bug class comes from these two being
/// different strings that both live in fields called "uid" somewhere.
const String kFirebaseUid = 'firebase-uid-abcdef123456';
const String kOtherFirebaseUid = 'firebase-uid-999999999999';
const String kBackendGuid = '3f2504e0-4f89-11d3-9a0c-0305e82c3301';
const String kOtherBackendGuid = '9c858901-8a57-4791-81fe-4c455b099bc9';

/// A profile as `/auth/me` hands it back: `uid` is the BACKEND GUID.
Map<String, dynamic> backendProfile({
  String uid = kBackendGuid,
  String username = 'Swift_Viper_42',
  int highScore = 1840,
}) {
  return {
    'uid': uid,
    'userType': 'google',
    'username': username,
    'displayName': username,
    'highScore': highScore,
    'totalGamesPlayed': 312,
    'totalScore': 92400,
    'level': 14,
    'preferences': <String, dynamic>{},
  };
}

/// A profile as the offline rebuild path writes it: `uid` is the FIREBASE UID.
Map<String, dynamic> rebuiltProfile({String uid = kFirebaseUid}) {
  return {
    'uid': uid,
    'userType': 'anonymous',
    'username': 'Brave_Cobra_7',
    'displayName': 'Brave_Cobra_7',
    'highScore': 0,
    'preferences': <String, dynamic>{},
  };
}

/// A profile as the pure-local guest path writes it: `uid` is an `offline_` id.
Map<String, dynamic> guestProfile() {
  return {
    'uid': 'offline_1754700000000_54321',
    'userType': 'guest',
    'username': 'Wild_Fox_9',
    'displayName': 'Wild_Fox_9',
    'highScore': 620,
    'preferences': <String, dynamic>{},
  };
}

String v2Cache({
  required Map<String, dynamic> user,
  String? firebaseUid,
  String? backendUserId,
}) {
  return jsonEncode(CachedUserSession.envelope(
    userJson: user,
    firebaseUid: firebaseUid,
    backendUserId: backendUserId,
  ));
}

/// The pre-v2 format: the bare profile, no identifiers at all.
String legacyCache(Map<String, dynamic> user) => jsonEncode(user);

void main() {
  group('the bug this envelope exists to fix', () {
    test(
      'backend GUID != Firebase UID, backend unavailable -> the correct '
      'cached profile is restored',
      () {
        final session = CachedUserSession.parse(v2Cache(
          user: backendProfile(),
          firebaseUid: kFirebaseUid,
          backendUserId: kBackendGuid,
        ));

        // The precondition that broke the old check: these differ.
        expect(session!.cachedUid, kBackendGuid);
        expect(session.cachedUid, isNot(kFirebaseUid));

        expect(session.ownedByFirebaseUser(kFirebaseUid), isTrue);
        expect(
          decideCacheRestore(session: session, firebaseUid: kFirebaseUid),
          CacheRestoreDecision.restoreCached,
        );
        expect(session.userJson['highScore'], 1840);
      },
    );

    test('the backend id is preserved for API/sync ownership', () {
      final session = CachedUserSession.parse(v2Cache(
        user: backendProfile(),
        firebaseUid: kFirebaseUid,
        backendUserId: kBackendGuid,
      ))!;

      // uid stays the backend GUID — nothing about this fix rewrites it.
      expect(session.backendUserId, kBackendGuid);
      expect(session.userJson['uid'], kBackendGuid);
    });
  });

  group('a different Firebase account never sees the prior cache', () {
    test('v2 cache owned by another account is rejected', () {
      final session = CachedUserSession.parse(v2Cache(
        user: backendProfile(),
        firebaseUid: kFirebaseUid,
        backendUserId: kBackendGuid,
      ))!;

      expect(session.ownedByFirebaseUser(kOtherFirebaseUid), isFalse);
      expect(
        decideCacheRestore(session: session, firebaseUid: kOtherFirebaseUid),
        CacheRestoreDecision.rebuildAndCache,
      );
    });

    test('a matching BACKEND id does not make a cache mine', () {
      // Same backend GUID recorded, different Firebase account signed in.
      // Ownership must be answered by the Firebase UID alone.
      final session = CachedUserSession.parse(v2Cache(
        user: backendProfile(),
        firebaseUid: kFirebaseUid,
        backendUserId: kBackendGuid,
      ))!;

      expect(session.backendUserId, kBackendGuid);
      expect(session.ownedByFirebaseUser(kBackendGuid), isFalse);
    });

    test('a guest-owned cache is not handed to a Firebase account', () {
      final session = CachedUserSession.parse(v2Cache(
        user: guestProfile(),
        firebaseUid: null,
        backendUserId: null,
      ))!;

      expect(session.isGuestOwned, isTrue);
      expect(session.ownedByFirebaseUser(kFirebaseUid), isFalse);
      expect(
        decideCacheRestore(session: session, firebaseUid: kFirebaseUid),
        CacheRestoreDecision.rebuildAndCache,
      );
    });
  });

  group('offline guest behaviour still works', () {
    test('a guest cache is restored when no Firebase user is signed in', () {
      final session = CachedUserSession.parse(v2Cache(
        user: guestProfile(),
        firebaseUid: null,
        backendUserId: null,
      ))!;

      expect(
        decideCacheRestore(session: session, firebaseUid: null),
        CacheRestoreDecision.restoreCached,
      );
      expect(session.userJson['highScore'], 620);
    });

    test('no cache at all falls through to a rebuild', () {
      expect(
        decideCacheRestore(session: null, firebaseUid: null),
        CacheRestoreDecision.rebuildAndCache,
      );
      expect(
        decideCacheRestore(session: null, firebaseUid: kFirebaseUid),
        CacheRestoreDecision.rebuildAndCache,
      );
    });

    test('a guest session round-trips through the envelope', () {
      final written = v2Cache(user: guestProfile(), firebaseUid: null);
      final session = CachedUserSession.parse(written)!;

      expect(session.isLegacy, isFalse);
      expect(session.firebaseUid, isNull);
      expect(session.backendUserId, isNull);
      expect(session.userJson['username'], 'Wild_Fox_9');
    });
  });

  group('linking and switching accounts', () {
    test(
      'linking a credential keeps the same Firebase UID, so the cache '
      'stays owned and is never rebuilt',
      () {
        // Firebase preserves the UID through linkWithCredential; only the
        // profile's userType changes. Ownership must survive that.
        final beforeLink = CachedUserSession.parse(v2Cache(
          user: backendProfile()..['userType'] = 'anonymous',
          firebaseUid: kFirebaseUid,
          backendUserId: kBackendGuid,
        ))!;

        expect(beforeLink.ownedByFirebaseUser(kFirebaseUid), isTrue);
        expect(
          decideCacheRestore(session: beforeLink, firebaseUid: kFirebaseUid),
          CacheRestoreDecision.restoreCached,
        );

        // Same account after linking — same backend row, same Firebase UID.
        final afterLink = CachedUserSession.parse(v2Cache(
          user: backendProfile(),
          firebaseUid: kFirebaseUid,
          backendUserId: kBackendGuid,
        ))!;
        expect(afterLink.ownedByFirebaseUser(kFirebaseUid), isTrue);
        expect(afterLink.backendUserId, kBackendGuid);
      },
    );

    test(
      'switching to a different account rebuilds AND replaces the cache, so '
      'the new session never inherits the old profile',
      () {
        final previous = CachedUserSession.parse(v2Cache(
          user: backendProfile(),
          firebaseUid: kFirebaseUid,
          backendUserId: kBackendGuid,
        ))!;

        expect(
          decideCacheRestore(session: previous, firebaseUid: kOtherFirebaseUid),
          CacheRestoreDecision.rebuildAndCache,
        );

        // And the replacement envelope records the NEW owners, so the next
        // launch attributes it to the account that actually owns it.
        final replaced = CachedUserSession.parse(v2Cache(
          user: backendProfile(uid: kOtherBackendGuid, username: 'Ace_Wolf_3'),
          firebaseUid: kOtherFirebaseUid,
          backendUserId: kOtherBackendGuid,
        ))!;
        expect(replaced.ownedByFirebaseUser(kOtherFirebaseUid), isTrue);
        expect(replaced.ownedByFirebaseUser(kFirebaseUid), isFalse);
      },
    );
  });

  group('legacy caches are handled conservatively', () {
    test(
      'an unattributable legacy cache is never bound to whichever account '
      'happens to be active',
      () {
        // Pre-v2 cache holding a backend GUID: nothing records who wrote it.
        final session = CachedUserSession.parse(legacyCache(backendProfile()))!;

        expect(session.isLegacy, isTrue);
        expect(session.firebaseUid, isNull);
        expect(session.ownedByFirebaseUser(kFirebaseUid), isFalse);
        expect(session.ownedByFirebaseUser(kOtherFirebaseUid), isFalse);
      },
    );

    test(
      'and it is never overwritten with a guest reconstruction just because '
      'the backend is offline',
      () {
        final session = CachedUserSession.parse(legacyCache(backendProfile()))!;

        // rebuildKeepCache, not rebuildAndCache: use a local profile for this
        // session but leave the stored one intact for a later migration.
        expect(
          decideCacheRestore(session: session, firebaseUid: kFirebaseUid),
          CacheRestoreDecision.rebuildKeepCache,
        );
      },
    );

    test(
      'a legacy cache written by the local rebuild path IS provably ours, '
      'because only that path ever stored a Firebase UID in uid',
      () {
        final session =
            CachedUserSession.parse(legacyCache(rebuiltProfile()))!;

        expect(session.isLegacy, isTrue);
        expect(session.ownedByFirebaseUser(kFirebaseUid), isTrue);
        expect(session.ownedByFirebaseUser(kOtherFirebaseUid), isFalse);
        expect(
          decideCacheRestore(session: session, firebaseUid: kFirebaseUid),
          CacheRestoreDecision.restoreCached,
        );
      },
    );

    test('a legacy guest cache is still usable with no Firebase user', () {
      final session = CachedUserSession.parse(legacyCache(guestProfile()))!;

      expect(session.isLegacy, isTrue);
      expect(session.isGuestOwned, isFalse); // legacy records nothing
      expect(
        decideCacheRestore(session: session, firebaseUid: null),
        CacheRestoreDecision.restoreCached,
      );
    });

    test('a legacy cache is migrated to v2 by the next online write', () {
      final legacy = CachedUserSession.parse(legacyCache(backendProfile()))!;
      expect(legacy.isLegacy, isTrue);

      // What _cacheUserSession writes after a successful /auth/me.
      final migrated = CachedUserSession.parse(v2Cache(
        user: legacy.userJson,
        firebaseUid: kFirebaseUid,
        backendUserId: kBackendGuid,
      ))!;

      expect(migrated.isLegacy, isFalse);
      expect(migrated.ownedByFirebaseUser(kFirebaseUid), isTrue);
      expect(migrated.userJson['highScore'], 1840);
      expect(
        decideCacheRestore(session: migrated, firebaseUid: kFirebaseUid),
        CacheRestoreDecision.restoreCached,
      );
    });
  });

  group('degenerate payloads', () {
    test('absent, empty, malformed, or non-object payloads read as no cache',
        () {
      expect(CachedUserSession.parse(null), isNull);
      expect(CachedUserSession.parse(''), isNull);
      expect(CachedUserSession.parse('{not json'), isNull);
      expect(CachedUserSession.parse('[1,2,3]'), isNull);
      expect(CachedUserSession.parse('"a string"'), isNull);
    });

    test('a v2 envelope with no user object reads as no cache', () {
      expect(CachedUserSession.parse('{"v":2,"firebaseUid":"x"}'), isNull);
    });

    test('empty-string identifiers are treated as absent, not as owners', () {
      final session = CachedUserSession.parse(v2Cache(
        user: backendProfile(),
        firebaseUid: '',
        backendUserId: '',
      ))!;

      expect(session.firebaseUid, isNull);
      expect(session.backendUserId, isNull);
      expect(session.ownedByFirebaseUser(''), isFalse);
      expect(session.isGuestOwned, isTrue);
    });

    test('a profile with no uid cannot be claimed by a legacy match', () {
      final session = CachedUserSession.parse(legacyCache({
        'userType': 'google',
        'username': 'No_Uid_1',
      }))!;

      expect(session.cachedUid, isNull);
      expect(session.ownedByFirebaseUser(kFirebaseUid), isFalse);
      expect(
        decideCacheRestore(session: session, firebaseUid: kFirebaseUid),
        CacheRestoreDecision.rebuildKeepCache,
      );
    });

    test('the schema version is recorded so a stale reader can detect it', () {
      final written = jsonDecode(v2Cache(
        user: backendProfile(),
        firebaseUid: kFirebaseUid,
      )) as Map<String, dynamic>;

      expect(written['v'], kCachedSessionSchemaVersion);
      expect(kCachedSessionSchemaVersion, greaterThanOrEqualTo(2));
    });
  });
}

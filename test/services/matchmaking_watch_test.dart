import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/services/multiplayer/matchmaking_watch.dart';

/// The client-side safety net around quick match.
///
/// The server is the authority on WHEN a match happens (human for 30s, then
/// a house opponent), so the client runs no "no players found" clock. What it
/// does judge is when waiting has stopped being useful: a real outage, or a
/// search that has blown far past the server's own promise.
void main() {
  group('hard deadline', () {
    test('keeps waiting right up to the deadline', () {
      final watch = MatchmakingWatch(hardDeadlineSeconds: 60);
      for (var s = 0; s < 60; s++) {
        expect(
          watch.onTick(s, online: true),
          MatchmakingWatchVerdict.keepWaiting,
          reason: 'second $s is inside the deadline',
        );
      }
    });

    test('times out once the deadline is reached', () {
      final watch = MatchmakingWatch(hardDeadlineSeconds: 60);
      expect(watch.onTick(60, online: true), MatchmakingWatchVerdict.timedOut);
    });

    test('the deadline sits well past what the server promises', () {
      // 35s is the server's quoted resolution; the scheduler behind it has
      // ~15s granularity. A deadline any tighter is the old give-up-too-early
      // bug back again, so the constructor refuses it.
      expect(() => MatchmakingWatch(hardDeadlineSeconds: 35),
          throwsA(isA<AssertionError>()));
      expect(MatchmakingWatch().hardDeadlineSeconds, greaterThanOrEqualTo(50));
    });
  });

  group('offline grace', () {
    test('a short blip is tolerated', () {
      final watch = MatchmakingWatch(offlineGraceSeconds: 10);
      expect(watch.onTick(5, online: true), MatchmakingWatchVerdict.keepWaiting);
      for (var s = 6; s < 15; s++) {
        expect(
          watch.onTick(s, online: false),
          MatchmakingWatchVerdict.keepWaiting,
          reason: 'offline for ${s - 6}s is still a blip',
        );
        expect(watch.isOffline, isTrue);
      }
    });

    test('an outage past the grace window ends the search', () {
      final watch = MatchmakingWatch(offlineGraceSeconds: 10);
      watch.onTick(5, online: true);
      for (var s = 6; s < 16; s++) {
        watch.onTick(s, online: false);
      }
      expect(
        watch.onTick(16, online: false),
        MatchmakingWatchVerdict.connectionLost,
      );
    });

    test('coming back online resets the window', () {
      final watch = MatchmakingWatch(offlineGraceSeconds: 10);
      for (var s = 0; s < 8; s++) {
        watch.onTick(s, online: false);
      }
      expect(watch.onTick(8, online: true), MatchmakingWatchVerdict.keepWaiting);
      expect(watch.isOffline, isFalse);
      // A second outage starts its own clock from scratch.
      for (var s = 9; s < 18; s++) {
        expect(
          watch.onTick(s, online: false),
          MatchmakingWatchVerdict.keepWaiting,
        );
      }
      expect(
        watch.onTick(19, online: false),
        MatchmakingWatchVerdict.connectionLost,
      );
    });

    test('an outage is reported before a coincident deadline', () {
      final watch =
          MatchmakingWatch(hardDeadlineSeconds: 60, offlineGraceSeconds: 10);
      for (var s = 50; s < 60; s++) {
        watch.onTick(s, online: false);
      }
      // At 60 both conditions hold. "Connection lost" is the truthful one:
      // it names the thing the player can fix.
      expect(
        watch.onTick(60, online: false),
        MatchmakingWatchVerdict.connectionLost,
      );
    });
  });

  group('re-queue budget', () {
    test('allows a bounded number of silent rejoins, then stops', () {
      final watch = MatchmakingWatch(maxRequeues: 2);
      expect(watch.takeRequeue(), isTrue);
      expect(watch.requeuesUsed, 1);
      expect(watch.takeRequeue(), isTrue);
      expect(watch.requeuesUsed, 2);
      expect(watch.takeRequeue(), isFalse);
      expect(watch.requeuesUsed, 2);
    });

    test('a new search starts with a fresh budget', () {
      final spent = MatchmakingWatch(maxRequeues: 1)..takeRequeue();
      expect(spent.takeRequeue(), isFalse);
      expect(MatchmakingWatch(maxRequeues: 1).takeRequeue(), isTrue);
    });
  });
}

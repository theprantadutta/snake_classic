import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/services/multiplayer/queue_resolution.dart';

/// How the client reads the server's answer while it waits for a quick match.
///
/// The rule it replaced was a 60-second stopwatch that ended in "NO PLAYERS
/// FOUND". Both halves were wrong: an empty queue is not a failure, because
/// the server seats a house opponent once the wait passes its deadline; and
/// the client cannot know when to stop anyway — a match created 34 seconds
/// after queueing was observed sitting matched in the database while the app
/// counted itself out and abandoned it.
void main() {
  Map<String, dynamic> waiting({int waited = 3, int deadline = 35}) => {
        'state': 'waiting',
        'waitedSeconds': waited,
        'resolvesWithinSeconds': deadline,
      };

  Map<String, dynamic> matched({String gameId = 'g1'}) => {
        'state': 'matched',
        'gameId': gameId,
        'roomCode': 'ABC123',
        'mode': 'Classic',
        'playerCount': 2,
        'playerIndex': 0,
        'resolvesWithinSeconds': 35,
      };

  group('an empty queue is not a failure', () {
    test('waiting keeps waiting, however long it goes on', () {
      final resolution = QueueResolution();

      // Well past the old 60-second give-up point, and past the server's own
      // deadline too. Still waiting is still waiting.
      for (var second = 0; second < 300; second++) {
        expect(resolution.apply(waiting(waited: second)),
            QueueOutcome.keepWaiting);
      }
    });

    test('an empty queue never reports unreachable', () {
      final resolution = QueueResolution();
      for (var i = 0; i < 100; i++) {
        expect(resolution.apply(waiting()), isNot(QueueOutcome.unreachable));
      }
    });
  });

  group('resolving', () {
    test('a matched status resolves', () {
      expect(QueueResolution().apply(matched()), QueueOutcome.resolved);
    });

    test('resolution arrives with no push involved at all', () {
      // Every answer here came from asking. MatchFound is addressed to one
      // connection, on whichever backend process ran the pass, with no
      // backplane behind it — so it can be missed entirely and this still
      // reaches a match.
      final resolution = QueueResolution();
      final answers = [
        waiting(waited: 2),
        waiting(waited: 4),
        waiting(waited: 32),
        matched(),
      ];

      final outcomes = answers.map(resolution.apply).toList();

      expect(outcomes.take(3), everyElement(QueueOutcome.keepWaiting));
      expect(outcomes.last, QueueOutcome.resolved);
    });

    test('matched without a game id is not treated as resolved', () {
      // Sending the player to a room with no id strands them worse than
      // waiting does.
      final broken = matched()..remove('gameId');
      expect(QueueResolution().apply(broken), QueueOutcome.keepWaiting);
    });

    test('the server deadline is read from the answer, not assumed', () {
      expect(QueueResolution.deadlineFrom(waiting(deadline: 35)), 35);
      expect(QueueResolution.deadlineFrom(waiting(deadline: 20)), 20);
      expect(QueueResolution.deadlineFrom(null), isNull);
      expect(QueueResolution.deadlineFrom({'state': 'waiting'}), isNull);
    });
  });

  group('cancelled or swept', () {
    test('no queue entry means leave the search, not an error', () {
      expect(QueueResolution().apply({'state': 'none'}),
          QueueOutcome.notQueued);
    });
  });

  group('the one real failure: the server cannot be reached', () {
    test('a single failed request is not an error', () {
      final resolution = QueueResolution(failuresBeforeUnreachable: 5);
      expect(resolution.apply(null), QueueOutcome.keepWaiting);
    });

    test('failures short of the threshold keep waiting', () {
      final resolution = QueueResolution(failuresBeforeUnreachable: 5);
      for (var i = 0; i < 4; i++) {
        expect(resolution.apply(null), QueueOutcome.keepWaiting);
      }
    });

    test('the threshold reports unreachable', () {
      final resolution = QueueResolution(failuresBeforeUnreachable: 5);
      for (var i = 0; i < 4; i++) {
        resolution.apply(null);
      }
      expect(resolution.apply(null), QueueOutcome.unreachable);
    });

    test('one good answer forgives the failures before it', () {
      // Otherwise a flaky minute of a long search accumulates into an error
      // for a queue that is working perfectly well.
      final resolution = QueueResolution(failuresBeforeUnreachable: 3);

      resolution.apply(null);
      resolution.apply(null);
      expect(resolution.consecutiveFailures, 2);

      expect(resolution.apply(waiting()), QueueOutcome.keepWaiting);
      expect(resolution.consecutiveFailures, 0);

      // Back to needing the full run again.
      expect(resolution.apply(null), QueueOutcome.keepWaiting);
      expect(resolution.apply(null), QueueOutcome.keepWaiting);
      expect(resolution.apply(null), QueueOutcome.unreachable);
    });

    test('a match still resolves even after some failed polls', () {
      final resolution = QueueResolution(failuresBeforeUnreachable: 5);
      resolution.apply(null);
      resolution.apply(null);
      expect(resolution.apply(matched()), QueueOutcome.resolved);
    });

    test('erroring on a single blip is refused outright', () {
      expect(() => QueueResolution(failuresBeforeUnreachable: 1),
          throwsA(isA<AssertionError>()));
    });
  });

  group('the deadline the player is shown', () {
    test('is the server 35s promise, not a client guess', () {
      // 30s preferring a human + one 5s matchmaking pass. If the backend ever
      // changes it, the client follows rather than disagreeing.
      expect(QueueResolution.deadlineFrom(waiting()), 35);
    });
  });
}

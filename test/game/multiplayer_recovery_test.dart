import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/models/multiplayer_game.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/presentation/bloc/multiplayer/multiplayer_recovery.dart';
import 'package:snake_classic/presentation/bloc/multiplayer/multiplayer_state.dart';
import 'package:snake_classic/presentation/bloc/multiplayer/multiplayer_steering.dart';
import 'package:snake_classic/utils/direction.dart';

/// An error that outlived the failure it described.
///
/// `copyWith` keeps `errorCode` unless asked to drop it, and the two paths
/// that put the client back into `playing` never asked. So a connection blip
/// mid-match left an error standing, steering refuses on any error, and the
/// player sat watching a match they could see running and could not steer in.
/// The controls looked broken; nothing in the logs said why.
void main() {
  const me = 'me';

  MatchSnapshot snapshotAt(int tick, {bool alive = true}) => MatchSnapshot(
    tick: tick,
    tickMs: 200,
    elapsedGameMs: tick * 200,
    food: const Position(9, 9),
    players: [
      MatchPlayerState(
        playerIndex: 0,
        userId: me,
        username: 'player',
        alive: alive,
        connected: true,
        direction: Direction.right,
        score: 0,
        deathReason: alive ? null : 'wall',
        body: const [Position(3, 3), Position(2, 3)],
      ),
    ],
  );

  bool steerable(MultiplayerState state) => MultiplayerSteering.canSteer(
    status: state.status,
    snapshot: state.snapshot,
    errorCode: state.errorCode,
    currentUserId: me,
  );

  MultiplayerState afterBlip({
    MultiplayerStatus status = MultiplayerStatus.playing,
    MultiplayerError error = MultiplayerError.connectionLost,
  }) {
    return MultiplayerState(
      status: status,
      snapshot: snapshotAt(10),
      errorCode: error,
    );
  }

  group('the stale error', () {
    test('a playing match with an error standing is not steerable', () {
      // Correct in itself — this is the guard doing its job. The bug was
      // that nothing ever took the error back down.
      expect(steerable(afterBlip()), isFalse);
    });

    test('an authoritative snapshot clears it', () {
      final recovered = MultiplayerRecovery.afterSnapshot(
        afterBlip(),
        snapshot: snapshotAt(11),
        boardSize: 20,
      );

      expect(recovered.errorCode, isNull);
      expect(recovered.status, MultiplayerStatus.playing);
      expect(recovered.snapshot?.tick, 11);
    });

    test('and the player can steer again', () {
      // The whole point: the control comes back, in the same frame the
      // player can see the match is running.
      final recovered = MultiplayerRecovery.afterSnapshot(
        afterBlip(),
        snapshot: snapshotAt(11),
        boardSize: 20,
      );

      expect(steerable(recovered), isTrue);
    });

    test('recovery from a reconnecting state works the same way', () {
      final recovered = MultiplayerRecovery.afterSnapshot(
        afterBlip(status: MultiplayerStatus.reconnecting),
        snapshot: snapshotAt(11),
        boardSize: 20,
      );

      expect(steerable(recovered), isTrue);
    });

    test('every error code is cleared, not just the connection ones', () {
      for (final error in MultiplayerError.values) {
        final recovered = MultiplayerRecovery.afterSnapshot(
          afterBlip(error: error),
          snapshot: snapshotAt(11),
          boardSize: 20,
        );
        expect(recovered.errorCode, isNull, reason: error.name);
      }
    });

    test('a snapshot also expires the local input echo and the refusal cue', () {
      // Both are per-tick truths. The committed direction in the snapshot is
      // the new reversal reference, and a refusal from before the blip has
      // nothing left to say.
      final stale = MultiplayerState(
        status: MultiplayerStatus.playing,
        snapshot: snapshotAt(10),
        errorCode: MultiplayerError.connectionLost,
        intentDirection: Direction.up,
        lastRejectedInputAt: DateTime(2026, 8, 12),
        lastRejectedDirection: Direction.left,
      );

      final recovered = MultiplayerRecovery.afterSnapshot(
        stale,
        snapshot: snapshotAt(11),
        boardSize: 20,
      );

      expect(recovered.intentDirection, isNull);
      expect(recovered.lastRejectedInputAt, isNull);
      expect(recovered.lastRejectedDirection, isNull);
    });
  });

  group('what does not count as recovery', () {
    test('only a playing game update proves the match is live', () {
      for (final status in MultiplayerGameStatus.values) {
        expect(
          MultiplayerRecovery.provesMatchLive(status),
          status == MultiplayerGameStatus.playing,
          reason: status.name,
        );
      }
    });

    test('a lobby, a countdown or a finish leaves the error alone', () {
      // None of them says anything about whether the outstanding failure has
      // been resolved, and clearing on them would hide a real problem.
      for (final status in [
        MultiplayerGameStatus.waiting,
        MultiplayerGameStatus.starting,
        MultiplayerGameStatus.paused,
        MultiplayerGameStatus.finished,
        MultiplayerGameStatus.abandoned,
      ]) {
        expect(MultiplayerRecovery.provesMatchLive(status), isFalse);
      }
    });

    test('a reconnecting client with no snapshot yet stays blocked', () {
      final reconnecting = MultiplayerState(
        status: MultiplayerStatus.reconnecting,
        errorCode: MultiplayerError.connectionLost,
      );

      expect(steerable(reconnecting), isFalse);
    });

    test('a failed match stays blocked', () {
      final failed = MultiplayerState(
        status: MultiplayerStatus.error,
        snapshot: snapshotAt(10),
        errorCode: MultiplayerError.startFailed,
      );

      expect(steerable(failed), isFalse);
    });

    test('an idle client is not steerable regardless of errors', () {
      expect(
        steerable(const MultiplayerState(status: MultiplayerStatus.idle)),
        isFalse,
      );
    });

    test('a recovered match the player died in stays unsteerable', () {
      // The error goes; being dead does not.
      final recovered = MultiplayerRecovery.afterSnapshot(
        afterBlip(),
        snapshot: snapshotAt(11, alive: false),
        boardSize: 20,
      );

      expect(recovered.errorCode, isNull);
      expect(steerable(recovered), isFalse);
    });
  });
}

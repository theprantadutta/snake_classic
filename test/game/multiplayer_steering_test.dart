import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/models/input_result.dart';
import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/presentation/bloc/multiplayer/multiplayer_state.dart';
import 'package:snake_classic/presentation/bloc/multiplayer/multiplayer_steering.dart';
import 'package:snake_classic/utils/direction.dart';

/// Who may steer, and what one input is worth.
///
/// The reported defect was a feedback defect: an accepted turn produced two
/// haptics (the cubit's and the screen's), while a refused or impossible one
/// produced a positive click and the success animation anyway. Fixing it
/// needed a single answer that both the cubit and the D-pad could read, which
/// is what these tests pin down. The counting half — one effect per accepted
/// input, none otherwise — follows from the shape: the haptic sits behind the
/// accepted branch alone, and the screens animate only on `isAccepted`.
void main() {
  const me = 'me';

  MatchPlayerState player({
    bool alive = true,
    Direction direction = Direction.right,
    String userId = me,
  }) {
    return MatchPlayerState(
      playerIndex: 0,
      userId: userId,
      username: 'player',
      alive: alive,
      connected: true,
      direction: direction,
      score: 0,
      deathReason: alive ? null : 'wall',
      body: const [Position(3, 3), Position(2, 3)],
    );
  }

  MatchSnapshot snapshotWith(List<MatchPlayerState> players) => MatchSnapshot(
    tick: 5,
    tickMs: 200,
    elapsedGameMs: 1000,
    food: const Position(9, 9),
    players: players,
  );

  bool steerable({
    MultiplayerStatus status = MultiplayerStatus.playing,
    MatchSnapshot? snapshot,
    MultiplayerError? errorCode,
    String? currentUserId = me,
  }) {
    return MultiplayerSteering.canSteer(
      status: status,
      snapshot: snapshot ?? snapshotWith([player()]),
      errorCode: errorCode,
      currentUserId: currentUserId,
    );
  }

  group('canSteer', () {
    test('a live player in a live match can', () {
      expect(steerable(), isTrue);
    });

    test('not before the match is playing', () {
      for (final status in MultiplayerStatus.values) {
        expect(
          steerable(status: status),
          status == MultiplayerStatus.playing,
          reason: status.name,
        );
      }
    });

    test('not without a snapshot to steer within', () {
      expect(
        MultiplayerSteering.canSteer(
          status: MultiplayerStatus.playing,
          snapshot: null,
          errorCode: null,
          currentUserId: me,
        ),
        isFalse,
      );
    });

    test('not while an error is standing', () {
      expect(steerable(errorCode: MultiplayerError.connectionLost), isFalse);
    });

    test('not when we do not know who the player is', () {
      expect(steerable(currentUserId: null), isFalse);
    });

    test('not when the local player is absent from the snapshot', () {
      expect(
        steerable(snapshot: snapshotWith([player(userId: 'someone else')])),
        isFalse,
      );
    });

    test('not once they are dead', () {
      // The control kept accepting presses from a crashed player. Every one
      // of them was dropped, silently.
      expect(steerable(snapshot: snapshotWith([player(alive: false)])), isFalse);
    });

    test("a dead opponent does not stop us steering", () {
      expect(
        steerable(
          snapshot: snapshotWith([
            player(),
            player(userId: 'them', alive: false),
          ]),
        ),
        isTrue,
      );
    });
  });

  group('one input, one outcome', () {
    InputResult resolve(
      Direction requested, {
      bool canSteerNow = true,
      Direction? intent,
      Direction committed = Direction.right,
    }) {
      return MultiplayerSteering.resolve(
        canSteerNow: canSteerNow,
        requested: requested,
        intent: intent,
        committed: committed,
      );
    }

    test('a legal turn is accepted', () {
      expect(resolve(Direction.up), InputResult.accepted);
    });

    test('a repeat of the outstanding intent is rejected, not ignored', () {
      // Rejected: the player did something and the game said no. Ignored
      // would mean silence, and silence reads as dropped input.
      expect(
        resolve(Direction.up, intent: Direction.up),
        InputResult.rejected,
      );
    });

    test('a reversal into your own neck is rejected', () {
      expect(resolve(Direction.left), InputResult.rejected);
    });

    test('the outstanding intent, not the committed direction, is what a '
        'reversal is measured against', () {
      // The snake is about to be going up; down is the reversal now, and
      // left — a reversal of the committed direction — is legal again.
      expect(
        resolve(Direction.down, intent: Direction.up),
        InputResult.rejected,
      );
      expect(resolve(Direction.left, intent: Direction.up), InputResult.accepted);
    });

    test('input from someone who cannot steer is ignored, not rejected', () {
      // No cue of any kind. Showing the rejected flash to a dead player tells
      // them their input was considered and refused, which it was not.
      for (final direction in Direction.values) {
        expect(
          resolve(direction, canSteerNow: false),
          InputResult.ignored,
          reason: direction.name,
        );
      }
    });

    test('only an accepted input carries feedback the screen should show', () {
      expect(InputResult.accepted.isAccepted, isTrue);
      expect(InputResult.accepted.hasFeedback, isTrue);
      expect(InputResult.rejected.isAccepted, isFalse);
      expect(InputResult.rejected.hasFeedback, isTrue);
      expect(InputResult.ignored.isAccepted, isFalse);
      expect(InputResult.ignored.hasFeedback, isFalse);
    });
  });
}

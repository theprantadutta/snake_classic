import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/game/flame/multiplayer_flame_game.dart';
import 'package:snake_classic/game/multiplayer/local_snake_predictor.dart';
import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';

/// The board's side of prediction: what the local snake looks like on the
/// frames after a swipe and after a snapshot, driven through the game's own
/// update clock.
void main() {
  const me = 'me';
  const frame = 1 / 60;

  MatchSnapshot snap(
    int tick,
    List<Position> body, {
    Direction dir = Direction.right,
  }) => MatchSnapshot(
    tick: tick,
    tickMs: 300,
    elapsedGameMs: tick * 300,
    food: const Position(15, 15),
    players: [
      MatchPlayerState(
        playerIndex: 0,
        userId: me,
        username: me,
        alive: true,
        connected: true,
        direction: dir,
        score: 0,
        deathReason: null,
        body: body,
      ),
      const MatchPlayerState(
        playerIndex: 1,
        userId: 'rival',
        username: 'rival',
        alive: true,
        connected: true,
        direction: Direction.left,
        score: 0,
        deathReason: null,
        body: [Position(15, 2), Position(16, 2), Position(17, 2)],
      ),
    ],
  );

  const start = [Position(5, 5), Position(4, 5), Position(3, 5)];

  ({LocalSnakePredictor predictor, MultiplayerFlameGame game}) setUpMatch() {
    final predictor = LocalSnakePredictor();
    final first = snap(10, start);
    predictor.onSnapshot(
      first,
      userId: me,
      boardSize: 20,
      receivedAt: Duration.zero,
    );
    final game = MultiplayerFlameGame(
      snapshot: first,
      currentUserId: me,
      boardSize: 20,
      theme: GameTheme.values.first,
      prediction: predictor.prediction,
    );
    return (predictor: predictor, game: game);
  }

  void run(MultiplayerFlameGame game, double seconds) {
    for (var t = 0.0; t < seconds; t += frame) {
      game.update(frame);
    }
  }

  test(
    'the local snake glides from the snapshot toward the predicted step',
    () {
      final (:predictor, :game) = setUpMatch();
      run(game, .15);

      final head = game.localCells!.first;
      expect(head.dy, closeTo(5.5, 1e-9));
      expect(head.dx, greaterThan(5.5));
      expect(head.dx, lessThan(6.5));
      expect(game.localFacing, Direction.right);
      expect(predictor.prediction!.to.first, const Position(6, 5));
    },
  );

  test(
    'a swipe that can make the next tick bends the head on the next frame',
    () {
      final (:predictor, :game) = setUpMatch();
      run(game, .05);
      final before = game.localCells!.first;

      predictor.recordInput(
        Direction.up,
        sentAt: const Duration(milliseconds: 50),
      );
      game.syncState(
        snapshot: game.snapshot,
        theme: game.theme,
        prediction: predictor.prediction,
      );
      game.update(frame);

      final after = game.localCells!.first;
      expect(game.localFacing, Direction.up);
      expect(after.dy, lessThan(before.dy), reason: 'moving up already');
      // ...but eased, not teleported onto the new path.
      expect((after - before).distance, lessThan(.2));

      run(game, .3);
      expect(game.localCells!.first.dx, closeTo(5.5, 1e-6));
      expect(game.localCells!.first.dy, closeTo(4.5, 1e-6));
    },
  );

  test(
    'a swipe too late for the next tick turns the head on the next frame',
    () {
      final (:predictor, :game) = setUpMatch();
      run(game, .2);

      predictor.recordInput(
        Direction.up,
        sentAt: const Duration(milliseconds: 200),
      );
      game.syncState(
        snapshot: game.snapshot,
        theme: game.theme,
        prediction: predictor.prediction,
      );
      game.update(frame);

      expect(game.localFacing, Direction.up);
      expect(
        game.localCells!.first.dy,
        closeTo(5.5, 1e-9),
        reason: 'the body keeps going straight to the cell the server will',
      );
    },
  );

  test(
    'a correct prediction hands over to the next snapshot without a jump',
    () {
      final (:predictor, :game) = setUpMatch();
      run(game, .35);
      final before = game.localCells!.first;

      final next = snap(11, const [
        Position(6, 5),
        Position(5, 5),
        Position(4, 5),
      ]);
      predictor.onSnapshot(
        next,
        userId: me,
        boardSize: 20,
        receivedAt: const Duration(milliseconds: 300),
      );
      game.syncState(
        snapshot: next,
        theme: game.theme,
        prediction: predictor.prediction,
      );
      game.update(frame);

      expect((game.localCells!.first - before).distance, lessThan(.1));
    },
  );

  test('a misprediction is eased out, not snapped', () {
    final (:predictor, :game) = setUpMatch();
    predictor.recordInput(
      Direction.up,
      sentAt: const Duration(milliseconds: 50),
    );
    game.syncState(
      snapshot: game.snapshot,
      theme: game.theme,
      prediction: predictor.prediction,
    );
    run(game, .35);
    final before = game.localCells!.first; // on (5, 4)'s centre

    // The input missed tick 11: the server went straight.
    final next = snap(11, const [
      Position(6, 5),
      Position(5, 5),
      Position(4, 5),
    ]);
    predictor.onSnapshot(
      next,
      userId: me,
      boardSize: 20,
      receivedAt: const Duration(milliseconds: 300),
    );
    game.syncState(
      snapshot: next,
      theme: game.theme,
      prediction: predictor.prediction,
    );
    game.update(frame);

    final firstFrame = game.localCells!.first;
    expect((firstFrame - before).distance, lessThan(.15));

    // The glide window stretches to the observed snapshot spacing (350ms
    // here), so give it the whole of that to land.
    run(game, .5);
    expect(predictor.mispredictions, 1);
    expect(game.localCells!.first.dx, closeTo(6.5, 1e-6));
    expect(game.localCells!.first.dy, closeTo(4.5, 1e-6));
  });

  test('without a prediction the painter draws the snapshot', () {
    final (:predictor, :game) = setUpMatch();
    game.syncState(snapshot: game.snapshot, theme: game.theme);
    game.update(frame);
    expect(game.localCells, isNull);
    expect(game.localFacing, isNull);
    expect(predictor.prediction, isNotNull);
  });
}

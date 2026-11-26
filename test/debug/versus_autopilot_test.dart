import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/debug/versus_autopilot.dart';
import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/utils/direction.dart';

MatchPlayerState _player(String id, List<Position> body, Direction dir) =>
    MatchPlayerState(
      playerIndex: id == 'me' ? 0 : 1,
      userId: id,
      username: id,
      alive: true,
      connected: true,
      direction: dir,
      score: 0,
      deathReason: null,
      body: body,
    );

MatchSnapshot _snap(Position food, List<MatchPlayerState> players) =>
    MatchSnapshot(tick: 1, tickMs: 200, elapsedGameMs: 0, food: food, players: players);

void main() {
  test('heads for the food when the way is clear', () {
    final me = _player('me', const [Position(5, 5), Position(4, 5), Position(3, 5)], Direction.right);
    final d = versusAutopilotDirection(
      snapshot: _snap(const Position(6, 10), [me]),
      userId: 'me',
      boardSize: 20,
      heading: Direction.right,
    );
    // Plans from (6,5) — one step ahead — so the food is straight down.
    expect(d, Direction.down);
  });

  test('never turns into the wall', () {
    final me = _player('me', const [Position(18, 0), Position(17, 0), Position(16, 0)], Direction.right);
    final d = versusAutopilotDirection(
      snapshot: _snap(const Position(0, 0), [me]),
      userId: 'me',
      boardSize: 20,
      heading: Direction.right,
    );
    // Head will be at (19,0): right and up are walls, left is a reversal.
    expect(d, Direction.down);
  });

  test("steers around the rival's body", () {
    final me = _player('me', const [Position(5, 5), Position(4, 5), Position(3, 5)], Direction.right);
    // A rival wall in column 7 rows 0-15, food behind it.
    final rival = _player(
      'rival',
      [for (var y = 0; y <= 15; y++) Position(7, y)],
      Direction.down,
    );
    final d = versusAutopilotDirection(
      snapshot: _snap(const Position(10, 5), [me, rival]),
      userId: 'me',
      boardSize: 20,
      heading: Direction.right,
    );
    // From (6,5) straight on is the rival; the way round is down.
    expect(d, Direction.down);
  });
}

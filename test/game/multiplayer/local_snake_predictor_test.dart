import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/game/multiplayer/local_snake_predictor.dart';
import 'package:snake_classic/models/input_result.dart';
import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/presentation/bloc/multiplayer/multiplayer_steering.dart';
import 'package:snake_classic/utils/direction.dart';

/// Client-side prediction of the local snake.
///
/// Everything here is inputs + snapshots in, predicted body out, with time
/// passed explicitly — no clocks, no hub. The server rules being mirrored are
/// `MatchRoom.QueueInput` / `AdvanceTick` in the backend.
void main() {
  const me = 'me';
  const rival = 'rival';
  const board = 20;

  // Default round trip is 180ms and ticks are 300ms here, so an input sent
  // less than 120ms after a snapshot arrives makes the next tick.
  Duration ms(int v) => Duration(milliseconds: v);

  MatchPlayerState player(
    String id, {
    required List<Position> body,
    Direction direction = Direction.right,
    bool alive = true,
    int index = 0,
  }) {
    return MatchPlayerState(
      playerIndex: index,
      userId: id,
      username: id,
      alive: alive,
      connected: true,
      direction: direction,
      score: 0,
      deathReason: alive ? null : 'wall',
      body: body,
    );
  }

  /// A snapshot with my snake heading [dir] and its head at [head], body
  /// trailing straight behind it opposite to [dir].
  List<Position> straight(Position head, Direction dir, {int length = 3}) {
    final back = dir.opposite;
    final cells = <Position>[head];
    for (var i = 1; i < length; i++) {
      cells.add(cells.last.move(back));
    }
    return cells;
  }

  MatchSnapshot snap(
    int tick, {
    required List<Position> body,
    Direction dir = Direction.right,
    bool alive = true,
    Position food = const Position(15, 15),
    List<Position>? rivalBody,
    int tickMs = 300,
  }) {
    return MatchSnapshot(
      tick: tick,
      tickMs: tickMs,
      elapsedGameMs: tick * tickMs,
      food: food,
      players: [
        player(me, body: body, direction: dir, alive: alive),
        player(
          rival,
          body:
              rivalBody ??
              const [Position(15, 2), Position(16, 2), Position(17, 2)],
          direction: Direction.left,
          index: 1,
        ),
      ],
    );
  }

  LocalSnakePredictor started(
    MatchSnapshot first, {
    Duration at = Duration.zero,
  }) {
    final p = LocalSnakePredictor();
    p.onSnapshot(first, userId: me, boardSize: board, receivedAt: at);
    return p;
  }

  SnapshotFit feed(LocalSnakePredictor p, MatchSnapshot s, Duration at) =>
      p.onSnapshot(s, userId: me, boardSize: board, receivedAt: at);

  final start = straight(const Position(5, 5), Direction.right);

  group('the next step', () {
    test(
      'with nothing pending the snake is predicted one cell straight on',
      () {
        final p = started(snap(10, body: start));
        final pred = p.prediction!;

        expect(pred.baseTick, 10);
        expect(pred.from, start);
        expect(pred.to, const [Position(6, 5), Position(5, 5), Position(4, 5)]);
        expect(pred.heading, Direction.right);
        expect(pred.facing, Direction.right);
        expect(pred.stalled, isFalse);
      },
    );

    test('an input that can make the next tick re-aims the glide at once', () {
      final p = started(snap(10, body: start));
      p.recordInput(Direction.up, sentAt: ms(50));

      final pred = p.prediction!;
      expect(p.pending.single.etaTick, 11);
      expect(pred.to.first, const Position(5, 4));
      expect(pred.heading, Direction.up);
      expect(pred.facing, Direction.up);
    });

    test(
      'an input too late for the next tick turns the head, not the body',
      () {
        // 200ms after the snapshot plus a 180ms round trip lands after tick 11
        // has run, so the server applies it at tick 12. Turning the body now
        // would be yanked back by the next snapshot.
        final p = started(snap(10, body: start));
        p.recordInput(Direction.up, sentAt: ms(200));

        final pred = p.prediction!;
        expect(p.pending.single.etaTick, 12);
        expect(pred.to.first, const Position(6, 5));
        expect(pred.heading, Direction.right);
        expect(pred.facing, Direction.up, reason: 'the head answers the swipe');
      },
    );

    test('... and the body turns from the very next snapshot', () {
      final p = started(snap(10, body: start));
      p.recordInput(Direction.up, sentAt: ms(200));

      final next = straight(const Position(6, 5), Direction.right);
      expect(feed(p, snap(11, body: next), ms(300)), SnapshotFit.advanced);

      expect(p.pending.single.direction, Direction.up);
      expect(p.prediction!.from, next);
      expect(p.prediction!.to.first, const Position(6, 4));
      expect(p.mispredictions, 0);
    });

    test(
      'food under the predicted head grows the body; the food stays put',
      () {
        final s = snap(10, body: start, food: const Position(6, 5));
        final p = started(s);

        expect(p.prediction!.to, const [
          Position(6, 5),
          Position(5, 5),
          Position(4, 5),
          Position(3, 5),
        ]);
        // Purely visual: the snapshot (food, score) is untouched.
        expect(p.base!.food, const Position(6, 5));
        expect(p.base!.playerByUserId(me)!.score, 0);
      },
    );

    test('nothing is predicted for a dead or absent local player', () {
      expect(started(snap(10, body: start, alive: false)).prediction, isNull);

      final p = LocalSnakePredictor();
      p.onSnapshot(
        snap(10, body: start),
        userId: 'somebody else',
        boardSize: board,
        receivedAt: Duration.zero,
      );
      expect(p.prediction, isNull);
    });
  });

  group('death is never predicted', () {
    test('a wall ahead holds the snake where the server last had it', () {
      final atWall = straight(const Position(19, 5), Direction.right);
      final pred = started(snap(10, body: atWall)).prediction!;
      expect(pred.stalled, isTrue);
      expect(pred.to, atWall);
    });

    test('its own body ahead holds it', () {
      // A tight curl: heading up into its own segment at (5, 4).
      const curled = [
        Position(5, 5),
        Position(6, 5),
        Position(6, 4),
        Position(5, 4),
        Position(4, 4),
      ];
      final pred = started(snap(10, body: curled, dir: Direction.up))
          .prediction!;
      expect(pred.stalled, isTrue);
    });

    test('the cell its own tail is leaving is safe, as on the server', () {
      const loop = [
        Position(5, 5),
        Position(6, 5),
        Position(6, 4),
        Position(5, 4),
      ];
      final pred = started(snap(10, body: loop, dir: Direction.up)).prediction!;
      expect(pred.stalled, isFalse);
      expect(pred.to.first, const Position(5, 4));
    });

    test("the rival's body holds it; the rival's tail does not", () {
      final intoBody = started(
        snap(
          10,
          body: start,
          rivalBody: const [Position(6, 4), Position(6, 5), Position(6, 6)],
        ),
      ).prediction!;
      expect(intoBody.stalled, isTrue);

      final intoTail = started(
        snap(
          10,
          body: start,
          rivalBody: const [Position(6, 3), Position(6, 4), Position(6, 5)],
        ),
      ).prediction!;
      expect(intoTail.stalled, isFalse);
    });

    test('a stalled prediction is not scored against the snapshot', () {
      final atWall = straight(const Position(19, 5), Direction.right);
      final p = started(snap(10, body: atWall));
      feed(
        p,
        snap(
          11,
          body: const [Position(20, 5), Position(19, 5), Position(18, 5)],
          alive: false,
        ),
        ms(300),
      );
      expect(p.predictionsChecked, 0);
      expect(p.prediction, isNull);
    });
  });

  group('reconciliation', () {
    test('a confirmed turn leaves nothing pending and counts as a hit', () {
      final p = started(snap(10, body: start));
      p.recordInput(Direction.up, sentAt: ms(50));

      final turned = [const Position(5, 4), ...start.take(2)];
      feed(p, snap(11, body: turned, dir: Direction.up), ms(300));

      expect(p.pending, isEmpty);
      expect(p.lastPendingDirection, isNull);
      expect(p.predictionsChecked, 1);
      expect(p.mispredictions, 0);
      expect(p.prediction!.to.first, const Position(5, 3));
    });

    test('an input that arrived a tick late is counted, kept, and applied '
        'on the next prediction', () {
      final p = started(snap(10, body: start));
      p.recordInput(Direction.up, sentAt: ms(50));
      expect(p.prediction!.to.first, const Position(5, 4));

      // The server went straight: our input missed tick 11.
      final next = straight(const Position(6, 5), Direction.right);
      feed(p, snap(11, body: next), ms(300));

      expect(p.mispredictions, 1);
      expect(p.pending.single.direction, Direction.up);
      expect(p.prediction!.to.first, const Position(6, 4));
    });

    test('an input the server never applies expires and frees the reversal '
        'reference', () {
      // A refused input (dead-on-arrival, lost frame) must not pin the
      // heading forever — the old per-snapshot intent reset existed for
      // exactly this, and expiry keeps the guarantee.
      final p = started(snap(10, body: start));
      p.recordInput(Direction.up, sentAt: ms(50)); // eta 11

      var head = const Position(5, 5);
      for (var tick = 11; tick <= 14; tick++) {
        head = head.move(Direction.right);
        feed(
          p,
          snap(tick, body: straight(head, Direction.right)),
          ms(300 * (tick - 10)),
        );
        if (tick < 15) {
          expect(
            p.lastPendingDirection,
            tick <= 11 + LocalSnakePredictor.lateTicksBeforeExpiry
                ? Direction.up
                : isNull,
            reason: 'tick $tick',
          );
        }
      }
      head = head.move(Direction.right);
      feed(p, snap(15, body: straight(head, Direction.right)), ms(1500));
      expect(p.pending, isEmpty);
      expect(p.prediction!.heading, Direction.right);
      expect(p.prediction!.facing, Direction.right);
    });

    test('a committed direction we never sent drops everything pending', () {
      final p = started(snap(10, body: start));
      p.recordInput(Direction.up, sentAt: ms(50));

      final down = [const Position(5, 6), ...start.take(2)];
      feed(p, snap(11, body: down, dir: Direction.down), ms(300));
      expect(p.pending, isEmpty);
      expect(p.prediction!.heading, Direction.down);
    });

    test('a stale snapshot is ignored outright', () {
      final p = started(snap(10, body: start));
      final next = straight(const Position(6, 5), Direction.right);
      feed(p, snap(11, body: next), ms(300));
      final before = p.prediction;

      expect(feed(p, snap(10, body: start), ms(320)), SnapshotFit.stale);
      expect(p.base!.tick, 11);
      expect(identical(p.prediction, before), isTrue);
    });

    test('a duplicate tick keeps the original arrival time', () {
      // MatchResumed can repeat the tick the broadcast already delivered.
      // Re-stamping the arrival would push every input's arrival estimate
      // late.
      final p = started(snap(10, body: start));
      expect(feed(p, snap(10, body: start), ms(250)), SnapshotFit.duplicate);

      // 150ms after the ORIGINAL arrival + 180ms round trip misses tick 11.
      // Measured from the duplicate it would wrongly look in time.
      p.recordInput(Direction.up, sentAt: ms(150));
      expect(p.pending.single.etaTick, 12);
    });

    test(
      'a reconnect jump drops pending inputs and rebuilds from the server',
      () {
        final p = started(snap(10, body: start));
        p.recordInput(Direction.up, sentAt: ms(200));

        final later = straight(const Position(9, 5), Direction.right);
        expect(feed(p, snap(14, body: later), ms(5000)), SnapshotFit.resynced);
        expect(p.pending, isEmpty);
        expect(p.prediction!.from, later);
        expect(p.prediction!.to.first, const Position(10, 5));
        expect(p.predictionsChecked, 0, reason: 'nothing comparable to score');
      },
    );

    test('a tick far below the base is a new match, not a stale packet', () {
      final p = started(snap(400, body: start));
      p.recordInput(Direction.up, sentAt: ms(200));

      final fresh = straight(const Position(4, 5), Direction.right);
      expect(feed(p, snap(0, body: fresh), ms(9000)), SnapshotFit.reset);
      expect(p.pending, isEmpty);
      expect(p.base!.tick, 0);
      expect(p.prediction!.from, fresh);
    });

    test('reset forgets the match but keeps the measured round trip', () {
      final p = started(snap(10, body: start));
      p.recordRoundTrip(ms(60));
      p.recordInput(Direction.up, sentAt: ms(50));
      p.reset();

      expect(p.base, isNull);
      expect(p.prediction, isNull);
      expect(p.pending, isEmpty);
      expect(p.roundTrip, ms(60));
    });
  });

  group('the server buffer, mirrored', () {
    test('commitDirection follows the drain loop', () {
      Direction commit(Direction d, List<Direction> q) =>
          LocalSnakePredictor.commitDirection(d, q);
      const r = Direction.right, u = Direction.up;
      const l = Direction.left, d = Direction.down;

      expect(commit(r, []), r);
      expect(commit(r, [u]), u);
      expect(commit(r, [l, u]), u, reason: 'a reversal is skipped');
      expect(commit(r, [r, u]), r, reason: 'a repeat stops the drain');
      expect(
        commit(r, [u, l, d]),
        d,
        reason: 'depth 2 drops the oldest; left then reverses and is skipped',
      );
    });

    test('three quick inputs reconcile through the buffer', () {
      final p = started(snap(10, body: start));
      p.recordInput(Direction.up, sentAt: ms(10));
      p.recordInput(Direction.left, sentAt: ms(20));
      p.recordInput(Direction.down, sentAt: ms(30));
      expect(p.prediction!.heading, Direction.down);

      final down = [const Position(5, 6), ...start.take(2)];
      feed(p, snap(11, body: down, dir: Direction.down), ms(300));
      expect(p.pending, isEmpty);
      expect(p.mispredictions, 0);
    });

    test('two quick turns land on consecutive ticks', () {
      final p = started(snap(10, body: start));
      p.recordInput(Direction.up, sentAt: ms(10));
      p.recordInput(Direction.left, sentAt: ms(20));
      // Only one commit per tick: up first.
      expect(p.prediction!.heading, Direction.up);

      final up = [const Position(5, 4), ...start.take(2)];
      feed(p, snap(11, body: up, dir: Direction.up), ms(300));
      expect(p.pending.single.direction, Direction.left);
      expect(p.prediction!.to.first, const Position(4, 4));
    });

    test('a quick corner after a snapshot is accepted, a U-turn into the '
        'pending turn is not', () {
      // The old client reset its reversal reference on every snapshot. At a
      // 190ms round trip the input is usually still in flight then, so the
      // second half of a quick corner (up, then left) was measured against
      // "right" and refused, while a reversal of the pending "up" was sent
      // and silently dropped by the server.
      final p = started(snap(10, body: start));
      p.recordInput(Direction.up, sentAt: ms(200));
      feed(
        p,
        snap(11, body: straight(const Position(6, 5), Direction.right)),
        ms(300),
      );

      InputResult press(Direction requested) => MultiplayerSteering.resolve(
        canSteerNow: true,
        requested: requested,
        intent: p.lastPendingDirection,
        committed: p.base!.playerByUserId(me)!.direction,
      );

      expect(press(Direction.left), InputResult.accepted);
      expect(press(Direction.down), InputResult.rejected);
      expect(press(Direction.up), InputResult.rejected);
    });
  });

  group('the steps after next (the late-snapshot lookahead)', () {
    test('with nothing pending the path runs straight on for two steps', () {
      final pred = started(snap(10, body: start)).prediction!;
      expect(pred.steps, [
        const [Position(6, 5), Position(5, 5), Position(4, 5)],
        const [Position(7, 5), Position(6, 5), Position(5, 5)],
      ]);
      expect(pred.steps.first, pred.to);
    });

    test('an input due the tick after next bends only the second step', () {
      final p = started(snap(10, body: start));
      p.recordInput(Direction.up, sentAt: ms(200)); // eta 12
      final steps = p.prediction!.steps;
      expect(steps[0].first, const Position(6, 5));
      expect(steps[1].first, const Position(6, 4));
    });

    test('a quick corner takes one tick per turn, as the server drains it', () {
      final p = started(snap(10, body: start));
      p.recordInput(Direction.up, sentAt: ms(10));
      p.recordInput(Direction.left, sentAt: ms(20));
      final steps = p.prediction!.steps;
      expect(steps[0].first, const Position(5, 4));
      expect(steps[1].first, const Position(4, 4));
    });

    test('the path stops before a fatal second step, never into it', () {
      final nearWall = straight(const Position(18, 5), Direction.right);
      final pred = started(snap(10, body: nearWall)).prediction!;
      expect(pred.stalled, isFalse);
      expect(pred.steps, hasLength(1));
      expect(pred.steps.single.first, const Position(19, 5));
    });

    test('food eaten on the first step does not grow the second', () {
      final s = snap(10, body: start, food: const Position(6, 5));
      final steps = started(s).prediction!.steps;
      expect(steps[0], hasLength(4));
      expect(steps[1], hasLength(4));
      expect(steps[1].first, const Position(7, 5));
    });

    test('planDirections agrees with commitDirection on the first tick', () {
      const all = Direction.values;
      var checked = 0;
      for (final current in all) {
        for (final a in all) {
          for (final b in all) {
            for (final c in all) {
              final queued = [a, b, c];
              final pending = [for (final d in queued) PendingInput(d, 11)];
              final plan = LocalSnakePredictor.planDirections(
                current,
                pending,
                firstTick: 11,
                ticks: 1,
              );
              expect(
                plan.single,
                LocalSnakePredictor.commitDirection(current, queued),
              );
              checked++;
            }
          }
        }
      }
      expect(checked, 256);
    });

    test('a later input never overtakes an earlier one still in flight', () {
      final plan = LocalSnakePredictor.planDirections(
        Direction.right,
        const [
          PendingInput(Direction.up, 12),
          PendingInput(Direction.left, 11),
        ],
        firstTick: 11,
        ticks: 2,
      );
      expect(plan, [Direction.right, Direction.up]);
    });
  });

  group('arrival estimate', () {
    test('a shorter measured round trip moves the deadline later', () {
      final p = started(snap(10, body: start));
      expect(p.etaFor(ms(200)), 12);

      p.recordRoundTrip(ms(50));
      expect(p.roundTrip, ms(50));
      expect(p.etaFor(ms(200)), 11);
    });

    test('round-trip samples are smoothed, and nonsense is ignored', () {
      final p = LocalSnakePredictor();
      p.recordRoundTrip(ms(200));
      p.recordRoundTrip(ms(600));
      expect(p.roundTrip, ms(300));

      p.recordRoundTrip(Duration.zero);
      p.recordRoundTrip(const Duration(seconds: 30));
      expect(p.roundTrip, ms(300));
    });

    test('a snapshot that is overdue pushes the estimate further out', () {
      final p = started(snap(10, body: start));
      expect(p.etaFor(ms(300)), 12);
      expect(p.etaFor(ms(450)), 13);
      expect(p.etaFor(ms(800)), 14);
    });

    test('the prediction never runs more than one tick ahead', () {
      // However many inputs are queued and however late, the predicted body is
      // always exactly one step from the authoritative one.
      final p = started(snap(10, body: start));
      p.recordInput(Direction.up, sentAt: ms(10));
      p.recordInput(Direction.left, sentAt: ms(20));
      p.recordInput(Direction.up, sentAt: ms(900));

      final pred = p.prediction!;
      final head = pred.to.first, was = pred.from.first;
      expect((head.x - was.x).abs() + (head.y - was.y).abs(), 1);
      expect(pred.to.skip(1), pred.from.take(pred.from.length - 1));
    });
  });

  test('the same inputs and snapshots always predict the same body', () {
    List<List<Position>?> run() {
      final p = started(snap(10, body: start));
      final out = <List<Position>?>[];
      p.recordInput(Direction.up, sentAt: ms(40));
      out.add(p.prediction?.to);
      feed(
        p,
        snap(
          11,
          body: [const Position(5, 4), ...start.take(2)],
          dir: Direction.up,
        ),
        ms(300),
      );
      out.add(p.prediction?.to);
      p.recordInput(Direction.left, sentAt: ms(500));
      out.add(p.prediction?.to);
      return out;
    }

    expect(run(), run());
  });
}

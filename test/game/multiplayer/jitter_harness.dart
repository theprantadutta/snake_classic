import 'dart:math' as math;

import 'package:snake_classic/game/flame/multiplayer_flame_game.dart';
import 'package:snake_classic/game/multiplayer/local_snake_predictor.dart';
import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';

/// A scripted online match for the render-clock tests: a server that ticks
/// on a steady schedule, a network that delivers its snapshots late, early,
/// in bursts and after gaps, and a 60 fps frame loop that feeds them to the
/// predictor and the board exactly as the cubit and the board widget do.
///
/// Both snakes run straight right along their own row of a wide board, so
/// "smooth" has a simple meaning: the head's x only ever grows, by about the
/// same amount every frame.
const String me = 'me';
const String rival = 'rival';
const int wideBoard = 400;
const double frame = 1 / 60;

const int myRow = 5;
const int rivalRow = 50;
const int startTick = 10;
const int startX = 5;

/// Where a straight-right snake's head is at [tick].
int headXAt(int tick) => startX + (tick - startTick);

List<Position> straightBody(int headX, int row, {int length = 4}) => [
  for (var i = 0; i < length; i++) Position(headX - i, row),
];

MatchSnapshot serverSnapshot(
  int tick, {
  required int tickMs,
  Position food = const Position(399, 399),
  int myLength = 4,
  int myScore = 0,
  int rivalLength = 4,
  int rivalScore = 0,
  bool rivalAlive = true,
}) {
  final x = headXAt(tick);
  return MatchSnapshot(
    tick: tick,
    tickMs: tickMs,
    elapsedGameMs: tick * tickMs,
    food: food,
    players: [
      MatchPlayerState(
        playerIndex: 0,
        userId: me,
        username: me,
        alive: true,
        connected: true,
        direction: Direction.right,
        score: myScore,
        deathReason: null,
        body: straightBody(x, myRow, length: myLength),
      ),
      MatchPlayerState(
        playerIndex: 1,
        userId: rival,
        username: rival,
        alive: rivalAlive,
        connected: true,
        direction: Direction.right,
        score: rivalScore,
        deathReason: rivalAlive ? null : 'wall',
        body: straightBody(x, rivalRow, length: rivalLength),
      ),
    ],
  );
}

/// One snapshot and when the phone receives it, in seconds.
class Delivery {
  Delivery(this.snapshot, this.at);
  final MatchSnapshot snapshot;
  final double at;
}

/// Server tick times: tick [startTick] at t=0, each later one a tick length
/// after the one before, the length given per tick by [tickMsAt].
List<double> serverTimes(int ticks, int Function(int tick) tickMsAt) {
  final times = <double>[0];
  for (var i = 1; i < ticks; i++) {
    times.add(times.last + tickMsAt(startTick + i - 1) / 1000);
  }
  return times;
}

/// Deliveries for [ticks] snapshots: a fixed one-way delay plus uniform
/// jitter of ±[jitterMs], every [burstEvery]th snapshot held back to land
/// together with the next, and every [gapEvery]th delayed by [gapMs] (the
/// ones behind it queue up behind it, as on a real ordered transport).
List<Delivery> deliveries({
  required int ticks,
  required int Function(int tick) tickMsAt,
  MatchSnapshot Function(int tick, int tickMs)? build,
  double baseDelayMs = 100,
  double jitterMs = 150,
  int burstEvery = 0,
  int gapEvery = 0,
  double gapMs = 500,
  int seed = 7,
}) {
  final rng = math.Random(seed);
  final times = serverTimes(ticks, tickMsAt);
  final arrivals = <double>[];
  for (var i = 0; i < ticks; i++) {
    final jitter = (rng.nextDouble() * 2 - 1) * jitterMs;
    var at = times[i] + (baseDelayMs + jitter) / 1000;
    if (gapEvery > 0 && i > 0 && i % gapEvery == 0) {
      // The gap: this one arrives gapMs after the previous one at the
      // earliest.
      at = math.max(at, arrivals.last + gapMs / 1000);
    }
    if (i > 0) at = math.max(at, arrivals.last); // ordered transport
    arrivals.add(at);
  }
  bool isGap(int i) => gapEvery > 0 && i > 0 && i % gapEvery == 0;
  if (burstEvery > 0) {
    for (var i = burstEvery; i + 1 < ticks; i += burstEvery) {
      // Held back to land with the next. Not across a gap: a packet held
      // into the one after a gap is two ticks late, which is the separate
      // "very late packet" case, not a burst.
      if (isGap(i + 1)) continue;
      arrivals[i] = arrivals[i + 1];
    }
  }
  return [
    for (var i = 0; i < ticks; i++)
      Delivery(
        (build ?? (t, ms) => serverSnapshot(t, tickMs: ms))(
          startTick + i,
          tickMsAt(startTick + i),
        ),
        arrivals[i],
      ),
  ];
}

/// What one frame drew.
class FrameSample {
  FrameSample({
    required this.time,
    required this.newestTick,
    required this.newestTickMs,
    required this.localX,
    required this.rivalX,
    required this.localTick,
    required this.remoteTick,
    required this.remoteDelay,
  });

  final double time;
  final int newestTick;
  final int newestTickMs;
  final double? localX;
  final double? rivalX;
  final double localTick;
  final double remoteTick;
  final double remoteDelay;

  /// The newest snapshot's head centre for a straight-right snake.
  double get newestHeadCentre => headXAt(newestTick) + .5;
}

/// Plays [plan] through a predictor and a board at 60 fps for [seconds].
class MatchRun {
  MatchRun(this.plan, {this.onFrame});

  final List<Delivery> plan;
  final void Function(MatchRun run, FrameSample sample)? onFrame;
  final samples = <FrameSample>[];
  late final LocalSnakePredictor predictor;
  late final MultiplayerFlameGame game;
  var _next = 0;
  var time = 0.0;
  var localBites = 0;

  void deliverDue() {
    while (_next < plan.length && plan[_next].at <= time + 1e-9) {
      deliver(plan[_next].snapshot);
      _next++;
    }
  }

  void deliver(MatchSnapshot s) {
    predictor.onSnapshot(
      s,
      userId: me,
      boardSize: wideBoard,
      receivedAt: Duration(microseconds: (time * 1e6).round()),
    );
    game.syncState(
      snapshot: s,
      theme: game.theme,
      prediction: predictor.prediction,
    );
  }

  void start() {
    final first = plan.first;
    time = first.at;
    predictor = LocalSnakePredictor();
    predictor.onSnapshot(
      first.snapshot,
      userId: me,
      boardSize: wideBoard,
      receivedAt: Duration(microseconds: (time * 1e6).round()),
    );
    game = MultiplayerFlameGame(
      snapshot: first.snapshot,
      currentUserId: me,
      boardSize: wideBoard,
      theme: GameTheme.values.first,
      prediction: predictor.prediction,
      onLocalFoodEaten: () => localBites++,
    );
    _next = 1;
  }

  void runFor(double seconds) {
    final end = time + seconds;
    while (time < end - 1e-9) {
      time += frame;
      deliverDue();
      game.update(frame);
      final sample = FrameSample(
        time: time,
        newestTick: game.snapshot.tick,
        newestTickMs: game.snapshot.tickMs,
        localX: game.localCells?.first.dx,
        rivalX: game.remotePoses[1]?.cells.first.dx,
        localTick: game.localRenderTick,
        remoteTick: game.remoteRenderTick,
        remoteDelay: game.remoteDelay,
      );
      samples.add(sample);
      onFrame?.call(this, sample);
    }
  }

  /// Runs until every planned snapshot has been delivered, plus [tail].
  void runAll({double tail = 0}) {
    runFor(plan.last.at - time + tail);
  }
}

/// Motion statistics for one snake's head x over a run.
class MotionStats {
  MotionStats(
    List<FrameSample> samples,
    double? Function(FrameSample) x, {
    double after = 0,
  }) {
    double? prev;
    FrameSample? prevSample;
    var stillFor = 0.0;
    final t0 = samples.isEmpty ? 0 : samples.first.time;
    for (final s in samples) {
      if (s.time - t0 < after) continue;
      final v = x(s);
      if (v == null) continue;
      if (prev != null && prevSample != null) {
        final step = v - prev;
        // The tick length can change between two frames; judge against
        // the faster of the two.
        final nominal =
            frame * 1000 / math.min(prevSample.newestTickMs, s.newestTickMs);
        minStep = math.min(minStep, step);
        maxStepRatio = math.max(maxStepRatio, step / nominal);
        if (step < .2 * nominal) {
          stillFor += frame;
          longestStall = math.max(longestStall, stillFor);
        } else {
          stillFor = 0;
        }
      }
      prev = v;
      prevSample = s;
    }
  }

  /// The most negative frame-to-frame move (a move backwards), in cells.
  double minStep = double.infinity;

  /// The largest frame-to-frame move as a multiple of the nominal one.
  double maxStepRatio = 0;

  /// The longest stretch spent moving under a fifth of the nominal speed,
  /// in seconds.
  double longestStall = 0;

  @override
  String toString() =>
      'minStep=${minStep.toStringAsFixed(4)} '
      'maxStepRatio=${maxStepRatio.toStringAsFixed(2)} '
      'longestStall=${(longestStall * 1000).round()}ms';
}

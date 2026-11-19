import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';
import 'package:snake_classic/utils/direction.dart';

/// Profiling aid: the snake steers itself, so frame pacing can be measured
/// on a device without anyone playing.
///
///   flutter run --profile -d DEVICE --dart-define=LB_AUTOPILOT=true
///
/// Off unless that define is set (a compile-time constant, so release builds
/// without it carry none of this). Never ship a build with it on.
///
/// It drives the game through [GameCubit.changeDirection], the same entry
/// point a swipe uses, so input feedback (haptics, head shimmer, edge bloom)
/// is part of what gets measured. It also starts [FrameStatsLogger].
class Autopilot {
  Autopilot(this._cubit);

  static const bool enabled = bool.fromEnvironment('LB_AUTOPILOT');

  final GameCubit _cubit;
  StreamSubscription<GameCubitState>? _sub;
  Position? _lastHead;

  void start() {
    if (!enabled) return;
    _sub = _cubit.stream.listen(_onState);
    FrameStatsLogger.instance.start();
    debugPrint('[AUTOPILOT] on');
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }

  void _onState(GameCubitState s) {
    if (s.status != GamePlayStatus.playing) return;
    final gs = s.gameState;
    if (gs == null) return;
    final head = gs.snake.head;
    if (head == _lastHead) return; // decide once per tick
    _lastHead = head;
    final dir = _choose(
      body: gs.snake.body,
      food: [
        if (gs.food != null) gs.food!.position,
        ...gs.foods.map((f) => f.position),
      ],
      w: gs.boardWidth,
      h: gs.boardHeight,
      wraps: gs.gameMode == GameMode.zen,
      current: gs.snake.plannedDirection,
    );
    if (dir != null && dir != gs.snake.plannedDirection) {
      _cubit.changeDirection(dir);
    }
  }

  static const _dirs = Direction.values;

  static Position _step(Position p, Direction d) => switch (d) {
        Direction.up => Position(p.x, p.y - 1),
        Direction.down => Position(p.x, p.y + 1),
        Direction.left => Position(p.x - 1, p.y),
        Direction.right => Position(p.x + 1, p.y),
      };

  /// Shortest safe path to food (BFS); if none, the move that leaves the
  /// most open space (flood fill), so it doesn't box itself in.
  static Direction? _choose({
    required List<Position> body,
    required List<Position> food,
    required int w,
    required int h,
    required bool wraps,
    required Direction current,
  }) {
    Position? norm(Position p) {
      if (wraps) return Position((p.x + w) % w, (p.y + h) % h);
      if (p.x < 0 || p.y < 0 || p.x >= w || p.y >= h) return null;
      return p;
    }

    // The tail moves away this tick, so its cell is free.
    final blocked = body.sublist(0, body.length - 1).toSet();
    final head = body.first;
    final candidates = <Direction, Position>{};
    for (final d in _dirs) {
      if (d == current.opposite) continue;
      final n = norm(_step(head, d));
      if (n != null && !blocked.contains(n)) candidates[d] = n;
    }
    if (candidates.isEmpty) return null;

    int space(Position from) {
      final seen = <Position>{from};
      final q = Queue<Position>()..add(from);
      while (q.isNotEmpty && seen.length < body.length * 2 + 8) {
        final p = q.removeFirst();
        for (final d in _dirs) {
          final n = norm(_step(p, d));
          if (n == null || blocked.contains(n) || !seen.add(n)) continue;
          q.add(n);
        }
      }
      return seen.length;
    }

    final targets = food.toSet();
    if (targets.isNotEmpty) {
      // BFS from each first step; take the shortest that keeps room to move.
      Direction? best;
      var bestDist = 1 << 30;
      for (final e in candidates.entries) {
        if (space(e.value) < body.length) continue;
        final dist = _distance(e.value, targets, blocked, norm);
        if (dist != null && dist < bestDist) {
          bestDist = dist;
          best = e.key;
        }
      }
      if (best != null) return best;
    }
    // No safe route to food: maximise free space, prefer going straight.
    Direction? best;
    var bestSpace = -1;
    for (final e in candidates.entries) {
      final sp = space(e.value) + (e.key == current ? 1 : 0);
      if (sp > bestSpace) {
        bestSpace = sp;
        best = e.key;
      }
    }
    return best;
  }

  static int? _distance(
    Position from,
    Set<Position> targets,
    Set<Position> blocked,
    Position? Function(Position) norm,
  ) {
    if (targets.contains(from)) return 0;
    final seen = <Position>{from};
    final q = Queue<(Position, int)>()..add((from, 0));
    while (q.isNotEmpty) {
      final (p, d) = q.removeFirst();
      for (final dir in _dirs) {
        final n = norm(_step(p, dir));
        if (n == null || blocked.contains(n) || !seen.add(n)) continue;
        if (targets.contains(n)) return d + 1;
        q.add((n, d + 1));
      }
    }
    return null;
  }
}

/// Logs frame pacing every 5 s while running:
///   [PERF] 300 frames | build p50/p90/p99 2.1/3.4/5.0 ms | raster ... |
///   over 16.7 ms: 2 (0.7%) | worst 21.3 ms
/// "over 16.7 ms" counts frames whose build or raster missed a 60 Hz vsync.
class FrameStatsLogger {
  FrameStatsLogger._();
  static final instance = FrameStatsLogger._();

  final _build = <double>[];
  final _raster = <double>[];
  Timer? _timer;

  void start() {
    if (_timer != null) return;
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _flush());
  }

  void _onTimings(List<FrameTiming> timings) {
    for (final t in timings) {
      _build.add(t.buildDuration.inMicroseconds / 1000);
      _raster.add(t.rasterDuration.inMicroseconds / 1000);
    }
  }

  void _flush() {
    if (_build.isEmpty) return;
    String pct(List<double> v) {
      final s = [...v]..sort();
      double at(double q) => s[((s.length - 1) * q).round()];
      return '${at(.5).toStringAsFixed(1)}/${at(.9).toStringAsFixed(1)}/'
          '${at(.99).toStringAsFixed(1)}';
    }

    const budget = 1000 / 60;
    var over = 0;
    var worst = 0.0;
    for (var i = 0; i < _build.length; i++) {
      final m = _build[i] > _raster[i] ? _build[i] : _raster[i];
      if (m > budget) over++;
      if (m > worst) worst = m;
    }
    debugPrint('[PERF] ${_build.length} frames | build p50/p90/p99 '
        '${pct(_build)} ms | raster ${pct(_raster)} ms | over 16.7 ms: $over '
        '(${(over * 100 / _build.length).toStringAsFixed(1)}%) | worst '
        '${worst.toStringAsFixed(1)} ms');
    _build.clear();
    _raster.clear();
  }
}

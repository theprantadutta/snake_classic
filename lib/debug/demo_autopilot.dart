// DEMO ONLY. Lives on the demo/autopilot branch for recording the Play Store
// video; never merge it. Enabled with --dart-define=DEMO_AUTOPILOT=true.
import 'dart:collection';

import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/utils/direction.dart';

const bool kDemoAutopilot = bool.fromEnvironment('DEMO_AUTOPILOT');

/// Picks the next heading: the first step of the shortest path to food (or a
/// power-up) when taking it leaves enough room to keep moving, otherwise the
/// move with the most open space. Good enough for long, natural-looking runs.
Direction? demoAutopilotDirection(GameState gs) {
  final w = gs.boardWidth;
  final h = gs.boardHeight;
  final wrap = !gs.gameMode.hasWalls || gs.hasInvincibility || gs.hasGhostMode;
  final body = gs.snake.body;
  if (body.isEmpty) return null;
  final head = body.first;
  final heading = gs.snake.currentDirection;

  Position? step(Position p, Direction d) {
    var n = p.move(d);
    if (wrap) {
      n = Position((n.x + w) % w, (n.y + h) % h);
    } else if (n.x < 0 || n.y < 0 || n.x >= w || n.y >= h) {
      return null;
    }
    return n;
  }

  // The tail cell frees up on the next move (unless we eat), so treat it open.
  final blocked = HashSet<Position>.from(body.sublist(0, body.length - 1));

  final targets = <Position>{
    for (final f in gs.foods) f.position,
    if (gs.food != null) gs.food!.position,
    if (gs.powerUp != null) gs.powerUp!.position,
  };

  int floodArea(Position start, Set<Position> walls, int cap) {
    final seen = HashSet<Position>()..add(start);
    final q = Queue<Position>()..add(start);
    while (q.isNotEmpty && seen.length < cap) {
      final p = q.removeFirst();
      for (final d in Direction.values) {
        final n = step(p, d);
        if (n == null || walls.contains(n) || !seen.add(n)) continue;
        q.add(n);
      }
    }
    return seen.length;
  }

  // BFS from each candidate first move to the nearest target.
  int distToTarget(Position start) {
    if (targets.contains(start)) return 0;
    final seen = HashSet<Position>()..add(start);
    final q = Queue<(Position, int)>()..add((start, 0));
    while (q.isNotEmpty) {
      final (p, dist) = q.removeFirst();
      for (final d in Direction.values) {
        final n = step(p, d);
        if (n == null || blocked.contains(n) || !seen.add(n)) continue;
        if (targets.contains(n)) return dist + 1;
        q.add((n, dist + 1));
      }
    }
    return 1 << 20;
  }

  final need = body.length + 2;
  Direction? best;
  var bestScore = -1 << 30;
  for (final d in Direction.values) {
    if (d == heading.opposite) continue;
    final n = step(head, d);
    if (n == null || blocked.contains(n)) continue;
    final walls = HashSet<Position>.from(blocked)..add(n);
    final area = floodArea(n, walls, need * 2);
    final dist = distToTarget(n);
    final safe = area >= need;
    // Safe moves toward food win; otherwise maximise room.
    final score = (safe ? 1 << 24 : 0) + (safe ? -dist * 16 : area * 16) +
        (d == heading ? 1 : 0);
    if (score > bestScore) {
      bestScore = score;
      best = d;
    }
  }
  return best;
}

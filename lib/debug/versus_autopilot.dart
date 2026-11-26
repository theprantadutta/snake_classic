import 'dart:collection';
import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/utils/direction.dart';

/// Profiling aid for online Versus, the multiplayer half of [Autopilot]
/// (`lib/debug/autopilot.dart`), under the same flag:
///
///   flutter build apk --profile --dart-define=LB_AUTOPILOT=true
///
/// With it on, `MultiplayerCubit` asks [versusAutopilotDirection] for a
/// heading on every snapshot and sends it through `changeDirection` — the
/// path the D-pad uses — so local prediction, the send, the server's tick and
/// the measured round trip are all the real thing. It also starts
/// `FrameStatsLogger` when a match begins and logs the match's network
/// numbers through [vsLog]. Compiled out of any build without the define.
///
/// [vsLog] goes to the VM service's Logging stream (`dart:developer` log):
/// in this app's profile builds print/debugPrint reach neither logcat nor the
/// VM service's Stdout stream. The VM service trims long log strings, so the
/// message is sent in short numbered chunks.
void vsLog(String message) {
  const size = 100;
  final parts = (message.length / size).ceil();
  for (var i = 0; i < parts; i++) {
    final chunk = message.substring(i * size, math.min(message.length, (i + 1) * size));
    developer.log(parts > 1 ? '${i + 1}/$parts $chunk' : chunk, name: 'VS');
  }
}

/// Picks the next heading for [userId]'s snake, or null to keep going.
///
/// Plans from where the head will be when an input sent now can apply: one
/// step ahead along [heading], since the round trip is about one tick. Walls
/// and both bodies are fatal (each live snake's tail moves on, so it is
/// free); the cells next to the rival's head are avoided when there is a
/// choice, to dodge head-on collisions. Takes the shortest path to food when
/// the snake keeps enough open space after the step, otherwise the move with
/// the most room.
Direction? versusAutopilotDirection({
  required MatchSnapshot snapshot,
  required String userId,
  required int boardSize,
  required Direction heading,
}) {
  final me = snapshot.playerByUserId(userId);
  if (me == null || !me.alive || me.body.isEmpty) return null;
  final n = boardSize;

  bool inside(Position p) => p.x >= 0 && p.y >= 0 && p.x < n && p.y < n;

  final blocked = HashSet<Position>();
  final rivalReach = HashSet<Position>();
  for (final p in snapshot.players) {
    if (p.body.isEmpty) continue;
    blocked.addAll(p.alive ? p.body.sublist(0, p.body.length - 1) : p.body);
    if (p.userId != userId && p.alive) {
      for (final d in Direction.values) {
        rivalReach.add(p.body.first.move(d));
      }
    }
  }

  // Where our head is when this input can take effect.
  var head = me.body.first;
  final ahead = head.move(heading);
  if (inside(ahead) && !blocked.contains(ahead)) head = ahead;

  int room(Position start, int cap) {
    final seen = HashSet<Position>()..add(start);
    final q = Queue<Position>()..add(start);
    while (q.isNotEmpty && seen.length < cap) {
      final c = q.removeFirst();
      for (final d in Direction.values) {
        final nx = c.move(d);
        if (!inside(nx) || blocked.contains(nx) || !seen.add(nx)) continue;
        q.add(nx);
      }
    }
    return seen.length;
  }

  final need = math.max(me.body.length + 2, 6);
  final options = <Direction, int>{};
  for (final d in Direction.values) {
    if (d == heading.opposite) continue;
    final nx = head.move(d);
    if (!inside(nx) || blocked.contains(nx)) continue;
    options[d] = room(nx, need * 3);
  }
  if (options.isEmpty) return null;

  bool safe(Direction d) =>
      options[d]! >= need && !rivalReach.contains(head.move(d));

  // Shortest path to food over free cells; remember each cell's first step.
  final food = snapshot.food;
  final firstStep = <Position, Direction>{};
  final q = Queue<Position>();
  final seen = HashSet<Position>()..add(head);
  for (final d in options.keys) {
    final nx = head.move(d);
    if (seen.add(nx)) {
      firstStep[nx] = d;
      q.add(nx);
    }
  }
  while (q.isNotEmpty) {
    final c = q.removeFirst();
    if (c == food) {
      final d = firstStep[c]!;
      if (safe(d)) return d;
      break;
    }
    for (final d in Direction.values) {
      final nx = c.move(d);
      if (!inside(nx) || blocked.contains(nx) || !seen.add(nx)) continue;
      firstStep[nx] = firstStep[c]!;
      q.add(nx);
    }
  }

  // No safe food path: most room, preferring cells the rival can't reach.
  final ranked = options.keys.toList()
    ..sort((a, b) {
      final ra = rivalReach.contains(head.move(a)) ? 1 : 0;
      final rb = rivalReach.contains(head.move(b)) ? 1 : 0;
      if (ra != rb) return ra - rb;
      return options[b]!.compareTo(options[a]!);
    });
  return ranked.first;
}

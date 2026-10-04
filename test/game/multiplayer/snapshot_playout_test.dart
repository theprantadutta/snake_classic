import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/game/multiplayer/snapshot_playout.dart';
import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/utils/direction.dart';

/// The rival's playback buffer on its own.
void main() {
  const frame = 1 / 60;

  MatchSnapshot snap(int tick, {bool alive = true, int? headX}) {
    final x = headX ?? tick;
    return MatchSnapshot(
      tick: tick,
      tickMs: 300,
      elapsedGameMs: tick * 300,
      food: const Position(0, 19),
      players: [
        MatchPlayerState(
          playerIndex: 1,
          userId: 'rival',
          username: 'rival',
          alive: alive,
          connected: true,
          direction: Direction.right,
          score: 0,
          deathReason: alive ? null : 'wall',
          body: [Position(x, 3), Position(x - 1, 3), Position(x - 2, 3)],
        ),
      ],
    );
  }

  void run(SnapshotPlayout p, double seconds) {
    for (var t = 0.0; t < seconds - 1e-9; t += frame) {
      p.advance(frame);
    }
  }

  Offset head(SnapshotPlayout p) => p.poseOf(1)!.cells.first;

  test('starts a delay behind the first snapshot, holding on it', () {
    final p = SnapshotPlayout()..push(snap(10));
    expect(p.renderTick, closeTo(10 - p.delay, 1e-9));
    expect(head(p), const Offset(10.5, 3.5));
    run(p, .2);
    expect(head(p), const Offset(10.5, 3.5), reason: 'nothing to glide to');
  });

  test('glides between the two snapshots around the render tick', () {
    final p = SnapshotPlayout()..push(snap(10));
    for (var tick = 11; tick <= 14; tick++) {
      run(p, .3);
      p.push(snap(tick));
    }
    final at = p.renderTick;
    expect(at, lessThan(14));
    expect(head(p).dx, closeTo(at + .5, 1e-6));
    expect(p.rendered!.tick, at.floor());
  });

  test('never plays past the newest snapshot', () {
    final p = SnapshotPlayout()..push(snap(10));
    run(p, .3);
    p.push(snap(11));
    run(p, 3); // nothing more arrives
    expect(p.renderTick, closeTo(11, 1e-9));
    expect(head(p), const Offset(11.5, 3.5));
  });

  test('stale snapshots are ignored; a duplicate replaces in place', () {
    final p = SnapshotPlayout()..push(snap(10));
    run(p, .3);
    p.push(snap(11));
    p.push(snap(10, headX: 50)); // stale
    p.push(snap(11)); // duplicate
    run(p, 3);
    expect(head(p), const Offset(11.5, 3.5));
  });

  test('a reconnect that skipped ticks starts over instead of gliding '
      'across the gap', () {
    final p = SnapshotPlayout()..push(snap(10));
    run(p, .3);
    p.push(snap(11));
    run(p, .3);
    p.push(snap(30));
    expect(p.renderTick, closeTo(30 - p.delay, 1e-9));
    expect(head(p), const Offset(30.5, 3.5));
    run(p, .3);
    p.push(snap(31));
    run(p, .5);
    expect(head(p).dx, inInclusiveRange(30.5, 31.5));
  });

  test('a new match (the tick restarts) starts over', () {
    final p = SnapshotPlayout()..push(snap(100));
    run(p, .3);
    p.push(snap(101));
    p.push(snap(3));
    expect(p.latest!.tick, 3);
    expect(head(p), const Offset(3.5, 3.5));
  });

  test('a crash glides into the fatal cell and shows dead only once '
      'reached', () {
    final p = SnapshotPlayout()..push(snap(10));
    run(p, .3);
    p.push(snap(11));
    run(p, .3);
    p.push(snap(12, alive: false));
    run(p, .05);
    while (p.renderTick < 11.9) {
      expect(p.poseOf(1)!.alive, isTrue);
      run(p, frame);
    }
    run(p, 2);
    final pose = p.poseOf(1)!;
    expect(pose.alive, isFalse);
    expect(pose.cells.first, const Offset(12.5, 3.5));
  });

  test('the delay stays within its bounds', () {
    final p = SnapshotPlayout();
    expect(p.delay, inInclusiveRange(p.minDelay, p.maxDelay));
  });
}

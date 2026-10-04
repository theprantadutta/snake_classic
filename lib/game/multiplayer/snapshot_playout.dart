import 'dart:collection';

import 'package:snake_classic/game/multiplayer/snake_glide.dart';
import 'package:snake_classic/game/multiplayer/tick_clock.dart';
import 'package:snake_classic/models/match_snapshot.dart';

/// Draws the snakes nobody on this phone steers — the rival — from a small
/// buffer of snapshots, a fixed distance behind the newest one.
///
/// The rival is never predicted, so it can only ever be drawn between two
/// snapshots that have both arrived. Drawn from the latest pair on arrival,
/// every early or late packet shows as a skip or a stall (see [TickClock]).
/// Instead the snapshots are buffered and played back on a steady
/// [TickClock] held [delay] ticks behind the arrivals: one tick so there is
/// always a pair to glide between, plus a margin for the jitter the clock
/// has measured, adapted between [minDelay] and [maxDelay]. A snapshot that
/// is late by less than the margin is in the buffer before the playback
/// needs it, so the lateness never shows. One later than that is waited
/// for with a short ease rather than an abrupt stop.
///
/// Anything tied to a snapshot — the rival eating, the rival dying — should
/// be shown when that snapshot becomes the drawn one ([renderTick] reaching
/// its tick), not when it arrives, or it happens before the snake gets
/// there.
class SnapshotPlayout {
  SnapshotPlayout({
    TickClock? clock,
    this.minDelay = 1.15,
    this.maxDelay = 2.0,
    this.jitterMargin = 2.5,
    this.capacity = 8,
    this.resetTickGap = 20,
  }) : clock =
           clock ??
           TickClock(softZone: .2, resyncThreshold: 2.5, initialJitter: .2);

  /// Paces the playback. Its jitter estimate sizes [delay].
  ///
  /// It tolerates more drift before jumping than the local clock does:
  /// every snapshot it could need is still buffered, so after a long gap
  /// and a burst it is better to catch up a little faster for a few ticks
  /// than to skip the rival forward. It also starts out assuming a rough
  /// link and relaxes as it measures a calm one: a match's first ticks are
  /// when the estimate knows least.
  final TickClock clock;

  /// Bounds on how far behind the newest snapshot playback runs, in ticks.
  final double minDelay;
  final double maxDelay;

  /// How many mean deviations of arrival jitter the delay covers.
  final double jitterMargin;

  /// Most snapshots kept. Only the pair around [renderTick] is needed.
  final int capacity;

  /// A tick this far below the newest is a new match, not a stale packet.
  final int resetTickGap;

  final SplayTreeMap<int, MatchSnapshot> _buffer =
      SplayTreeMap<int, MatchSnapshot>();

  /// How far behind the newest snapshot playback aims to run, in ticks.
  double get delay =>
      (1 + jitterMargin * clock.jitter).clamp(minDelay, maxDelay).toDouble();

  /// The newest snapshot buffered.
  MatchSnapshot? get latest =>
      _buffer.isEmpty ? null : _buffer[_buffer.lastKey()!];

  /// Where playback is on the server's tick axis.
  double get renderTick => clock.position;

  /// Forget everything; the next snapshot starts playback afresh.
  void reset() {
    _buffer.clear();
    clock.reset();
  }

  /// Buffer a snapshot that arrived now.
  void push(MatchSnapshot snapshot) {
    final newest = latest;
    if (newest == null) {
      _start(snapshot);
      return;
    }
    if (snapshot.tick == newest.tick) {
      // The same tick again (a resume reply racing the broadcast).
      _buffer[snapshot.tick] = snapshot;
      return;
    }
    if (snapshot.tick < newest.tick - resetTickGap) {
      // The tick counter restarted: a new match.
      reset();
      _start(snapshot);
      return;
    }
    if (snapshot.tick < newest.tick) return; // stale; already played past it

    if (snapshot.tick > newest.tick + 1) {
      // A reconnect skipped ticks. Gliding across the gap would drag the
      // rival through cells it never visited, so start over from here.
      _buffer.clear();
      _buffer[snapshot.tick] = snapshot;
      clock.onArrival(
        snapshot.tick,
        tickMs: snapshot.tickMs,
        lag: delay,
        resync: true,
      );
      return;
    }

    _buffer[snapshot.tick] = snapshot;
    clock.onArrival(snapshot.tick, tickMs: snapshot.tickMs, lag: delay);
    _prune();
  }

  void _start(MatchSnapshot snapshot) {
    _buffer[snapshot.tick] = snapshot;
    // Playback starts a delay behind it, holding on this snapshot (the
    // oldest there is) until the clock reaches it — at the start of a match
    // the snakes have not moved yet anyway.
    clock.onArrival(snapshot.tick, tickMs: snapshot.tickMs, lag: delay);
  }

  void _prune() {
    // Everything older than the snapshot playback is gliding from has been
    // shown for good.
    final keepFrom = renderTick.floor();
    while (_buffer.length > 1) {
      final second = _buffer.firstKeyAfter(_buffer.firstKey()!)!;
      if (second > keepFrom) break;
      _buffer.remove(_buffer.firstKey());
    }
    while (_buffer.length > capacity) {
      _buffer.remove(_buffer.firstKey());
    }
  }

  /// Advance playback by one frame.
  void advance(double dtSeconds) {
    final newest = latest;
    if (newest == null) return;
    clock.advance(dtSeconds, limit: newest.tick.toDouble());
  }

  /// The snapshot playback has most recently reached — the one the board
  /// is showing. Before playback reaches the oldest buffered snapshot (the
  /// start of a match, just after a reconnect) that oldest one is shown.
  MatchSnapshot? get rendered {
    if (_buffer.isEmpty) return null;
    final at = _buffer.lastKeyBefore(_renderKey + 1);
    return _buffer[at ?? _buffer.firstKey()!];
  }

  // A hair of tolerance so a clock that has eased exactly onto a tick counts
  // as there despite rounding.
  int get _renderKey => (renderTick + 1e-6).floor();

  /// How the snake of [playerIndex] is drawn this frame, or null when no
  /// buffered snapshot has it.
  SnakePose? poseOf(int playerIndex) {
    final from = rendered;
    if (from == null) return null;
    final a = from.playerByIndex(playerIndex);
    final nextKey = _buffer.firstKeyAfter(from.tick);
    final to = nextKey == null ? null : _buffer[nextKey];
    final b = to?.playerByIndex(playerIndex);

    if (a == null) {
      return b == null ? null : _still(b);
    }
    if (!a.alive || b == null || to == null) return _still(a);

    final t = ((renderTick - from.tick) / (to.tick - from.tick)).clamp(
      0.0,
      1.0,
    );
    if (t <= 0) return _still(a);
    // Into the next snapshot's cells — including the lunge into whatever
    // killed it, which is shown dead only once that snapshot is reached.
    return SnakePose(
      cells: glideBody(a.body, b.body, t),
      facing: b.direction,
      alive: true,
    );
  }

  static SnakePose _still(MatchPlayerState p) => SnakePose(
    cells: glideBody(p.body, p.body, 0),
    facing: p.direction,
    alive: p.alive,
  );
}

import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/utils/direction.dart';

/// One snake as the board draws it this frame: cell centres in GRID units
/// (cell (3, 4) centres on (3.5, 4.5)), head first, where its head looks,
/// and whether it is drawn alive.
class SnakePose {
  const SnakePose({
    required this.cells,
    required this.facing,
    required this.alive,
  });

  final List<Offset> cells;
  final Direction facing;
  final bool alive;
}

/// Cell centres of a body gliding from [from] to [to], [t] of the way
/// (0..1), in GRID units — cell (3, 4) has its centre at (3.5, 4.5).
///
/// Segment i slides from its old cell to its new one: the body list shifts
/// one cell forward per tick, so an index-wise lerp is the slide. A segment
/// with no counterpart in [from] (growth) and any jump too long to be one
/// step (a resync) sit on their destination cell instead of sliding.
List<Offset> glideBody(List<Position> from, List<Position> to, double t) {
  final p = t.clamp(0.0, 1.0);
  Offset centre(Position c) => Offset(c.x + .5, c.y + .5);
  return List<Offset>.generate(to.length, (i) {
    final b = to[i];
    final a = i < from.length ? from[i] : b;
    final jump = (b.x - a.x).abs() + (b.y - a.y).abs();
    if (jump == 0 || jump > 2 || p >= 1.0) return centre(b);
    return Offset.lerp(centre(a), centre(b), p)!;
  });
}

/// Hides a discontinuity in what the local snake is drawn doing.
///
/// Prediction changes its mind in two places: when a swipe re-aims the glide
/// that is already under way, and when a snapshot disagrees with what was
/// predicted for it. Drawn as-is, either one teleports the snake part of a
/// cell. Instead, the difference between what was on screen and the new path
/// is carried as an offset and eased away over [duration], so a turn reads
/// as a curve and a correction as a quick slide. The offset rides ON the new
/// path, so the snake keeps moving at full speed the whole time — easing
/// from a frozen picture instead made every correction start with a
/// visible hitch. A jump too large to be a misprediction (reconnect) is not
/// smoothed: sliding across the board would be worse than appearing.
class CorrectionBlend {
  CorrectionBlend({
    this.duration = const Duration(milliseconds: 120),
    this.snapDistance = 3.0,
    this.threshold = 0.02,
  });

  /// How long a correction takes to settle.
  final Duration duration;

  /// Beyond this many cells of displacement the new path is shown at once.
  final double snapDistance;

  /// Below this many cells a change is invisible and not worth easing.
  final double threshold;

  List<Offset>? _offsets;
  double _elapsedMs = 0;

  /// Whether a correction is currently being eased out.
  bool get active => _offsets != null;

  /// The path changed under the snake. [shown] is what is on screen (the old
  /// path at this moment, with any correction still in flight); [target] is
  /// where the new path puts it at the same moment.
  void begin(List<Offset> shown, List<Offset> target) {
    final gap = maxGap(shown, target);
    if (gap <= threshold || gap > snapDistance) {
      _offsets = null;
      return;
    }
    final n = math.min(shown.length, target.length);
    _offsets = [for (var i = 0; i < n; i++) shown[i] - target[i]];
    _elapsedMs = 0;
  }

  /// Drop any correction in flight.
  void cancel() => _offsets = null;

  /// Advance by [dtSeconds] and return what to draw for [target].
  List<Offset> apply(List<Offset> target, double dtSeconds) {
    final offsets = _offsets;
    if (offsets == null) return target;
    _elapsedMs += dtSeconds * 1000;
    final total = duration.inMicroseconds / 1000.0;
    final linear = total <= 0 ? 1.0 : (_elapsedMs / total).clamp(0.0, 1.0);
    if (linear >= 1.0) {
      _offsets = null;
      return target;
    }
    // Smoothstep: no single frame carries a visible share of the jump. An
    // ease-out moved a whole-cell correction more than half a cell on its
    // first frame, which reads as the snap it is meant to hide.
    final remaining = 1 - linear * linear * (3 - 2 * linear);
    return List<Offset>.generate(target.length, (i) {
      if (i >= offsets.length) return target[i];
      return target[i] + offsets[i] * remaining;
    });
  }

  /// Largest per-segment distance between two drawings of the same snake,
  /// over the segments they share.
  static double maxGap(List<Offset> a, List<Offset> b) {
    final n = math.min(a.length, b.length);
    var gap = 0.0;
    for (var i = 0; i < n; i++) {
      gap = math.max(gap, (a[i] - b[i]).distance);
    }
    return gap;
  }
}

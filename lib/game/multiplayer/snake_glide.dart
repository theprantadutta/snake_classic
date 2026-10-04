import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:snake_classic/models/position.dart';

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
/// cell. Instead, whatever was on screen the frame before is eased into the
/// new path over [duration], so a turn reads as a curve and a correction as
/// a quick slide. A jump too large to be a misprediction (reconnect) is not
/// smoothed: sliding across the board would be worse than appearing.
class CorrectionBlend {
  CorrectionBlend({
    this.duration = const Duration(milliseconds: 100),
    this.snapDistance = 3.0,
    this.threshold = 0.02,
  });

  /// How long a correction takes to settle.
  final Duration duration;

  /// Beyond this many cells of displacement the new path is shown at once.
  final double snapDistance;

  /// Below this many cells a change is invisible and not worth easing.
  final double threshold;

  List<Offset>? _from;
  double _elapsedMs = 0;

  /// Whether a correction is currently being eased out.
  bool get active => _from != null;

  /// The path changed under the snake. [shown] is what was on screen last
  /// frame; [target] is where the new path puts it now.
  void begin(List<Offset> shown, List<Offset> target) {
    final gap = maxGap(shown, target);
    if (gap <= threshold || gap > snapDistance) {
      _from = null;
      return;
    }
    // Start from what is on screen — including a blend still in progress, so
    // two corrections in quick succession chain instead of jumping.
    _from = List<Offset>.of(shown);
    _elapsedMs = 0;
  }

  /// Drop any correction in flight.
  void cancel() => _from = null;

  /// Advance by [dtSeconds] and return what to draw for [target].
  List<Offset> apply(List<Offset> target, double dtSeconds) {
    final from = _from;
    if (from == null) return target;
    _elapsedMs += dtSeconds * 1000;
    final total = duration.inMicroseconds / 1000.0;
    final linear = total <= 0 ? 1.0 : (_elapsedMs / total).clamp(0.0, 1.0);
    if (linear >= 1.0) {
      _from = null;
      return target;
    }
    // Ease-out: most of the correction happens at once, the tail settles.
    final k = 1 - math.pow(1 - linear, 3).toDouble();
    return List<Offset>.generate(target.length, (i) {
      if (i >= from.length) return target[i];
      return Offset.lerp(from[i], target[i], k)!;
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

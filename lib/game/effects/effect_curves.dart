// Snake Classic: pure timing math for the in-game motion effects.
//
// Everything here is a plain function of a normalised time (0..1) or a
// combo count, so the board painter, the effects component and the HUD all
// share one tested source and nothing allocates per frame. Durations and
// curves come from LBMotion (docs/MOTION_SPEC.md).
import 'dart:math' as math;

import 'package:snake_classic/design/lb_motion.dart';

abstract class EffectCurves {
  /// Grow ripple: how lit body segment [index] of [length] is at ripple
  /// progress [t] (0..1, head at index 0). A soft band travels from the head
  /// to the tail; returns 0..1, 0 outside the band and outside 0 <= t < 1.
  static double rippleIntensity(double t, int index, int length) {
    if (t < 0 || t >= 1 || length <= 0 || index < 0 || index >= length) {
      return 0;
    }
    // Half-width of the band as a fraction of the body: about three
    // segments, kept readable on short snakes and narrow on long ones.
    final w = rippleHalfWidth(length);
    final s = length <= 1 ? 0.0 : index / (length - 1);
    // The front starts one half-width before the head and ends one past
    // the tail, so both ends get the full bump.
    final front = t * (1 + 2 * w) - w;
    final d = (s - front).abs() / w;
    if (d >= 1) return 0;
    final k = 1 - d;
    return k * k * (3 - 2 * k);
  }

  /// The swallowed lump is about one segment wide (it reads as one bite
  /// going down, not a flash along the body).
  static double rippleHalfWidth(int length) =>
      length <= 0 ? .35 : (1.4 / length).clamp(.06, .35);

  /// How long the swallowed lump takes to travel head to tail. Owner,
  /// 2026-11-19: the 400 ms spark + flash was too fast and distracting;
  /// the bite should be seen going down the belly and vanishing.
  static const Duration swallowDuration = Duration(milliseconds: 1400);

  /// Gulp at the mouth: the eaten food shrinks into the head (1 -> 0) over
  /// the first [gulpFraction] of the swallow, easing in.
  static const double gulpFraction = .2;
  static double gulpScale(double t) {
    if (t <= 0) return 1;
    if (t >= gulpFraction) return 0;
    final k = t / gulpFraction;
    return 1 - k * k;
  }

  /// Where the swallowed food is, as a fraction of the body (0 = neck,
  /// 1 = tail) at swallow progress [t]: the same front [rippleIntensity]
  /// bulges around, clamped to the body.
  static double swallowFront(double t, int length) {
    final w = rippleHalfWidth(length);
    return (t * (1 + 2 * w) - w).clamp(0.0, 1.0);
  }

  /// Opacity of the food seen inside the body: fades in as it enters the
  /// neck, holds, and fades out over the last stretch (digested at the
  /// tail). No flashes: everything is a slow ramp.
  static double swallowDotAlpha(double t) {
    if (t <= 0 || t >= 1) return 0;
    if (t < .1) return t / .1;
    if (t > .75) return (1 - t) / .25;
    return 1;
  }

  /// Size of the food seen inside the body (fraction of a cell): it shrinks
  /// as it is digested.
  static double swallowDotRadius(double t) => .27 - .12 * t.clamp(0.0, 1.0);

  /// Chomp: the head squeezes once as it bites (0 = none, 1 = deepest),
  /// over the first [chompFraction] of the swallow.
  static const double chompFraction = .14;
  static double chomp(double t) {
    if (t <= 0 || t >= chompFraction) return 0;
    return math.sin(math.pi * t / chompFraction);
  }

  /// Turn feedback length: head squash-and-stretch + direction chevrons.
  static const Duration turnDuration = Duration(milliseconds: 360);

  /// Head stretch along the new direction at turn progress [t] (0..1):
  /// jumps to [amp], springs back through a small opposite squash, 0 after.
  static double turnStretch(double t, {double amp = .18}) {
    if (t < 0 || t >= 1) return 0;
    return amp * (1 - LBMotion.springSoft.transform(t));
  }

  /// Direction chevrons: distance ahead of the head in cells, and alpha.
  static double chevronTravel(double t) =>
      .7 + .9 * LBMotion.easeOutSoft.transform(t.clamp(0.0, 1.0));
  static double chevronAlpha(double t) {
    if (t <= 0) return .85;
    if (t >= 1) return 0;
    final k = 1 - t;
    return .85 * k * k;
  }

  /// Combo chip resting scale: grows 3% per streak step past the first
  /// (combo 2), capped at +12%.
  static double comboBaseScale(int combo) =>
      1 + math.min(.12, .03 * math.max(0, combo - 2));

  /// Combo chip pop: springs from [from] to 1 (with overshoot) over the pop
  /// animation's progress [t].
  static double comboPopScale(double t, {double from = .6}) {
    final c = LBMotion.springPop.transform(t.clamp(0.0, 1.0));
    return from + (1 - from) * c;
  }

  /// Score bump: jumps to 1 + [amp] and springs back to 1 (dipping slightly
  /// under on the way). 1 outside 0 <= t < 1.
  static double bumpScale(double t, {double amp = .08}) {
    if (t < 0 || t >= 1) return 1;
    return 1 + amp * (1 - LBMotion.springPop.transform(t));
  }

  /// Eat pop ring radius in cells: springs from .35 to .95 cell.
  static double popRingRadius(double t) =>
      .35 + .6 * LBMotion.springPop.transform(t.clamp(0.0, 1.0));

  /// Generic fade-out alpha over 0..1 (ease-out so it reads, then goes).
  static double fadeOut(double t) {
    if (t <= 0) return 1;
    if (t >= 1) return 0;
    final k = 1 - t;
    return k * k;
  }

  /// Spark cell travel in cells from the centre, eased out.
  static double sparkDistance(double t) =>
      1.25 * LBMotion.easeOutSoft.transform(t.clamp(0.0, 1.0));

  /// Level wall: how many of [count] cells are lit [elapsedMs] into the
  /// level-up sweep (one cell per LBMotion.cellStagger).
  static int wallLitCells(int elapsedMs, int count) {
    if (elapsedMs < 0) return 0;
    final step = LBMotion.cellStagger.inMilliseconds;
    return math.min(count, elapsedMs ~/ step + 1);
  }

  /// Total level wall sweep length for [count] cells.
  static Duration wallSweepDuration(int count) =>
      LBMotion.cellStagger * math.max(1, count);
}

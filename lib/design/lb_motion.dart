// Snake Classic: motion tokens (the single source of timing and easing).
//
// Every animation in the app takes its duration and curve from here, so the
// whole game moves with one rhythm. Spec: docs/MOTION_SPEC.md.
//
// The "spring" curves are overshooting cubics, not physics simulations, so
// they work with implicit Animated* widgets, flutter_animate and plain
// controllers alike.
import 'package:material_ui/material_ui.dart';

abstract class LBMotion {
  // Durations.
  static const Duration instant = Duration(milliseconds: 120);
  static const Duration quick = Duration(milliseconds: 180);
  static const Duration base = Duration(milliseconds: 280);
  static const Duration gentle = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration lingering = Duration(milliseconds: 900);

  /// Per-item delay for staggered entrances (list rows, tiles, cells).
  static const Duration stagger = Duration(milliseconds: 45);

  /// Per-cell delay when a row of LED cells lights up in sequence.
  static const Duration cellStagger = Duration(milliseconds: 18);

  // Curves.
  /// Default for things arriving: fast start, soft landing.
  static const Curve easeOutSoft = Cubic(0.2, 0.8, 0.2, 1);

  /// Material standard, for state changes in place.
  static const Curve standard = Cubic(0.4, 0, 0.2, 1);

  /// Small overshoot: press release, toggles, sheets.
  static const Curve springSoft = Cubic(0.3, 1.5, 0.5, 1);

  /// Bigger overshoot: rewards, pickups, badges, new-best.
  static const Curve springPop = Cubic(0.3, 1.8, 0.5, 1);

  /// Things falling into place from above.
  static const Curve dropIn = Cubic(0.3, 0.9, 0.4, 1);

  /// Leaving the screen.
  static const Curve exit = Cubic(0.4, 0, 0.5, 1);

  /// Moving from one place to another (coins flying to a counter).
  static const Curve travel = Cubic(0.45, 0, 0.25, 1);

  // Press feedback (LBBlock and every tappable surface).
  static const double pressScale = 0.97;
  static const Duration pressDown = instant;
  static const Duration pressRelease = Duration(milliseconds: 250);

  /// Reduce motion: the OS "remove animations" accessibility flag. When on,
  /// every animation falls back to [reducedFade] or an instant change.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  static const Duration reducedFade = Duration(milliseconds: 140);

  /// [d] normally, [reducedFade] (or zero when [instantWhenReduced]) under
  /// reduce motion.
  static Duration of(
    BuildContext context,
    Duration d, {
    bool instantWhenReduced = false,
  }) =>
      reduced(context)
          ? (instantWhenReduced ? Duration.zero : reducedFade)
          : d;
}

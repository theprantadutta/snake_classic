import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// Turns thumb movement into four-way steering. Pure; no widgets, no time.
///
/// A FLOATING stick: wherever the thumb lands becomes the centre, so there
/// is nothing to aim at. Push past [deadRadius] and the push resolves to the
/// nearest of the four directions — but only once it is clearly inside that
/// direction's sector ([sectorHalfAngle] either side of the axis), so a
/// diagonal push sits in a dead band instead of flickering between two
/// answers. Each time a direction registers the centre moves to the thumb,
/// so the next push is measured from where the thumb already is and a
/// corner never needs a lift.
///
/// Pulling straight back toward where the thumb came from is read as
/// returning to centre, not as the opposite direction: the game would refuse
/// that reversal anyway, and a buzz for un-pushing a stick reads as a bug.
class JoystickTracker {
  JoystickTracker({
    this.deadRadius = 12.0,
    this.sectorHalfAngle = 35.0,
  }) : assert(sectorHalfAngle > 0 && sectorHalfAngle <= 45);

  /// Distance the thumb must travel from the centre before anything counts.
  final double deadRadius;

  /// Degrees either side of an axis that count as that direction. 45 would
  /// make every push resolve; smaller leaves a dead band on the diagonals.
  final double sectorHalfAngle;

  Offset? _origin;
  Direction? _current;

  /// Where the stick is centred right now (null between touches).
  Offset? get origin => _origin;

  /// The last direction this touch registered.
  Direction? get current => _current;

  bool get isActive => _origin != null;

  /// Thumb landed.
  void begin(Offset at) {
    _origin = at;
    _current = null;
  }

  /// Thumb moved. Returns a direction only when a NEW one registers.
  Direction? update(Offset at) {
    final origin = _origin;
    if (origin == null) return null;

    final push = at - origin;
    if (push.distance < deadRadius) return null;

    final candidate = _nearest(push);

    // Pulling back against the last push: re-centre silently.
    if (_current != null && candidate == _current!.opposite) {
      _origin = at;
      return null;
    }
    if (candidate == _current) return null;

    // Must be committed to the sector, not sitting on a diagonal.
    final axis = _axisVector(candidate);
    final cosine =
        (push.dx * axis.dx + push.dy * axis.dy) / push.distance;
    final degreesOffAxis =
        math.acos(cosine.clamp(-1.0, 1.0)) * 180 / math.pi;
    if (degreesOffAxis > sectorHalfAngle) return null;

    _current = candidate;
    _origin = at;
    return candidate;
  }

  /// Thumb lifted.
  void end() {
    _origin = null;
    _current = null;
  }

  static Direction _nearest(Offset push) {
    if (push.dx.abs() >= push.dy.abs()) {
      return push.dx > 0 ? Direction.right : Direction.left;
    }
    return push.dy > 0 ? Direction.down : Direction.up;
  }

  static Offset _axisVector(Direction d) {
    switch (d) {
      case Direction.up:
        return const Offset(0, -1);
      case Direction.down:
        return const Offset(0, 1);
      case Direction.left:
        return const Offset(-1, 0);
      case Direction.right:
        return const Offset(1, 0);
    }
  }
}

/// The floating joystick control. The whole box is the touch zone; a base
/// ring appears where the thumb lands and a knob follows the push.
///
/// Raw [Listener] like the other steering controls — no gesture arena, the
/// centre is set on the down event itself.
class FloatingJoystick extends StatefulWidget {
  const FloatingJoystick({
    super.key,
    required this.onDirection,
    required this.theme,
    this.opacity = 0.8,
    this.knobTravel = 34.0,
  });

  final void Function(Direction) onDirection;
  final GameTheme theme;
  final double opacity;

  /// How far from the base the drawn knob may travel. Purely visual; the
  /// tracker has no maximum.
  final double knobTravel;

  @override
  State<FloatingJoystick> createState() => _FloatingJoystickState();
}

class _FloatingJoystickState extends State<FloatingJoystick> {
  final JoystickTracker _tracker = JoystickTracker();
  int? _activePointer;
  Offset? _thumb;

  void _down(PointerDownEvent e) {
    _activePointer = e.pointer;
    _tracker.begin(e.localPosition);
    setState(() => _thumb = e.localPosition);
  }

  void _move(PointerMoveEvent e) {
    if (e.pointer != _activePointer) return;
    final direction = _tracker.update(e.localPosition);
    setState(() => _thumb = e.localPosition);
    if (direction != null) widget.onDirection(direction);
  }

  void _end(PointerEvent e) {
    if (e.pointer != _activePointer) return;
    _activePointer = null;
    _tracker.end();
    setState(() => _thumb = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final origin = _tracker.origin;
    final thumb = _thumb;

    Offset? knob;
    if (origin != null && thumb != null) {
      final push = thumb - origin;
      knob = push.distance <= widget.knobTravel
          ? thumb
          : origin + push / push.distance * widget.knobTravel;
    }

    final p = context.lb;
    final ink = (0.55 + 0.45 * widget.opacity).clamp(0.0, 1.0);

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _down,
      onPointerMove: _move,
      onPointerUp: _end,
      onPointerCancel: _end,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(LB.blockRadius),
        child: Container(
          decoration: BoxDecoration(
            color: p.lime.withValues(alpha: .05),
            borderRadius: BorderRadius.circular(LB.blockRadius),
            border: Border.all(color: p.lime.withValues(alpha: .32 * ink)),
          ),
          child: Stack(
            children: [
              // Idle hint, gone the moment a thumb is down.
              if (origin == null)
                Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LBPixelIcon(LBIcon.plus, cell: 3.4, color: p.lime.withValues(alpha: .7 * ink)),
                          const SizedBox(width: 10),
                          Text(
                            l10n.gameJoystickHint.toUpperCase(),
                            style: LBText.button(p, color: p.head.withValues(alpha: .75 * ink), size: 11)
                                .copyWith(letterSpacing: 2.2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (origin != null)
                Positioned(
                  left: origin.dx - widget.knobTravel - 10,
                  top: origin.dy - widget.knobTravel - 10,
                  child: _Ring(
                    diameter: (widget.knobTravel + 10) * 2,
                    color: p.lime.withValues(alpha: .4 * ink),
                    fill: p.lime.withValues(alpha: .05),
                  ),
                ),
              if (knob != null)
                Positioned(
                  left: knob.dx - 18,
                  top: knob.dy - 18,
                  child: _Knob(diameter: 36, color: p.head.withValues(alpha: ink)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The base: a rounded-square block outline where the thumb landed.
class _Ring extends StatelessWidget {
  const _Ring({required this.diameter, required this.color, required this.fill});
  final double diameter;
  final Color color;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(diameter * .22),
          border: Border.all(color: color, width: 1.5),
        ),
      ),
    );
  }
}

/// The knob: one lit snake cell, glowing like the head.
class _Knob extends StatelessWidget {
  const _Knob({required this.diameter, required this.color});
  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(diameter * .22),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.45),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

/// [FloatingJoystick] as it appears in a control bar: dimmed, pointer-blind
/// and reported disabled when the player cannot steer. Same contract as the
/// d-pad and turn-button wrappers.
class SteerableJoystick extends StatelessWidget {
  const SteerableJoystick({
    super.key,
    required this.onDirection,
    required this.theme,
    required this.height,
    required this.canSteer,
  });

  final void Function(Direction) onDirection;
  final GameTheme theme;
  final double height;
  final bool canSteer;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Opacity(
        opacity: canSteer ? 1.0 : 0.45,
        child: IgnorePointer(
          ignoring: !canSteer,
          child: Semantics(
            container: true,
            label: AppLocalizations.of(context)!.gameJoystick,
            enabled: canSteer,
            child: FloatingJoystick(onDirection: onDirection, theme: theme),
          ),
        ),
      ),
    );
  }
}

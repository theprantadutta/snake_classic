import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';

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
    final theme = widget.theme;
    final origin = _tracker.origin;
    final thumb = _thumb;

    Offset? knob;
    if (origin != null && thumb != null) {
      final push = thumb - origin;
      knob = push.distance <= widget.knobTravel
          ? thumb
          : origin + push / push.distance * widget.knobTravel;
    }

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _down,
      onPointerMove: _move,
      onPointerUp: _end,
      onPointerCancel: _end,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: theme.backgroundColor.withValues(
              alpha: widget.opacity * 0.25,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.accentColor.withValues(alpha: widget.opacity * 0.18),
            ),
          ),
          child: Stack(
            children: [
              // Idle hint, gone the moment a thumb is down.
              if (origin == null)
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.control_camera_rounded,
                        size: 18,
                        color: theme.accentColor.withValues(
                          alpha: widget.opacity * 0.45,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.gameJoystickHint.toUpperCase(),
                        style: TextStyle(
                          color: theme.accentColor.withValues(
                            alpha: widget.opacity * 0.45,
                          ),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              if (origin != null)
                Positioned(
                  left: origin.dx - widget.knobTravel - 10,
                  top: origin.dy - widget.knobTravel - 10,
                  child: _Ring(
                    diameter: (widget.knobTravel + 10) * 2,
                    color: theme.accentColor.withValues(
                      alpha: widget.opacity * 0.35,
                    ),
                  ),
                ),
              if (knob != null)
                Positioned(
                  left: knob.dx - 18,
                  top: knob.dy - 18,
                  child: _Knob(
                    diameter: 36,
                    color: theme.accentColor.withValues(
                      alpha: widget.opacity * 0.75,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.diameter, required this.color});
  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1.5),
        ),
      ),
    );
  }
}

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
          shape: BoxShape.circle,
          color: color,
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

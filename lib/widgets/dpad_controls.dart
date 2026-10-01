import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/overlays/lb_overlay_parts.dart';

/// On-screen D-Pad controller for touch-based directional input.
/// Provides an alternative to swipe controls for users who prefer buttons.
///
/// Hit testing is deliberately NOT per-button. The four circles are pure
/// visuals; a single pointer layer spans the whole square and resolves the
/// touch point to a quadrant. Four discrete button hit boxes only covered
/// ~45% of the control's footprint - every diagonal gap between them was
/// inert - and they only accepted taps, so sliding a thumb from up to right
/// never registered the second turn. Both read to players as the game
/// ignoring their input.
///
/// The pointer layer is a raw [Listener], not a GestureDetector. This is the
/// part that matters for feel. A GestureDetector with tap AND pan handlers
/// puts two recognisers into the gesture arena for every press, and Flutter
/// withholds the tap's down callback until the arena settles: for a finger
/// that lands and holds, that is the 100ms press timeout; for a quick tap, it
/// is the release. The pan side only spoke up after the touch slop, so a
/// slide-through lost its FIRST direction altogether. Every d-pad press was
/// therefore reaching the game late, on top of the tick it then had to wait
/// for — and "the d-pad feels laggy" was the most common review complaint.
/// A Listener has no arena. The direction fires on the down event itself.
class DPadControls extends StatefulWidget {
  final Function(Direction) onDirection;
  final GameTheme theme;
  final double opacity;
  final double size;

  const DPadControls({
    super.key,
    required this.onDirection,
    required this.theme,
    this.opacity = 0.6,
    this.size = 140.0,
  });

  @override
  State<DPadControls> createState() => _DPadControlsState();
}

class _DPadControlsState extends State<DPadControls> {
  /// Quadrant currently under the finger — drives the pressed visual.
  Direction? _activeDirection;

  /// Last direction actually dispatched during this gesture. Only a CHANGE
  /// fires, so holding or jittering inside one quadrant doesn't spam the
  /// cubit every frame; cleared on release so re-tapping the same button
  /// still counts as a fresh input.
  Direction? _lastFiredDirection;

  /// The pointer that is steering right now. Latest press wins: a second
  /// finger landing while the first is still held takes over, exactly as a
  /// physical pad reads the newest press, and the first finger's release
  /// or movement is then ignored rather than ending the live gesture.
  int? _activePointer;

  /// Resolve a local touch point to a direction, splitting the square on its
  /// diagonals so 100% of the footprint is live. Returns null only inside a
  /// small centre dead zone, where no direction was plausibly intended.
  Direction? _directionFor(Offset localPosition) {
    final centre = widget.size / 2;
    final dx = localPosition.dx - centre;
    final dy = localPosition.dy - centre;

    // Dead zone sized to the decorative hub, so a dead-centre press is
    // treated as "no direction" rather than an arbitrary quadrant.
    final deadZone = widget.size * 0.10;
    if (dx * dx + dy * dy < deadZone * deadZone) return null;

    if (dx.abs() >= dy.abs()) {
      return dx > 0 ? Direction.right : Direction.left;
    }
    return dy > 0 ? Direction.down : Direction.up;
  }

  void _handlePointer(Offset localPosition) {
    final direction = _directionFor(localPosition);

    if (direction != _activeDirection) {
      setState(() => _activeDirection = direction);
    }
    if (direction == null || direction == _lastFiredDirection) return;

    _lastFiredDirection = direction;
    // No haptic here — GameCubit.changeDirection owns input haptics
    // (selectionClick on accept, double-buzz on reject). Firing one here
    // too double-buzzed every press.
    widget.onDirection(direction);
  }

  void _releasePointer() {
    if (_activeDirection != null) {
      setState(() => _activeDirection = null);
    }
    _lastFiredDirection = null;
  }

  void _onPointerDown(PointerDownEvent event) {
    _activePointer = event.pointer;
    _handlePointer(event.localPosition);
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (event.pointer != _activePointer) return;
    // The Listener keeps delivering moves after the finger leaves its box,
    // so a thumb that drifts past the edge still resolves to the nearest
    // arm instead of dropping the press mid-corner.
    _handlePointer(event.localPosition);
  }

  void _onPointerEnd(PointerEvent event) {
    if (event.pointer != _activePointer) return;
    _activePointer = null;
    _releasePointer();
  }

  @override
  Widget build(BuildContext context) {
    // Square arms in a plus. 0.30 is the largest square that keeps the
    // diagonal neighbours from touching with the 0.04 edge spacing (squares
    // reach further into the corners than the old circles did). These are
    // the DRAWN size only — the live hit area is the full square, so the
    // effective target is the whole control.
    final buttonSize = widget.size * 0.30;
    final spacing = widget.size * 0.04;
    final hubSize = widget.size * 0.10;
    final p = context.lb;

    return Listener(
      // Opaque so presses anywhere in the square are captured, including
      // the gaps that used to fall through to the bar behind.
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerEnd,
      onPointerCancel: _onPointerEnd,
      // Quadrant resolution is meaningless to a screen reader — where you
      // touched inside the square is the whole input. A Listener adds no
      // semantics of its own; the accessible control is the four labelled
      // buttons underneath, each of which carries its own tap action.
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: p.board.withValues(alpha: .55),
          borderRadius: BorderRadius.circular(LB.blockRadius * 1.5),
          border: Border.all(color: p.lime.withValues(alpha: widget.opacity * 0.2)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Centre hub: one dim cell, so the plus reads as one control.
            SizedBox.square(
              dimension: hubSize,
              child: CustomPaint(painter: _HubPainter(p.cellOff)),
            ),
            Positioned(
              top: spacing,
              child: _buildDirectionButton(direction: Direction.up, buttonSize: buttonSize),
            ),
            Positioned(
              bottom: spacing,
              child: _buildDirectionButton(direction: Direction.down, buttonSize: buttonSize),
            ),
            Positioned(
              left: spacing,
              child: _buildDirectionButton(direction: Direction.left, buttonSize: buttonSize),
            ),
            Positioned(
              right: spacing,
              child: _buildDirectionButton(direction: Direction.right, buttonSize: buttonSize),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionButton({
    required Direction direction,
    required double buttonSize,
  }) {
    // The accessible half of the control. Sighted players drive the single
    // pointer layer above; assistive tech gets four ordinary labelled
    // buttons with real tap actions, which is the only way to steer without
    // being able to aim at a quadrant.
    return Semantics(
      button: true,
      label: _labelFor(context, direction),
      onTap: () => widget.onDirection(direction),
      child: _DPadButton(
        direction: direction,
        size: buttonSize,
        opacity: widget.opacity,
        isPressed: _activeDirection == direction,
      ),
    );
  }

  static String _labelFor(BuildContext context, Direction direction) {
    final l10n = AppLocalizations.of(context)!;
    switch (direction) {
      case Direction.up:
        return l10n.gameSteerUp;
      case Direction.down:
        return l10n.gameSteerDown;
      case Direction.left:
        return l10n.gameSteerLeft;
      case Direction.right:
        return l10n.gameSteerRight;
    }
  }
}

/// Pure visual for one arm of the d-pad: an outline block with a pixel
/// arrow, lit to the selected stroke while pressed. Pointer handling lives in
/// the parent's single pointer layer.
class _DPadButton extends StatelessWidget {
  final Direction direction;
  final double size;
  final double opacity;
  final bool isPressed;

  const _DPadButton({
    required this.direction,
    required this.size,
    required this.opacity,
    required this.isPressed,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final strength = isPressed ? 1.0 : (0.55 + 0.45 * opacity).clamp(0.0, 1.0);
    return SizedBox.square(
      dimension: size,
      child: LBBlock(
        width: size - LB.inset * 2,
        height: size - LB.inset * 2,
        selected: isPressed,
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
        child: LBArrowIcon(
          direction: direction,
          cell: (size * .11).clamp(2.5, 7.0),
          color: p.lime.withValues(alpha: strength),
        ),
      ),
    );
  }
}

class _HubPainter extends CustomPainter {
  _HubPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) =>
      canvas.drawRRect(lbCellRect(0, 0, size.width), Paint()..color = color);

  @override
  bool shouldRepaint(_HubPainter old) => old.color != color;
}

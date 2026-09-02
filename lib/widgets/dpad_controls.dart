import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';

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
    // Button ratio dialled to 0.38 — the geometric ceiling for this
    // layout: with the 0.04 edge spacing, diagonal-neighbour circles
    // touch at ~0.381, so this is as large as the targets can get
    // without overlapping. Combined with the small-screen dpadSize bump
    // in game_bottom_bar.dart this puts the visible circles at ~46px on
    // small phones. Note these are now the DRAWN size only — the live
    // hit area is the full square, so the effective target is larger.
    final buttonSize = widget.size * 0.38;
    final spacing = widget.size * 0.04;
    final hubSize = widget.size * 0.10;

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
          color: widget.theme.backgroundColor.withValues(
            alpha: widget.opacity * 0.25,
          ),
          borderRadius: BorderRadius.circular(widget.size * 0.18),
          border: Border.all(
            color: widget.theme.accentColor.withValues(
              alpha: widget.opacity * 0.18,
            ),
            width: 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Decorative center hub — small dot so the cross of buttons
            // reads as one coherent control instead of four loose circles.
            Container(
              width: hubSize,
              height: hubSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.theme.accentColor.withValues(
                  alpha: widget.opacity * 0.25,
                ),
              ),
            ),
            Positioned(
              top: spacing,
              child: _buildDirectionButton(
                direction: Direction.up,
                icon: Icons.keyboard_arrow_up_rounded,
                buttonSize: buttonSize,
              ),
            ),
            Positioned(
              bottom: spacing,
              child: _buildDirectionButton(
                direction: Direction.down,
                icon: Icons.keyboard_arrow_down_rounded,
                buttonSize: buttonSize,
              ),
            ),
            Positioned(
              left: spacing,
              child: _buildDirectionButton(
                direction: Direction.left,
                icon: Icons.keyboard_arrow_left_rounded,
                buttonSize: buttonSize,
              ),
            ),
            Positioned(
              right: spacing,
              child: _buildDirectionButton(
                direction: Direction.right,
                icon: Icons.keyboard_arrow_right_rounded,
                buttonSize: buttonSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionButton({
    required Direction direction,
    required IconData icon,
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
        icon: icon,
        size: buttonSize,
        theme: widget.theme,
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

/// Pure visual for one arm of the d-pad. Pointer handling lives in the
/// parent's single pointer layer.
class _DPadButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final GameTheme theme;
  final double opacity;
  final bool isPressed;

  const _DPadButton({
    required this.icon,
    required this.size,
    required this.theme,
    required this.opacity,
    required this.isPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPressed
            ? theme.accentColor.withValues(alpha: opacity * 0.55)
            : theme.accentColor.withValues(alpha: opacity * 0.22),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: opacity * 0.5),
          width: isPressed ? 2 : 1.2,
        ),
        boxShadow: isPressed
            ? [
                BoxShadow(
                  color: theme.accentColor.withValues(alpha: 0.35),
                  blurRadius: 10,
                  spreadRadius: 1.5,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Center(
        child: Icon(
          icon,
          size: size * 0.62,
          color: theme.accentColor.withValues(
            alpha: isPressed ? opacity : opacity * 0.85,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/presentation/bloc/game/game_settings_cubit.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/utils/responsive.dart';

/// Translucent gesture layer over the game board that turns finger movement
/// into direction inputs.
///
/// **Raw pointer events, not a pan recognizer (8.3).** This used to be a
/// GestureDetector pan. A pan recognizer only accepts after the platform pan
/// slop (36 logical px for touch), and with the default start behaviour that
/// travel is swallowed, so a turn needed ~36 px of slop PLUS the 15 px
/// threshold below: about 50 px of finger travel before the game heard
/// anything. "The controls are so laggy" was a recurring review. A [Listener]
/// has no arena and no slop: distance counts from the moment the finger
/// lands, so a turn fires after [SwipeSensitivity.distance] of travel
/// (14 px on Normal). Same fix the d-pad got in 7.x.
///
/// Visual feedback is NOT this widget's job: accepted/rejected input cues
/// are rendered by the game screen, driven from GameCubit state.
class SwipeDetector extends StatefulWidget {
  final Widget child;
  final Function(Direction) onSwipe;
  final VoidCallback? onTap; // Callback for tap gesture (e.g., to pause)

  /// Overrides the player's setting (tests, previews). Null reads
  /// [GameSettingsState.swipeSensitivity] when a GameSettingsCubit is above.
  final SwipeSensitivity? sensitivity;

  const SwipeDetector({
    super.key,
    required this.child,
    required this.onSwipe,
    this.onTap,
    this.sensitivity,
  });

  @override
  State<SwipeDetector> createState() => _SwipeDetectorState();
}

class _SwipeDetectorState extends State<SwipeDetector> {
  Direction? _lastSwipeDirection;
  DateTime? _lastSwipeTime;

  /// The pointer that is steering. Latest finger down wins, like the d-pad.
  int? _activePointer;
  VelocityTracker? _velocity;

  // Movement since the last trigger (or since the finger landed).
  Offset _cumulativeDelta = Offset.zero;
  bool _hasTriggeredThisGesture = false;

  // Direction most recently triggered within the CURRENT drag. A drag can
  // take several corners without lifting; this stops one direction from
  // re-firing continuously while the finger keeps moving that way.
  Direction? _lastGestureDirection;

  double _minDistance = SwipeSensitivity.normal.distance;

  void _processSwipe(Direction direction) {
    final now = DateTime.now();

    // Prevent spam
    if (_lastSwipeTime != null &&
        now.difference(_lastSwipeTime!).inMilliseconds <
            GameConstants.swipeSpamPreventionMs) {
      return;
    }

    // If same direction within short time, ignore
    if (_lastSwipeDirection == direction &&
        _lastSwipeTime != null &&
        now.difference(_lastSwipeTime!).inMilliseconds <
            GameConstants.swipeSameDirectionThresholdMs) {
      return;
    }

    _lastSwipeDirection = direction;
    _lastSwipeTime = now;

    // No haptic here: GameCubit.changeDirection owns input haptics.
    widget.onSwipe(direction);
  }

  /// The swipe direction from the cumulative delta, with a directional ratio
  /// check. Null if there is not enough movement or it is too diagonal (it
  /// keeps accumulating and resolves a moment later).
  Direction? _getSwipeDirection(Offset delta) {
    final absX = delta.dx.abs();
    final absY = delta.dy.abs();

    // Primary axis must be at least 1.3x the secondary, so diagonal
    // movement doesn't trigger the wrong direction.
    const directionRatio = 1.3;

    if (absX < _minDistance && absY < _minDistance) return null;

    if (absX > absY * directionRatio) {
      return delta.dx > 0 ? Direction.right : Direction.left;
    } else if (absY > absX * directionRatio) {
      return delta.dy > 0 ? Direction.down : Direction.up;
    }
    return null;
  }

  void _resetGesture() {
    _activePointer = null;
    _velocity = null;
    _cumulativeDelta = Offset.zero;
    _hasTriggeredThisGesture = false;
    _lastGestureDirection = null;
  }

  void _onDown(PointerDownEvent event) {
    _resetGesture();
    _activePointer = event.pointer;
    _velocity = VelocityTracker.withKind(event.kind)
      ..addPosition(event.timeStamp, event.position);
  }

  void _onMove(PointerMoveEvent event) {
    if (event.pointer != _activePointer) return;
    _velocity?.addPosition(event.timeStamp, event.position);
    _cumulativeDelta += event.delta;

    final direction = _getSwipeDirection(_cumulativeDelta);
    if (direction == null) return;

    // Restart accumulation from here: after a trigger so a follow-up turn is
    // measured fresh, and while continuing the same way so built-up distance
    // can't drown out a later turn in the same drag.
    _cumulativeDelta = Offset.zero;

    if (direction != _lastGestureDirection) {
      _hasTriggeredThisGesture = true;
      _lastGestureDirection = direction;
      _processSwipe(direction);
    }
  }

  void _onUp(PointerUpEvent event) {
    if (event.pointer != _activePointer) return;
    // Backup for quick flicks that never reached the distance. Deliberately
    // no ratio gate: the drag is over and nothing can disambiguate it, so
    // the dominant axis beats dropping the input on the floor.
    if (!_hasTriggeredThisGesture && _velocity != null) {
      final velocity = _velocity!.getVelocity().pixelsPerSecond;
      final absX = velocity.dx.abs();
      final absY = velocity.dy.abs();
      if (absX >= absY) {
        if (absX > GameConstants.swipeMinVelocity) {
          _processSwipe(velocity.dx > 0 ? Direction.right : Direction.left);
        }
      } else if (absY > GameConstants.swipeMinVelocity) {
        _processSwipe(velocity.dy > 0 ? Direction.down : Direction.up);
      }
    }
    _resetGesture();
  }

  // A cancelled pointer must not lend its partial distance to the next drag.
  void _onCancel(PointerCancelEvent event) {
    if (event.pointer != _activePointer) return;
    _resetGesture();
  }

  SwipeSensitivity _sensitivity(BuildContext context) {
    if (widget.sensitivity != null) return widget.sensitivity!;
    try {
      return context.select<GameSettingsCubit, SwipeSensitivity>(
        (c) => c.state.swipeSensitivity,
      );
    } catch (_) {
      // No settings cubit above (isolated widget tests).
      return SwipeSensitivity.normal;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaled by device class so the feel is the same on a tablet.
    _minDistance = _sensitivity(context).distance * context.uiScale;

    Widget child = widget.child;
    // Only claim taps when somebody is listening for them: a haptic for a tap
    // with no meaning teaches the player their taps do something.
    if (widget.onTap != null) {
      child = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          HapticService().selectionClick();
          widget.onTap!.call();
        },
        child: child,
      );
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onDown,
      onPointerMove: _onMove,
      onPointerUp: _onUp,
      onPointerCancel: _onCancel,
      child: child,
    );
  }
}

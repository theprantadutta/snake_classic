import 'package:flutter/material.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/utils/responsive.dart';

/// Translucent gesture layer over the game board that turns pan gestures
/// into direction inputs.
///
/// Visual feedback is NOT this widget's job — accepted/rejected input cues
/// are rendered by the game screen (chrome gesture chip, board edge bloom,
/// rejected-input flash) driven from GameCubit state. An older in-widget
/// animated feedback circle was permanently disabled at the only call
/// sites yet still forced a setState on the board-wrapping widget for
/// every swipe; it has been deleted.
class SwipeDetector extends StatefulWidget {
  final Widget child;
  final Function(Direction) onSwipe;
  final VoidCallback? onTap; // Callback for tap gesture (e.g., to pause)

  const SwipeDetector({
    super.key,
    required this.child,
    required this.onSwipe,
    this.onTap,
  });

  @override
  State<SwipeDetector> createState() => _SwipeDetectorState();
}

class _SwipeDetectorState extends State<SwipeDetector> {
  Direction? _lastSwipeDirection;
  DateTime? _lastSwipeTime;

  // Cumulative tracking for better swipe detection
  Offset _cumulativeDelta = Offset.zero;
  bool _hasTriggeredThisGesture = false;

  // Direction most recently triggered within the CURRENT drag. A drag
  // can trigger multiple turns (e.g. up-then-right around a corner
  // without lifting the finger); this prevents the same direction from
  // re-firing continuously while the finger keeps moving that way.
  Direction? _lastGestureDirection;

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

    // No haptic here — GameCubit.changeDirection owns input haptics
    // (selectionClick on accept, double-buzz on reject); firing one here
    // too double-buzzed every swipe.
    widget.onSwipe(direction);
  }

  /// Determines the swipe direction from cumulative delta with directional
  /// ratio check. Returns null if the swipe is ambiguous (too diagonal).
  Direction? _getSwipeDirection(Offset delta) {
    final absX = delta.dx.abs();
    final absY = delta.dy.abs();

    // Minimum distance threshold (more generous than per-frame check).
    // Scaled by device class so the swipe feel is consistent on physically
    // larger tablet screens (1.0x on phones — unchanged).
    final minDistance = 15.0 * context.uiScale;

    // Directional ratio - primary axis must be at least 1.3x the secondary
    // This prevents diagonal swipes from triggering wrong directions
    const directionRatio = 1.3;

    if (absX < minDistance && absY < minDistance) {
      return null; // Not enough movement
    }

    if (absX > absY * directionRatio) {
      // Clearly horizontal
      return delta.dx > 0 ? Direction.right : Direction.left;
    } else if (absY > absX * directionRatio) {
      // Clearly vertical
      return delta.dy > 0 ? Direction.down : Direction.up;
    }

    // Ambiguous diagonal - don't trigger
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        // Reset tracking for new gesture
        _cumulativeDelta = Offset.zero;
        _hasTriggeredThisGesture = false;
        _lastGestureDirection = null;
      },
      onPanUpdate: (details) {
        // Accumulate movement since the last trigger (or pan start).
        _cumulativeDelta += details.delta;

        final direction = _getSwipeDirection(_cumulativeDelta);
        if (direction == null) return;

        // Restart accumulation from here in all cases: after a trigger
        // so a follow-up turn is measured fresh, and while continuing in
        // the same direction so built-up same-axis distance can't drown
        // out a subsequent turn late in the drag.
        _cumulativeDelta = Offset.zero;

        // A drag may trigger multiple turns — one per direction change.
        if (direction != _lastGestureDirection) {
          _hasTriggeredThisGesture = true;
          _lastGestureDirection = direction;
          _processSwipe(direction);
        }
      },
      onPanEnd: (details) {
        // Backup: Use velocity for quick flicks that might not accumulate
        // enough distance
        if (!_hasTriggeredThisGesture) {
          final velocity = details.velocity.pixelsPerSecond;
          final absX = velocity.dx.abs();
          final absY = velocity.dy.abs();

          // Check velocity with directional ratio
          const velocityRatio = 1.3;

          if (absX > GameConstants.swipeMinVelocity &&
              absX > absY * velocityRatio) {
            _processSwipe(velocity.dx > 0 ? Direction.right : Direction.left);
          } else if (absY > GameConstants.swipeMinVelocity &&
              absY > absX * velocityRatio) {
            _processSwipe(velocity.dy > 0 ? Direction.down : Direction.up);
          }
        }

        // Reset for next gesture
        _cumulativeDelta = Offset.zero;
        _hasTriggeredThisGesture = false;
        _lastGestureDirection = null;
      },
      onTap: () {
        HapticService().selectionClick();
        widget.onTap?.call(); // Call external tap handler (e.g. pause)
      },
      child: widget.child,
    );
  }
}

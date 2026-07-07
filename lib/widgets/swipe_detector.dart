import 'package:flutter/material.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/utils/responsive.dart';

class SwipeDetector extends StatefulWidget {
  final Widget child;
  final Function(Direction) onSwipe;
  final VoidCallback? onTap; // Callback for tap gesture (e.g., to pause)
  final bool showFeedback;

  const SwipeDetector({
    super.key,
    required this.child,
    required this.onSwipe,
    this.onTap,
    this.showFeedback = true,
  });

  @override
  State<SwipeDetector> createState() => _SwipeDetectorState();
}

class _SwipeDetectorState extends State<SwipeDetector>
    with SingleTickerProviderStateMixin {
  late AnimationController _feedbackController;
  late Animation<double> _opacityAnimation;

  Direction? _lastSwipeDirection;
  bool _isProcessingSwipe = false;
  DateTime? _lastSwipeTime;

  // Cumulative tracking for better swipe detection
  Offset _cumulativeDelta = Offset.zero;
  bool _hasTriggeredThisGesture = false;

  // Direction most recently triggered within the CURRENT drag. A drag
  // can now trigger multiple turns (e.g. up-then-right around a corner
  // without lifting the finger); this prevents the same direction from
  // re-firing continuously while the finger keeps moving that way.
  Direction? _lastGestureDirection;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      duration: const Duration(
        milliseconds: 200,
      ), // Slightly slower for better visibility
      vsync: this,
    );

    _opacityAnimation =
        Tween<double>(
          begin: 0.0,
          end: 0.5, // More visible feedback
        ).animate(
          CurvedAnimation(parent: _feedbackController, curve: Curves.easeOut),
        );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _processSwipe(Direction direction) {
    final now = DateTime.now();

    // Allow direction changes but prevent spam
    if (_isProcessingSwipe &&
        _lastSwipeTime != null &&
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

    setState(() {
      _isProcessingSwipe = true;
      _lastSwipeDirection = direction;
      _lastSwipeTime = now;
    });

    // Immediate haptic feedback
    HapticService().lightImpact();

    // Visual feedback with longer display time
    if (widget.showFeedback) {
      // Reset and start animation
      _feedbackController.reset();
      _feedbackController.forward().then((_) {
        if (mounted) {
          // Stay visible longer before fading
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              _feedbackController.reverse();
            }
          });
        }
      });
    }

    // Call the callback immediately
    widget.onSwipe(direction);

    // Reset processing flag quickly to allow direction changes
    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) {
        setState(() {
          _isProcessingSwipe = false;
        });
      }
    });
  }

  /// Determines the swipe direction from cumulative delta with directional ratio check.
  /// Returns null if the swipe is ambiguous (too diagonal).
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
        // Backup: Use velocity for quick flicks that might not accumulate enough distance
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
        widget.onTap?.call(); // Call external tap handler (e.g., toggle pause)
      },
      child: Stack(
        children: [
          widget.child,
          // Gesture feedback indicator - positioned over game board center
          if (widget.showFeedback && _lastSwipeDirection != null)
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _feedbackController,
                    builder: (context, child) {
                      return Container(
                        width: GameConstants.gestureIndicatorSize,
                        height: GameConstants.gestureIndicatorSize,
                        decoration: BoxDecoration(
                          color: _getDirectionColor(
                            _lastSwipeDirection!,
                          ).withValues(alpha: _opacityAnimation.value * 0.9),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha: _opacityAnimation.value * 0.8,
                            ),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _getDirectionColor(_lastSwipeDirection!)
                                  .withValues(
                                    alpha: _opacityAnimation.value * 0.4,
                                  ),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: Center(
                          child: AnimatedScale(
                            scale: _feedbackController.isAnimating ? 1.3 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            child: Icon(
                              _getDirectionIconData(_lastSwipeDirection!),
                              size: 32,
                              color: Colors.white.withValues(
                                alpha: _opacityAnimation.value,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getDirectionColor(Direction direction) {
    switch (direction) {
      case Direction.up:
        return const Color(0xFF00BCD4); // Cyan
      case Direction.down:
        return const Color(0xFF4CAF50); // Green
      case Direction.left:
        return const Color(0xFFFF9800); // Orange
      case Direction.right:
        return const Color(0xFF9C27B0); // Purple
    }
  }

  IconData _getDirectionIconData(Direction direction) {
    switch (direction) {
      case Direction.up:
        return Icons.keyboard_arrow_up_rounded;
      case Direction.down:
        return Icons.keyboard_arrow_down_rounded;
      case Direction.left:
        return Icons.keyboard_arrow_left_rounded;
      case Direction.right:
        return Icons.keyboard_arrow_right_rounded;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snake_classic/utils/direction.dart';

class SwipeDetector extends StatefulWidget {
  final Widget child;
  final Function(Direction) onSwipe;
  final bool showFeedback;

  const SwipeDetector({
    super.key,
    required this.child,
    required this.onSwipe,
    this.showFeedback = true,
  });

  @override
  State<SwipeDetector> createState() => _SwipeDetectorState();
}

class _SwipeDetectorState extends State<SwipeDetector>
    with SingleTickerProviderStateMixin {
  late AnimationController _feedbackController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  Direction? _lastSwipeDirection;
  bool _isProcessingSwipe = false;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _processSwipe(Direction direction) {
    if (_isProcessingSwipe) return;
    
    setState(() {
      _isProcessingSwipe = true;
      _lastSwipeDirection = direction;
    });

    // Visual and haptic feedback
    if (widget.showFeedback) {
      HapticFeedback.lightImpact();
      _feedbackController.forward().then((_) {
        _feedbackController.reverse();
      });
    }

    // Call the callback
    widget.onSwipe(direction);

    // Prevent rapid fire swipes
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _isProcessingSwipe = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanEnd: (details) {
        final velocity = details.velocity.pixelsPerSecond;
        final absX = velocity.dx.abs();
        final absY = velocity.dy.abs();
        
        // Minimum velocity threshold for swipe detection
        const minVelocity = 500.0;
        
        if (absX > minVelocity || absY > minVelocity) {
          if (absX > absY) {
            // Horizontal swipe
            if (velocity.dx > 0) {
              _processSwipe(Direction.right);
            } else {
              _processSwipe(Direction.left);
            }
          } else {
            // Vertical swipe
            if (velocity.dy > 0) {
              _processSwipe(Direction.down);
            } else {
              _processSwipe(Direction.up);
            }
          }
        }
      },
      onTap: () {
        // Optional tap handling for pause/resume
        HapticFeedback.selectionClick();
      },
      child: AnimatedBuilder(
        animation: _feedbackController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              children: [
                widget.child,
                if (widget.showFeedback && _lastSwipeDirection != null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getDirectionColor(_lastSwipeDirection!)
                              .withValues(alpha: _opacityAnimation.value),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: _getDirectionIcon(_lastSwipeDirection!),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getDirectionColor(Direction direction) {
    switch (direction) {
      case Direction.up:
        return Colors.blue;
      case Direction.down:
        return Colors.green;
      case Direction.left:
        return Colors.orange;
      case Direction.right:
        return Colors.purple;
    }
  }

  Widget _getDirectionIcon(Direction direction) {
    IconData iconData;
    switch (direction) {
      case Direction.up:
        iconData = Icons.keyboard_arrow_up;
        break;
      case Direction.down:
        iconData = Icons.keyboard_arrow_down;
        break;
      case Direction.left:
        iconData = Icons.keyboard_arrow_left;
        break;
      case Direction.right:
        iconData = Icons.keyboard_arrow_right;
        break;
    }
    
    return AnimatedScale(
      scale: _feedbackController.isAnimating ? 1.5 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Icon(
        iconData,
        size: 48,
        color: Colors.white.withValues(alpha: 0.8),
      ),
    );
  }
}
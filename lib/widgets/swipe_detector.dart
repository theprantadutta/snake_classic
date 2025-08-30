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
  late Animation<double> _opacityAnimation;
  
  Direction? _lastSwipeDirection;
  bool _isProcessingSwipe = false;
  DateTime? _lastSwipeTime;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 200), // Slightly slower for better visibility
      vsync: this,
    );
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5, // More visible feedback
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
    final now = DateTime.now();
    
    // Allow direction changes but prevent spam
    if (_isProcessingSwipe && 
        _lastSwipeTime != null && 
        now.difference(_lastSwipeTime!).inMilliseconds < 50) {
      return;
    }
    
    // If same direction within short time, ignore
    if (_lastSwipeDirection == direction &&
        _lastSwipeTime != null && 
        now.difference(_lastSwipeTime!).inMilliseconds < 150) {
      return;
    }
    
    setState(() {
      _isProcessingSwipe = true;
      _lastSwipeDirection = direction;
      _lastSwipeTime = now;
    });

    // Immediate haptic feedback
    HapticFeedback.lightImpact();
    
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanUpdate: (details) {
        // Detect swipes during pan for more responsive feeling
        final delta = details.delta;
        const minDelta = 2.0; // Lower threshold for faster response
        
        if (delta.dx.abs() > minDelta || delta.dy.abs() > minDelta) {
          if (delta.dx.abs() > delta.dy.abs()) {
            // Horizontal swipe
            if (delta.dx > 0) {
              _processSwipe(Direction.right);
            } else {
              _processSwipe(Direction.left);
            }
          } else {
            // Vertical swipe
            if (delta.dy > 0) {
              _processSwipe(Direction.down);
            } else {
              _processSwipe(Direction.up);
            }
          }
        }
      },
      onPanEnd: (details) {
        // Backup swipe detection with velocity for missed quick swipes
        final velocity = details.velocity.pixelsPerSecond;
        final absX = velocity.dx.abs();
        final absY = velocity.dy.abs();
        
        const minVelocity = 300.0; // Lower threshold for better responsiveness
        
        if (absX > minVelocity || absY > minVelocity) {
          if (absX > absY) {
            if (velocity.dx > 0) {
              _processSwipe(Direction.right);
            } else {
              _processSwipe(Direction.left);
            }
          } else {
            if (velocity.dy > 0) {
              _processSwipe(Direction.down);
            } else {
              _processSwipe(Direction.up);
            }
          }
        }
      },
      onTap: () {
        HapticFeedback.selectionClick();
      },
      child: Stack(
        children: [
          widget.child,
          // Gesture feedback indicator - positioned to avoid UI overlap
          if (widget.showFeedback && _lastSwipeDirection != null)
            Positioned(
              bottom: 100, // Position above bottom UI elements
              left: 20,    // Left side to avoid pause button
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _feedbackController,
                  builder: (context, child) {
                    return Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: _getDirectionColor(_lastSwipeDirection!)
                            .withValues(alpha: _opacityAnimation.value * 0.9),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: _opacityAnimation.value * 0.8),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _getDirectionColor(_lastSwipeDirection!)
                                .withValues(alpha: _opacityAnimation.value * 0.4),
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
                            color: Colors.white.withValues(alpha: _opacityAnimation.value),
                          ),
                        ),
                      ),
                    );
                  },
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
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:snake_classic/widgets/advanced_particle_system.dart';
import 'package:snake_classic/widgets/screen_shake.dart';
import 'package:snake_classic/utils/constants.dart';

// Visual Effects Manager - coordinates all visual effects
class VisualEffectsManager extends ChangeNotifier {
  final ParticleManager particleManager = ParticleManager();
  final GameJuiceController juiceController = GameJuiceController();
  
  // Food consumption effects
  void playFoodEatenEffect(Offset position, GameTheme theme) {
    // Add particle explosion
    particleManager.emitAt(position, ParticleConfig.foodExplosion);
    
    // Add screen juice
    juiceController.foodEaten();
    
    // Add score popup particles
    final scorePosition = Offset(position.dx, position.dy - 30);
    particleManager.emitAt(scorePosition, ParticleConfig.scorePopup);
    
    notifyListeners();
  }
  
  void playBonusFoodEatenEffect(Offset position, GameTheme theme) {
    // Enhanced explosion for bonus food
    final bonusConfig = ParticleConfig(
      type: ParticleType.food,
      count: 25,
      lifetime: const Duration(milliseconds: 1200),
      minSize: 4.0,
      maxSize: 12.0,
      minSpeed: 100.0,
      maxSpeed: 250.0,
      colors: [
        const Color(0xFFFFD700), // Gold
        const Color(0xFFFF69B4), // Hot pink
        const Color(0xFF00FFFF), // Cyan
      ],
      blendMode: ParticleBlendMode.additive,
      gravity: 150.0,
      friction: 0.93,
    );
    
    particleManager.emitAt(position, bonusConfig);
    juiceController.bonusFoodEaten();
    
    // Add sparkle ring effect
    _createSparkleRing(position, 8);
    
    notifyListeners();
  }
  
  void playSpecialFoodEatenEffect(Offset position, GameTheme theme) {
    // Massive explosion for special food
    final specialConfig = ParticleConfig(
      type: ParticleType.explosion,
      count: 35,
      lifetime: const Duration(milliseconds: 1500),
      minSize: 6.0,
      maxSize: 18.0,
      minSpeed: 150.0,
      maxSpeed: 400.0,
      colors: [
        const Color(0xFFFFD700), // Gold
        const Color(0xFFFF4444), // Red
        const Color(0xFF44FF44), // Green
        const Color(0xFF4444FF), // Blue
      ],
      blendMode: ParticleBlendMode.additive,
      gravity: 100.0,
      friction: 0.94,
    );
    
    particleManager.emitAt(position, specialConfig);
    juiceController.specialFoodEaten();
    
    // Add multiple sparkle rings
    _createSparkleRing(position, 12);
    Future.delayed(const Duration(milliseconds: 200), () {
      _createSparkleRing(position, 8);
    });
    
    notifyListeners();
  }
  
  void playPowerUpCollectedEffect(Offset position, GameTheme theme) {
    particleManager.emitAt(position, ParticleConfig.powerUpGlow);
    juiceController.powerUpCollected();
    
    // Add ascending sparkles
    _createAscendingSparkles(position);
    
    notifyListeners();
  }
  
  void playGameOverEffect(Offset crashPosition, GameTheme theme) {
    // Massive explosion at crash site
    final crashConfig = ParticleConfig(
      type: ParticleType.explosion,
      count: 50,
      lifetime: const Duration(milliseconds: 2000),
      minSize: 8.0,
      maxSize: 20.0,
      minSpeed: 50.0,
      maxSpeed: 350.0,
      colors: [
        const Color(0xFFFF0000), // Red
        const Color(0xFFFF8800), // Orange
        const Color(0xFFFFDD00), // Yellow
        Colors.white,
      ],
      blendMode: ParticleBlendMode.additive,
      gravity: 200.0,
      friction: 0.92,
    );
    
    particleManager.emitAt(crashPosition, crashConfig);
    juiceController.gameOver();
    
    notifyListeners();
  }
  
  void playLevelUpEffect(Offset centerPosition, GameTheme theme) {
    // Celebratory burst
    final levelUpConfig = ParticleConfig(
      type: ParticleType.sparkle,
      count: 20,
      lifetime: const Duration(milliseconds: 2000),
      minSize: 4.0,
      maxSize: 10.0,
      minSpeed: 80.0,
      maxSpeed: 200.0,
      colors: [
        theme.accentColor,
        theme.foodColor,
        Colors.white,
      ],
      blendMode: ParticleBlendMode.additive,
      gravity: -50.0, // Float upward
      friction: 0.95,
    );
    
    particleManager.emitAt(centerPosition, levelUpConfig);
    juiceController.levelUp();
    
    notifyListeners();
  }
  
  void _createSparkleRing(Offset center, int sparkleCount) {
    for (int i = 0; i < sparkleCount; i++) {
      final angle = (i / sparkleCount) * math.pi * 2;
      final radius = 40.0 + math.sin(i * 0.5) * 20.0;
      final sparklePos = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      
      particleManager.emitAt(sparklePos, ParticleConfig.sparkle);
    }
  }
  
  void _createAscendingSparkles(Offset position) {
    for (int i = 0; i < 5; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        final sparklePos = Offset(
          position.dx + (math.Random().nextDouble() - 0.5) * 40,
          position.dy - i * 20,
        );
        
        particleManager.emitAt(sparklePos, ParticleConfig.sparkle);
      });
    }
  }
  
  @override
  void dispose() {
    particleManager.clear();
    juiceController.dispose();
    super.dispose();
  }
}

// Enhanced UI Elements with modern animations
class EnhancedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool enabled;
  final VisualEffectsManager? effectsManager;

  const EnhancedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.enabled = true,
    this.effectsManager,
  });

  @override
  State<EnhancedButton> createState() => _EnhancedButtonState();
}

class _EnhancedButtonState extends State<EnhancedButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
    
    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    
    setState(() => _isPressed = true);
    _scaleController.forward();
    
    widget.effectsManager?.juiceController.buttonPress();
  }

  void _onTapUp(TapUpDetails details) {
    _handleTapEnd();
  }

  void _onTapCancel() {
    _handleTapEnd();
  }

  void _handleTapEnd() {
    if (!mounted) return;
    
    setState(() => _isPressed = false);
    _scaleController.reverse();
    
    if (widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _shimmerAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: widget.padding ?? const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (widget.backgroundColor ?? Colors.blue).withValues(alpha: 0.9),
                    (widget.backgroundColor ?? Colors.blue).withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (widget.backgroundColor ?? Colors.blue).withValues(alpha: 0.3),
                    blurRadius: _isPressed ? 8 : 12,
                    spreadRadius: _isPressed ? 1 : 2,
                    offset: Offset(0, _isPressed ? 2 : 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Shimmer effect overlay
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(_shimmerAnimation.value - 1, -1),
                            end: Alignment(_shimmerAnimation.value + 1, 1),
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Button content
                  DefaultTextStyle(
                    style: TextStyle(
                      color: widget.foregroundColor ?? Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    child: widget.child,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Floating score animation widget
class FloatingScoreAnimation extends StatefulWidget {
  final int score;
  final Offset startPosition;
  final Color color;
  final VoidCallback? onComplete;

  const FloatingScoreAnimation({
    super.key,
    required this.score,
    required this.startPosition,
    this.color = Colors.white,
    this.onComplete,
  });

  @override
  State<FloatingScoreAnimation> createState() => _FloatingScoreAnimationState();
}

class _FloatingScoreAnimationState extends State<FloatingScoreAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _positionAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );

    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -80),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.startPosition.dx + _positionAnimation.value.dx,
          top: widget.startPosition.dy + _positionAnimation.value.dy,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  '+${widget.score}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Ripple effect widget for tap feedback
class RippleEffect extends StatefulWidget {
  final Widget child;
  final Color rippleColor;
  final VoidCallback? onTap;

  const RippleEffect({
    super.key,
    required this.child,
    this.rippleColor = Colors.white,
    this.onTap,
  });

  @override
  State<RippleEffect> createState() => _RippleEffectState();
}

class _RippleEffectState extends State<RippleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Offset? _tapPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(TapDownDetails details) {
    setState(() {
      _tapPosition = details.localPosition;
    });
    _controller.forward().then((_) {
      _controller.reset();
      widget.onTap?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTap,
      child: Stack(
        children: [
          widget.child,
          if (_tapPosition != null)
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Positioned.fill(
                  child: CustomPaint(
                    painter: RipplePainter(
                      progress: _animation.value,
                      center: _tapPosition!,
                      color: widget.rippleColor,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class RipplePainter extends CustomPainter {
  final double progress;
  final Offset center;
  final Color color;

  RipplePainter({
    required this.progress,
    required this.center,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height);
    final radius = maxRadius * progress;
    final opacity = 1.0 - progress;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity * 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant RipplePainter oldDelegate) {
    return progress != oldDelegate.progress || center != oldDelegate.center;
  }
}
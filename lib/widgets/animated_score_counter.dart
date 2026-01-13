import 'package:flutter/material.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/typography.dart';

/// Size variants for the animated score counter
enum ScoreCounterSize {
  /// Small counter for compact displays - 24px
  small(24),

  /// Medium counter for standard use - 36px
  medium(36),

  /// Large counter for prominent display - 48px
  large(48),

  /// Extra large for game over/celebration - 64px
  extraLarge(64);

  final double fontSize;

  const ScoreCounterSize(this.fontSize);
}

/// An animated score counter that smoothly transitions between values
/// with optional burst effects on score increase
class AnimatedScoreCounter extends StatefulWidget {
  /// The current score value
  final int score;

  /// The current game theme for color coordination
  final GameTheme theme;

  /// The size of the counter
  final ScoreCounterSize size;

  /// Duration of the counting animation
  final Duration animationDuration;

  /// Whether to show burst effect on score increase
  final bool enableBurstEffect;

  /// Custom text color (overrides theme)
  final Color? textColor;

  /// Custom glow color for burst effect
  final Color? glowColor;

  /// Optional prefix text (e.g., "Score: ")
  final String? prefix;

  /// Optional suffix text (e.g., " pts")
  final String? suffix;

  /// Whether to show shadow effect
  final bool showShadow;

  /// Callback when counting animation completes
  final VoidCallback? onAnimationComplete;

  const AnimatedScoreCounter({
    super.key,
    required this.score,
    required this.theme,
    this.size = ScoreCounterSize.medium,
    this.animationDuration = const Duration(milliseconds: 300),
    this.enableBurstEffect = true,
    this.textColor,
    this.glowColor,
    this.prefix,
    this.suffix,
    this.showShadow = true,
    this.onAnimationComplete,
  });

  @override
  State<AnimatedScoreCounter> createState() => _AnimatedScoreCounterState();
}

class _AnimatedScoreCounterState extends State<AnimatedScoreCounter>
    with TickerProviderStateMixin {
  late AnimationController _countController;
  late AnimationController _burstController;
  late Animation<double> _burstScaleAnimation;
  late Animation<double> _burstOpacityAnimation;

  int _previousScore = 0;
  int _displayedScore = 0;

  @override
  void initState() {
    super.initState();
    _previousScore = widget.score;
    _displayedScore = widget.score;

    _countController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _burstController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _burstScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_burstController);

    _burstOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.6),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.6, end: 0.0),
        weight: 70,
      ),
    ]).animate(_burstController);

    _countController.addListener(_updateDisplayedScore);
    _countController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _countController.removeListener(_updateDisplayedScore);
    _countController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedScoreCounter oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.score != oldWidget.score) {
      _previousScore = _displayedScore;

      // Trigger burst effect if score increased
      if (widget.enableBurstEffect && widget.score > oldWidget.score) {
        _burstController.forward(from: 0);
      }

      // Start counting animation
      _countController.forward(from: 0);
    }
  }

  void _updateDisplayedScore() {
    setState(() {
      _displayedScore = _previousScore +
          ((_countController.value * (widget.score - _previousScore)).round());
    });
  }

  TextStyle _getTextStyle() {
    final color = widget.textColor ?? widget.theme.accentColor;

    switch (widget.size) {
      case ScoreCounterSize.small:
        return GameTypography.scoreSmall(color: color);
      case ScoreCounterSize.medium:
        return GameTypography.scoreDisplay(color: color);
      case ScoreCounterSize.large:
        return GameTypography.scoreLarge(color: color);
      case ScoreCounterSize.extraLarge:
        return GameTypography.scoreLarge(color: color).copyWith(
          fontSize: widget.size.fontSize,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.textColor ?? widget.theme.accentColor;
    final glowColor = widget.glowColor ?? textColor;

    return AnimatedBuilder(
      animation: Listenable.merge([_burstScaleAnimation, _burstOpacityAnimation]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Burst glow effect
            if (widget.enableBurstEffect && _burstController.isAnimating)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: glowColor.withValues(
                          alpha: _burstOpacityAnimation.value,
                        ),
                        blurRadius: 30 * _burstScaleAnimation.value,
                        spreadRadius: 10 * _burstScaleAnimation.value,
                      ),
                    ],
                  ),
                ),
              ),

            // Score text with scale animation
            Transform.scale(
              scale: widget.enableBurstEffect ? _burstScaleAnimation.value : 1.0,
              child: _buildScoreText(textColor),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScoreText(Color textColor) {
    final style = _getTextStyle();

    Widget text = Text.rich(
      TextSpan(
        children: [
          if (widget.prefix != null)
            TextSpan(
              text: widget.prefix,
              style: style.copyWith(
                fontSize: style.fontSize! * 0.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          TextSpan(text: '$_displayedScore'),
          if (widget.suffix != null)
            TextSpan(
              text: widget.suffix,
              style: style.copyWith(
                fontSize: style.fontSize! * 0.6,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
      style: style.copyWith(
        shadows: widget.showShadow
            ? [
                Shadow(
                  color: textColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
    );

    return text;
  }
}

/// A simpler animated counter without the full styling
/// Good for integration into existing UI without overriding styles
class SimpleAnimatedCounter extends StatefulWidget {
  /// The current value
  final int value;

  /// Duration of the counting animation
  final Duration duration;

  /// Text style for the counter
  final TextStyle? style;

  /// Format function for the value (e.g., adding commas)
  final String Function(int)? formatter;

  const SimpleAnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 300),
    this.style,
    this.formatter,
  });

  @override
  State<SimpleAnimatedCounter> createState() => _SimpleAnimatedCounterState();
}

class _SimpleAnimatedCounterState extends State<SimpleAnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SimpleAnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _previousValue = oldWidget.value;
      _controller.forward(from: 0);
    }
  }

  String _formatValue(int value) {
    if (widget.formatter != null) {
      return widget.formatter!(value);
    }
    return '$value';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final currentValue = _previousValue +
            ((_controller.value * (widget.value - _previousValue)).round());
        return Text(
          _formatValue(currentValue),
          style: widget.style,
        );
      },
    );
  }
}

/// A countdown timer display with animation
class AnimatedCountdown extends StatefulWidget {
  /// The remaining time in seconds
  final int seconds;

  /// The theme for styling
  final GameTheme theme;

  /// Whether to show milliseconds
  final bool showMilliseconds;

  /// Whether to pulse when low on time
  final bool pulseWhenLow;

  /// Threshold for "low time" warning (in seconds)
  final int lowTimeThreshold;

  const AnimatedCountdown({
    super.key,
    required this.seconds,
    required this.theme,
    this.showMilliseconds = false,
    this.pulseWhenLow = true,
    this.lowTimeThreshold = 10,
  });

  @override
  State<AnimatedCountdown> createState() => _AnimatedCountdownState();
}

class _AnimatedCountdownState extends State<AnimatedCountdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.pulseWhenLow && widget.seconds <= widget.lowTimeThreshold) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  String _formatTime() {
    final minutes = widget.seconds ~/ 60;
    final secs = widget.seconds % 60;

    if (minutes > 0) {
      return '$minutes:${secs.toString().padLeft(2, '0')}';
    }
    return '$secs';
  }

  @override
  Widget build(BuildContext context) {
    final isLow = widget.seconds <= widget.lowTimeThreshold;
    final color = isLow ? Colors.red : widget.theme.accentColor;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isLow && widget.pulseWhenLow ? _pulseAnimation.value : 1.0,
          child: Text(
            _formatTime(),
            style: GameTypography.scoreDisplay(color: color).copyWith(
              shadows: [
                Shadow(
                  color: color.withValues(alpha: isLow ? 0.5 : 0.3),
                  blurRadius: isLow ? 12 : 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

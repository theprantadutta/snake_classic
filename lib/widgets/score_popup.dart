import 'package:flutter/material.dart';

/// A floating score popup that rises and fades out
class ScorePopup extends StatefulWidget {
  final int points;
  final int multiplier;
  final Offset position;
  final Color color;
  final VoidCallback onComplete;

  const ScorePopup({
    super.key,
    required this.points,
    this.multiplier = 1,
    required this.position,
    required this.color,
    required this.onComplete,
  });

  @override
  State<ScorePopup> createState() => _ScorePopupState();
}

class _ScorePopupState extends State<ScorePopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  late Animation<double> _rise;

  // Peak scale rises with multiplier so a 3x bite feels heavier than a 1x.
  double get _peakScale {
    switch (widget.multiplier) {
      case >= 3:
        return 2.0;
      case 2:
        return 1.7;
      default:
        return 1.3;
    }
  }

  // Heat-flash color held over the first 200ms of the animation; settles
  // back to the food color afterwards.
  Color get _flashColor {
    switch (widget.multiplier) {
      case >= 3:
        return Colors.red;
      case 2:
        return Colors.orange;
      default:
        return widget.color;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    final peak = _peakScale;
    // Scale: quick bounce in, then settle. Peak height scales with multiplier.
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.5,
          end: peak,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: peak,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 50),
    ]).animate(_controller);

    // Opacity: stay visible, then fade out at the end
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 70),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(_controller);

    // Rise: smooth upward movement (reduced distance for smaller popup)
    _rise = Tween<double>(
      begin: 0,
      end: 45,
    ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(_controller);

    _controller.forward().then((_) {
      widget.onComplete();
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
      builder: (context, _) {
        return Positioned(
          left: widget.position.dx - 20,
          top: widget.position.dy - _rise.value,
          child: Opacity(
            opacity: _opacity.value,
            child: Transform.scale(scale: _scale.value, child: _buildBadge()),
          ),
        );
      },
    );
  }

  Widget _buildBadge() {
    final displayText = widget.multiplier > 1
        ? '+${widget.points} x${widget.multiplier}'
        : '+${widget.points}';

    final flash = _flashColor;
    // Lerp from the heat-flash color (multiplier 2/3) to the food color over
    // the first 30% of the animation so big multipliers read as red-hot,
    // then settle into the standard food palette.
    final flashProgress = (_controller.value / 0.3).clamp(0.0, 1.0);
    final effectiveColor = widget.multiplier >= 2
        ? Color.lerp(flash, widget.color, flashProgress) ?? widget.color
        : widget.color;
    final shadowBlur = 4.0 + (widget.multiplier - 1) * 3.0;
    final shadowSpread = 1.0 + (widget.multiplier - 1) * 1.5;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.multiplier >= 2 ? 10 : 8,
        vertical: widget.multiplier >= 2 ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: effectiveColor.withValues(alpha: 0.5),
            blurRadius: shadowBlur,
            spreadRadius: shadowSpread,
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: widget.multiplier >= 2 ? 0.55 : 0.25),
          width: widget.multiplier >= 2 ? 1.5 : 1,
        ),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: Colors.white,
          fontSize: widget.multiplier >= 3 ? 16 : widget.multiplier == 2 ? 14 : 11,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.4),
              offset: const Offset(0.5, 0.5),
              blurRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

/// Manager class to handle multiple score popups
class ScorePopupManager {
  final List<ScorePopupData> _activePopups = [];
  int _nextId = 0;

  List<ScorePopupData> get activePopups => List.unmodifiable(_activePopups);

  /// Add a new score popup
  int addPopup({
    required int points,
    required Offset position,
    required Color color,
    int multiplier = 1,
  }) {
    final id = _nextId++;
    _activePopups.add(
      ScorePopupData(
        id: id,
        points: points,
        position: position,
        color: color,
        multiplier: multiplier,
      ),
    );
    return id;
  }

  /// Remove a popup by ID
  void removePopup(int id) {
    _activePopups.removeWhere((popup) => popup.id == id);
  }

  /// Clear all popups
  void clear() {
    _activePopups.clear();
  }
}

/// Data class for score popup information
class ScorePopupData {
  final int id;
  final int points;
  final Offset position;
  final Color color;
  final int multiplier;

  const ScorePopupData({
    required this.id,
    required this.points,
    required this.position,
    required this.color,
    this.multiplier = 1,
  });
}

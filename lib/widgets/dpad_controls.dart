import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';

/// On-screen D-Pad controller for touch-based directional input.
/// Provides an alternative to swipe controls for users who prefer buttons.
class DPadControls extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Smaller buttons + more edge-padding so the four circles have clear
    // breathing room from each other (no more overlapping affordance
    // rings at the diagonals).
    final buttonSize = size * 0.30;
    final spacing = size * 0.04;
    final hubSize = size * 0.10;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: opacity * 0.25),
        borderRadius: BorderRadius.circular(size * 0.18),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: opacity * 0.18),
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
              color: theme.accentColor.withValues(alpha: opacity * 0.25),
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
    );
  }

  Widget _buildDirectionButton({
    required Direction direction,
    required IconData icon,
    required double buttonSize,
  }) {
    return _DPadButton(
      direction: direction,
      icon: icon,
      size: buttonSize,
      theme: theme,
      opacity: opacity,
      onPressed: () {
        HapticFeedback.lightImpact();
        onDirection(direction);
      },
    );
  }
}

class _DPadButton extends StatefulWidget {
  final Direction direction;
  final IconData icon;
  final double size;
  final GameTheme theme;
  final double opacity;
  final VoidCallback onPressed;

  const _DPadButton({
    required this.direction,
    required this.icon,
    required this.size,
    required this.theme,
    required this.opacity,
    required this.onPressed,
  });

  @override
  State<_DPadButton> createState() => _DPadButtonState();
}

class _DPadButtonState extends State<_DPadButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        widget.onPressed();
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isPressed
              ? widget.theme.accentColor.withValues(alpha: widget.opacity * 0.55)
              : widget.theme.accentColor.withValues(alpha: widget.opacity * 0.22),
          border: Border.all(
            color: widget.theme.accentColor.withValues(
              alpha: widget.opacity * 0.5,
            ),
            width: _isPressed ? 2 : 1.2,
          ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: widget.theme.accentColor.withValues(alpha: 0.35),
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
            widget.icon,
            size: widget.size * 0.62,
            color: widget.theme.accentColor.withValues(
              alpha: _isPressed ? widget.opacity : widget.opacity * 0.85,
            ),
          ),
        ),
      ),
    );
  }
}

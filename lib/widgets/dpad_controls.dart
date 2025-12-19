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
    final buttonSize = size * 0.35;
    final spacing = size * 0.02;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: opacity * 0.3),
        borderRadius: BorderRadius.circular(size * 0.15),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: opacity * 0.2),
          width: 1,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Up button
          Positioned(
            top: spacing,
            child: _buildDirectionButton(
              direction: Direction.up,
              icon: Icons.keyboard_arrow_up_rounded,
              buttonSize: buttonSize,
            ),
          ),
          // Down button
          Positioned(
            bottom: spacing,
            child: _buildDirectionButton(
              direction: Direction.down,
              icon: Icons.keyboard_arrow_down_rounded,
              buttonSize: buttonSize,
            ),
          ),
          // Left button
          Positioned(
            left: spacing,
            child: _buildDirectionButton(
              direction: Direction.left,
              icon: Icons.keyboard_arrow_left_rounded,
              buttonSize: buttonSize,
            ),
          ),
          // Right button
          Positioned(
            right: spacing,
            child: _buildDirectionButton(
              direction: Direction.right,
              icon: Icons.keyboard_arrow_right_rounded,
              buttonSize: buttonSize,
            ),
          ),
          // Center indicator (optional visual element)
          Container(
            width: buttonSize * 0.5,
            height: buttonSize * 0.5,
            decoration: BoxDecoration(
              color: theme.accentColor.withValues(alpha: opacity * 0.1),
              shape: BoxShape.circle,
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
          color: _isPressed
              ? widget.theme.accentColor.withValues(alpha: widget.opacity * 0.5)
              : widget.theme.accentColor.withValues(alpha: widget.opacity * 0.2),
          borderRadius: BorderRadius.circular(widget.size * 0.25),
          border: Border.all(
            color: widget.theme.accentColor.withValues(alpha: widget.opacity * 0.4),
            width: _isPressed ? 2 : 1,
          ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: widget.theme.accentColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Icon(
          widget.icon,
          size: widget.size * 0.6,
          color: widget.theme.accentColor.withValues(
            alpha: _isPressed ? widget.opacity : widget.opacity * 0.8,
          ),
        ),
      ),
    );
  }
}

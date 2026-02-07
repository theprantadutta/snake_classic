import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/typography.dart';

/// Button size variants
enum GameButtonSize {
  /// Small button - 36px height, 12px font
  small,

  /// Medium button - 48px height, 14px font
  medium,

  /// Large button - 56px height, 16px font
  large,

  /// Hero button - 64px height, 18px font (for main CTAs)
  hero,
}

/// Button style variants
enum GameButtonVariant {
  /// Primary button with theme gradient
  primary,

  /// Secondary button with border only
  secondary,

  /// Ghost button with minimal styling
  ghost,

  /// Premium gold-styled button
  premium,

  /// Danger/destructive action button
  danger,

  /// Success/positive action button
  success,
}

/// A flexible button component with multiple size and style variants
class GameButton extends StatefulWidget {
  /// Button label text
  final String text;

  /// Current game theme for color coordination
  final GameTheme theme;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Button size variant
  final GameButtonSize size;

  /// Button style variant
  final GameButtonVariant variant;

  /// Optional icon to display before text
  final IconData? icon;

  /// Optional icon to display after text
  final IconData? trailingIcon;

  /// Whether the button is in loading state
  final bool isLoading;

  /// Whether the button is disabled
  final bool isDisabled;

  /// Fixed width (null for auto-width)
  final double? width;

  /// Whether button should expand to fill available width
  final bool expanded;

  /// Whether to play sound on tap
  final bool enableSound;

  /// Whether to trigger haptic feedback on tap
  final bool enableHaptics;

  const GameButton({
    super.key,
    required this.text,
    required this.theme,
    this.onPressed,
    this.size = GameButtonSize.medium,
    this.variant = GameButtonVariant.primary,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.expanded = false,
    this.enableSound = true,
    this.enableHaptics = true,
  });

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isEnabled => !widget.isDisabled && !widget.isLoading && widget.onPressed != null;

  double get _height {
    switch (widget.size) {
      case GameButtonSize.small:
        return 36;
      case GameButtonSize.medium:
        return 48;
      case GameButtonSize.large:
        return 56;
      case GameButtonSize.hero:
        return 64;
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case GameButtonSize.small:
        return 12;
      case GameButtonSize.medium:
        return 14;
      case GameButtonSize.large:
        return 16;
      case GameButtonSize.hero:
        return 18;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case GameButtonSize.small:
        return 16;
      case GameButtonSize.medium:
        return 20;
      case GameButtonSize.large:
        return 24;
      case GameButtonSize.hero:
        return 28;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case GameButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case GameButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case GameButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
      case GameButtonSize.hero:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  BoxDecoration _buildDecoration() {
    final glowIntensity = _glowAnimation.value;

    switch (widget.variant) {
      case GameButtonVariant.primary:
        return BoxDecoration(
          gradient: _isEnabled
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [widget.theme.accentColor, widget.theme.snakeColor],
                )
              : null,
          color: _isEnabled ? null : widget.theme.accentColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isEnabled
              ? [
                  BoxShadow(
                    color: widget.theme.accentColor.withValues(
                      alpha: 0.3 + (glowIntensity * 0.2),
                    ),
                    blurRadius: 8 + (glowIntensity * 4),
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        );

      case GameButtonVariant.secondary:
        return BoxDecoration(
          color: _isEnabled
              ? widget.theme.accentColor.withValues(alpha: 0.1)
              : widget.theme.accentColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isEnabled
                ? widget.theme.accentColor.withValues(alpha: 0.4)
                : widget.theme.accentColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
        );

      case GameButtonVariant.ghost:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isEnabled
                ? widget.theme.accentColor.withValues(alpha: 0.2)
                : widget.theme.accentColor.withValues(alpha: 0.1),
            width: 1,
          ),
        );

      case GameButtonVariant.premium:
        return BoxDecoration(
          gradient: _isEnabled
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                )
              : null,
          color: _isEnabled ? null : Colors.amber.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isEnabled
              ? [
                  BoxShadow(
                    color: Colors.amber.withValues(
                      alpha: 0.4 + (glowIntensity * 0.2),
                    ),
                    blurRadius: 12 + (glowIntensity * 4),
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        );

      case GameButtonVariant.danger:
        return BoxDecoration(
          gradient: _isEnabled
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.red.shade600, Colors.red.shade800],
                )
              : null,
          color: _isEnabled ? null : Colors.red.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isEnabled
              ? [
                  BoxShadow(
                    color: Colors.red.withValues(
                      alpha: 0.3 + (glowIntensity * 0.2),
                    ),
                    blurRadius: 8 + (glowIntensity * 4),
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        );

      case GameButtonVariant.success:
        return BoxDecoration(
          gradient: _isEnabled
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.green.shade500, Colors.green.shade700],
                )
              : null,
          color: _isEnabled ? null : Colors.green.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isEnabled
              ? [
                  BoxShadow(
                    color: Colors.green.withValues(
                      alpha: 0.3 + (glowIntensity * 0.2),
                    ),
                    blurRadius: 8 + (glowIntensity * 4),
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        );
    }
  }

  Color get _textColor {
    if (!_isEnabled) {
      return widget.theme.accentColor.withValues(alpha: 0.5);
    }

    switch (widget.variant) {
      case GameButtonVariant.primary:
      case GameButtonVariant.danger:
      case GameButtonVariant.success:
        return Colors.white;
      case GameButtonVariant.premium:
        return Colors.amber.shade900;
      case GameButtonVariant.secondary:
      case GameButtonVariant.ghost:
        return widget.theme.accentColor;
    }
  }

  void _onTapDown(TapDownDetails details) {
    if (_isEnabled) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  void _onTap() {
    if (!_isEnabled) return;

    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
    if (widget.enableSound) {
      AudioService().playSound('button_click');
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.expanded ? double.infinity : widget.width,
              height: _height,
              padding: _padding,
              decoration: _buildDecoration(),
              child: _buildContent(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: _iconSize,
          height: _iconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: _textColor,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            color: _textColor,
            size: _iconSize,
          ),
          SizedBox(width: widget.size == GameButtonSize.small ? 6 : 8),
        ],
        Flexible(
          child: Text(
            widget.text,
            style: GameTypography.buttonLarge(color: _textColor).copyWith(
              fontSize: _fontSize,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        if (widget.trailingIcon != null) ...[
          SizedBox(width: widget.size == GameButtonSize.small ? 6 : 8),
          Icon(
            widget.trailingIcon,
            color: _textColor,
            size: _iconSize,
          ),
        ],
      ],
    );
  }
}

/// A circular icon button variant
class GameIconButton extends StatefulWidget {
  final IconData icon;
  final GameTheme theme;
  final VoidCallback? onPressed;
  final GameButtonSize size;
  final GameButtonVariant variant;
  final bool isDisabled;
  final String? tooltip;

  const GameIconButton({
    super.key,
    required this.icon,
    required this.theme,
    this.onPressed,
    this.size = GameButtonSize.medium,
    this.variant = GameButtonVariant.secondary,
    this.isDisabled = false,
    this.tooltip,
  });

  @override
  State<GameIconButton> createState() => _GameIconButtonState();
}

class _GameIconButtonState extends State<GameIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.86).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isEnabled => !widget.isDisabled && widget.onPressed != null;

  double get _size {
    switch (widget.size) {
      case GameButtonSize.small:
        return 32;
      case GameButtonSize.medium:
        return 44;
      case GameButtonSize.large:
        return 52;
      case GameButtonSize.hero:
        return 64;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case GameButtonSize.small:
        return 16;
      case GameButtonSize.medium:
        return 22;
      case GameButtonSize.large:
        return 26;
      case GameButtonSize.hero:
        return 32;
    }
  }

  Color get _iconColor {
    if (!_isEnabled) {
      return widget.theme.accentColor.withValues(alpha: 0.4);
    }

    switch (widget.variant) {
      case GameButtonVariant.primary:
      case GameButtonVariant.danger:
      case GameButtonVariant.success:
        return Colors.white;
      case GameButtonVariant.premium:
        return Colors.amber.shade900;
      case GameButtonVariant.secondary:
      case GameButtonVariant.ghost:
        return widget.theme.accentColor;
    }
  }

  BoxDecoration _buildDecoration() {
    switch (widget.variant) {
      case GameButtonVariant.primary:
        return BoxDecoration(
          gradient: _isEnabled
              ? LinearGradient(
                  colors: [widget.theme.accentColor, widget.theme.snakeColor],
                )
              : null,
          color: _isEnabled ? null : widget.theme.accentColor.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        );
      case GameButtonVariant.secondary:
        return BoxDecoration(
          color: _isEnabled
              ? widget.theme.accentColor.withValues(alpha: 0.1)
              : widget.theme.accentColor.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.theme.accentColor.withValues(alpha: _isEnabled ? 0.3 : 0.15),
          ),
        );
      case GameButtonVariant.ghost:
        return BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.theme.accentColor.withValues(alpha: _isEnabled ? 0.2 : 0.1),
          ),
        );
      case GameButtonVariant.premium:
        return BoxDecoration(
          gradient: _isEnabled
              ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)])
              : null,
          color: _isEnabled ? null : Colors.amber.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        );
      case GameButtonVariant.danger:
        return BoxDecoration(
          gradient: _isEnabled
              ? LinearGradient(colors: [Colors.red.shade600, Colors.red.shade800])
              : null,
          color: _isEnabled ? null : Colors.red.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        );
      case GameButtonVariant.success:
        return BoxDecoration(
          gradient: _isEnabled
              ? LinearGradient(colors: [Colors.green.shade500, Colors.green.shade700])
              : null,
          color: _isEnabled ? null : Colors.green.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget button = GestureDetector(
      onTapDown: (_) => _isEnabled ? _controller.forward() : null,
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: _isEnabled
          ? () {
              HapticFeedback.lightImpact();
              AudioService().playSound('button_click');
              widget.onPressed?.call();
            }
          : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: _size,
              height: _size,
              decoration: _buildDecoration(),
              child: Center(
                child: Icon(
                  widget.icon,
                  color: _iconColor,
                  size: _iconSize,
                ),
              ),
            ),
          );
        },
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}

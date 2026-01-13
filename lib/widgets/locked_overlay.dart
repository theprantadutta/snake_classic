import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/typography.dart';

/// Style variants for locked overlays
enum LockedOverlayStyle {
  /// Standard locked with blur and dark overlay
  standard,

  /// Premium locked - suggests purchase
  premium,

  /// Level locked - shows level requirement
  level,

  /// Coming soon - not yet available
  comingSoon,

  /// Maintenance - temporarily unavailable
  maintenance,
}

/// An overlay that indicates locked/unavailable content
/// Provides blur effect, dark gradient, and informative messaging
class LockedOverlay extends StatelessWidget {
  /// The style of the locked overlay
  final LockedOverlayStyle style;

  /// The current game theme for color coordination
  final GameTheme? theme;

  /// Optional message to display
  final String? message;

  /// Optional sub-message with additional info
  final String? subMessage;

  /// Optional level requirement (for level style)
  final int? requiredLevel;

  /// Optional price (for premium style)
  final String? price;

  /// Callback when unlock button is tapped
  final VoidCallback? onUnlockTap;

  /// Whether to show the blur effect
  final bool enableBlur;

  /// The blur intensity (sigma value)
  final double blurIntensity;

  /// Border radius to match parent container
  final double borderRadius;

  /// Custom icon to use
  final IconData? customIcon;

  const LockedOverlay({
    super.key,
    this.style = LockedOverlayStyle.standard,
    this.theme,
    this.message,
    this.subMessage,
    this.requiredLevel,
    this.price,
    this.onUnlockTap,
    this.enableBlur = true,
    this.blurIntensity = 3,
    this.borderRadius = 12,
    this.customIcon,
  });

  String _getMessage() {
    if (message != null) return message!;

    switch (style) {
      case LockedOverlayStyle.standard:
        return 'Locked';
      case LockedOverlayStyle.premium:
        return 'Premium Only';
      case LockedOverlayStyle.level:
        return requiredLevel != null ? 'Level $requiredLevel Required' : 'Level Up Required';
      case LockedOverlayStyle.comingSoon:
        return 'Coming Soon';
      case LockedOverlayStyle.maintenance:
        return 'Under Maintenance';
    }
  }

  String? _getSubMessage() {
    if (subMessage != null) return subMessage;

    switch (style) {
      case LockedOverlayStyle.premium:
        return price != null ? 'Unlock for $price' : 'Upgrade to unlock';
      case LockedOverlayStyle.level:
        return 'Keep playing to unlock';
      case LockedOverlayStyle.comingSoon:
        return 'Stay tuned!';
      case LockedOverlayStyle.maintenance:
        return 'Check back later';
      default:
        return null;
    }
  }

  IconData _getIcon() {
    if (customIcon != null) return customIcon!;

    switch (style) {
      case LockedOverlayStyle.standard:
        return Icons.lock_rounded;
      case LockedOverlayStyle.premium:
        return Icons.workspace_premium_rounded;
      case LockedOverlayStyle.level:
        return Icons.trending_up_rounded;
      case LockedOverlayStyle.comingSoon:
        return Icons.hourglass_empty_rounded;
      case LockedOverlayStyle.maintenance:
        return Icons.build_rounded;
    }
  }

  Color _getIconColor() {
    switch (style) {
      case LockedOverlayStyle.premium:
        return const Color(0xFFFFD700); // Gold
      case LockedOverlayStyle.comingSoon:
        return const Color(0xFF64B5F6); // Light blue
      case LockedOverlayStyle.maintenance:
        return const Color(0xFFFFB74D); // Orange
      default:
        return theme?.accentColor.withValues(alpha: 0.8) ?? Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = theme?.accentColor ?? Colors.white;

    Widget content = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.5),
            Colors.black.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with glow
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.3),
                border: Border.all(
                  color: _getIconColor().withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getIconColor().withValues(alpha: 0.3),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _getIcon(),
                size: 32,
                color: _getIconColor(),
              ),
            ),
            const SizedBox(height: 16),

            // Main message
            Text(
              _getMessage(),
              style: GameTypography.titleMedium(color: Colors.white),
              textAlign: TextAlign.center,
            ),

            // Sub message
            if (_getSubMessage() != null) ...[
              const SizedBox(height: 4),
              Text(
                _getSubMessage()!,
                style: GameTypography.bodySmall(
                  color: accentColor.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Unlock button for premium style
            if (style == LockedOverlayStyle.premium && onUnlockTap != null) ...[
              const SizedBox(height: 16),
              _UnlockButton(
                onTap: onUnlockTap!,
                label: price != null ? 'Unlock $price' : 'Unlock Now',
              ),
            ],
          ],
        ),
      ),
    );

    // Apply blur if enabled
    if (enableBlur) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurIntensity,
            sigmaY: blurIntensity,
          ),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Small unlock button for locked overlay
class _UnlockButton extends StatefulWidget {
  final VoidCallback onTap;
  final String label;

  const _UnlockButton({
    required this.onTap,
    required this.label,
  });

  @override
  State<_UnlockButton> createState() => _UnlockButtonState();
}

class _UnlockButtonState extends State<_UnlockButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const goldPrimary = Color(0xFFFFD700);
    const goldDark = Color(0xFFDAA520);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [goldPrimary, goldDark],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: goldPrimary.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_open_rounded,
                size: 16,
                color: Colors.black87,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: GameTypography.buttonSmall().copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact locked indicator for list items or small spaces
class LockedIndicator extends StatelessWidget {
  /// The size of the lock icon
  final double size;

  /// Whether to show just the icon or icon with background
  final bool showBackground;

  /// Optional tooltip message
  final String? tooltip;

  const LockedIndicator({
    super.key,
    this.size = 16,
    this.showBackground = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    Widget icon = Icon(
      Icons.lock_rounded,
      size: size,
      color: Colors.white54,
    );

    if (showBackground) {
      icon = Container(
        padding: EdgeInsets.all(size / 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white24,
            width: 1,
          ),
        ),
        child: icon,
      );
    }

    if (tooltip != null) {
      icon = Tooltip(
        message: tooltip!,
        child: icon,
      );
    }

    return icon;
  }
}

/// A "LOCKED" text badge for inline use
class LockedTextBadge extends StatelessWidget {
  /// Whether to use compact styling
  final bool compact;

  /// Custom text
  final String? text;

  const LockedTextBadge({
    super.key,
    this.compact = false,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(compact ? 4 : 6),
        border: Border.all(
          color: Colors.white24,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_rounded,
            size: compact ? 10 : 12,
            color: Colors.white54,
          ),
          SizedBox(width: compact ? 3 : 4),
          Text(
            text ?? 'LOCKED',
            style: (compact
                    ? GameTypography.labelSmall()
                    : GameTypography.labelMedium())
                .copyWith(
              color: Colors.white54,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

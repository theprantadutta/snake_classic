import 'package:flutter/material.dart';
import 'package:snake_classic/utils/typography.dart';

/// Size variants for premium badges
enum PremiumBadgeSize {
  /// Tiny badge for list items - 16px icon
  tiny(16, 4, 6),

  /// Small badge for cards - 20px icon
  small(20, 6, 8),

  /// Medium badge for headers - 24px icon
  medium(24, 8, 10),

  /// Large badge for featured content - 32px icon
  large(32, 12, 14);

  final double iconSize;
  final double horizontalPadding;
  final double verticalPadding;

  const PremiumBadgeSize(
    this.iconSize,
    this.horizontalPadding,
    this.verticalPadding,
  );
}

/// Style variants for premium badges
enum PremiumBadgeStyle {
  /// Gold badge with shimmer effect
  gold,

  /// Crown icon badge
  crown,

  /// Star badge
  star,

  /// Diamond badge for elite/VIP
  diamond,

  /// Simple text badge
  text,
}

/// An animated premium badge with shimmer effect
/// Shows premium/VIP status with eye-catching gold animations
class PremiumBadge extends StatefulWidget {
  /// The size of the badge
  final PremiumBadgeSize size;

  /// The style variant of the badge
  final PremiumBadgeStyle style;

  /// Optional label text (shown for text style or beside icon)
  final String? label;

  /// Whether to show the shimmer animation
  final bool enableShimmer;

  /// Whether to show the glow effect
  final bool enableGlow;

  /// Custom icon to use instead of default
  final IconData? customIcon;

  const PremiumBadge({
    super.key,
    this.size = PremiumBadgeSize.small,
    this.style = PremiumBadgeStyle.crown,
    this.label,
    this.enableShimmer = true,
    this.enableGlow = true,
    this.customIcon,
  });

  @override
  State<PremiumBadge> createState() => _PremiumBadgeState();
}

class _PremiumBadgeState extends State<PremiumBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  // Premium gold colors
  static const Color _goldPrimary = Color(0xFFFFD700);
  static const Color _goldLight = Color(0xFFFFF8DC);
  static const Color _goldDark = Color(0xFFDAA520);
  static const Color _diamondBlue = Color(0xFF87CEEB);
  static const Color _diamondLight = Color(0xFFE0FFFF);

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    if (widget.enableShimmer) {
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PremiumBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enableShimmer && !_shimmerController.isAnimating) {
      _shimmerController.repeat();
    } else if (!widget.enableShimmer && _shimmerController.isAnimating) {
      _shimmerController.stop();
    }
  }

  IconData _getIcon() {
    if (widget.customIcon != null) return widget.customIcon!;

    switch (widget.style) {
      case PremiumBadgeStyle.gold:
        return Icons.workspace_premium;
      case PremiumBadgeStyle.crown:
        return Icons.emoji_events;
      case PremiumBadgeStyle.star:
        return Icons.star;
      case PremiumBadgeStyle.diamond:
        return Icons.diamond;
      case PremiumBadgeStyle.text:
        return Icons.verified;
    }
  }

  Color _getPrimaryColor() {
    switch (widget.style) {
      case PremiumBadgeStyle.diamond:
        return _diamondBlue;
      default:
        return _goldPrimary;
    }
  }

  Color _getLightColor() {
    switch (widget.style) {
      case PremiumBadgeStyle.diamond:
        return _diamondLight;
      default:
        return _goldLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _getPrimaryColor();
    final lightColor = _getLightColor();

    Widget badge = AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.size.horizontalPadding,
            vertical: widget.size.verticalPadding - 2,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor.withValues(alpha: 0.3),
                _goldDark.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(widget.size.iconSize / 2 + 4),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.6),
              width: 1,
            ),
            boxShadow: widget.enableGlow
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (bounds) {
                  if (!widget.enableShimmer) {
                    return LinearGradient(
                      colors: [primaryColor, primaryColor],
                    ).createShader(bounds);
                  }
                  return LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor,
                      lightColor,
                      primaryColor,
                    ],
                    stops: [
                      (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                      _shimmerAnimation.value.clamp(0.0, 1.0),
                      (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                    ],
                  ).createShader(bounds);
                },
                child: Icon(
                  _getIcon(),
                  size: widget.size.iconSize,
                  color: Colors.white,
                ),
              ),
              if (widget.label != null) ...[
                SizedBox(width: widget.size.horizontalPadding / 2),
                ShaderMask(
                  shaderCallback: (bounds) {
                    if (!widget.enableShimmer) {
                      return LinearGradient(
                        colors: [primaryColor, primaryColor],
                      ).createShader(bounds);
                    }
                    return LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor,
                        lightColor,
                        primaryColor,
                      ],
                      stops: [
                        (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                        _shimmerAnimation.value.clamp(0.0, 1.0),
                        (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                      ],
                    ).createShader(bounds);
                  },
                  child: Text(
                    widget.label!,
                    style: _getLabelStyle().copyWith(color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );

    return badge;
  }

  TextStyle _getLabelStyle() {
    switch (widget.size) {
      case PremiumBadgeSize.tiny:
        return GameTypography.labelSmall();
      case PremiumBadgeSize.small:
        return GameTypography.labelMedium();
      case PremiumBadgeSize.medium:
        return GameTypography.labelLarge();
      case PremiumBadgeSize.large:
        return GameTypography.titleSmall();
    }
  }
}

/// A simple inline premium indicator (just the icon)
class PremiumIcon extends StatelessWidget {
  /// The size of the icon
  final double size;

  /// The color of the icon
  final Color? color;

  /// Whether to show the glow effect
  final bool enableGlow;

  const PremiumIcon({
    super.key,
    this.size = 16,
    this.color,
    this.enableGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? const Color(0xFFFFD700);

    Widget icon = Icon(
      Icons.workspace_premium,
      size: size,
      color: iconColor,
    );

    if (enableGlow) {
      icon = Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: iconColor.withValues(alpha: 0.5),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: icon,
      );
    }

    return icon;
  }
}

/// A "PRO" or "PREMIUM" text badge
class PremiumTextBadge extends StatelessWidget {
  /// The text to display
  final String text;

  /// Whether to use compact styling
  final bool compact;

  const PremiumTextBadge({
    super.key,
    this.text = 'PRO',
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    const goldPrimary = Color(0xFFFFD700);
    const goldDark = Color(0xFFDAA520);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [goldPrimary, goldDark],
        ),
        borderRadius: BorderRadius.circular(compact ? 4 : 6),
        boxShadow: [
          BoxShadow(
            color: goldPrimary.withValues(alpha: 0.4),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Text(
        text,
        style: (compact ? GameTypography.labelSmall() : GameTypography.labelMedium())
            .copyWith(
          color: Colors.black87,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

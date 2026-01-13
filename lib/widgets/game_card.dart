import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:snake_classic/utils/constants.dart';

/// Visual style variants for GameCard
enum GameCardStyle {
  /// Standard card with theme gradient
  standard,

  /// Premium/gold styled card with amber glow
  premium,

  /// Achievement card with purple accents
  achievement,

  /// Locked/disabled card with muted colors
  locked,

  /// Highlighted card with strong glow effect
  highlighted,

  /// Minimal card with subtle styling
  minimal,
}

/// A reusable card component with multiple style variants
/// Provides consistent styling across the app with theme integration
class GameCard extends StatelessWidget {
  /// The child widget to display inside the card
  final Widget child;

  /// The current game theme for color coordination
  final GameTheme theme;

  /// The visual style variant of the card
  final GameCardStyle style;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Whether to enable glassmorphism blur effect
  final bool enableGlassmorphism;

  /// Border radius of the card
  final double borderRadius;

  /// Padding inside the card
  final EdgeInsets padding;

  /// Margin around the card
  final EdgeInsets margin;

  /// Custom shadows (overrides style defaults)
  final List<BoxShadow>? customShadows;

  /// Custom border color (overrides style defaults)
  final Color? borderColor;

  /// Custom border width (overrides style defaults)
  final double? borderWidth;

  const GameCard({
    super.key,
    required this.child,
    required this.theme,
    this.style = GameCardStyle.standard,
    this.onTap,
    this.enableGlassmorphism = false,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.customShadows,
    this.borderColor,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = _buildDecoration();

    Widget cardContent = Container(
      padding: padding,
      decoration: decoration,
      child: child,
    );

    // Apply glassmorphism if enabled
    if (enableGlassmorphism && style != GameCardStyle.locked) {
      cardContent = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: cardContent,
        ),
      );
    }

    // Wrap with margin
    if (margin != EdgeInsets.zero) {
      cardContent = Padding(
        padding: margin,
        child: cardContent,
      );
    }

    // Wrap with gesture detector if onTap provided
    if (onTap != null) {
      cardContent = _TappableCard(
        onTap: onTap!,
        borderRadius: borderRadius,
        child: cardContent,
      );
    }

    return cardContent;
  }

  BoxDecoration _buildDecoration() {
    switch (style) {
      case GameCardStyle.standard:
        return _standardDecoration();
      case GameCardStyle.premium:
        return _premiumDecoration();
      case GameCardStyle.achievement:
        return _achievementDecoration();
      case GameCardStyle.locked:
        return _lockedDecoration();
      case GameCardStyle.highlighted:
        return _highlightedDecoration();
      case GameCardStyle.minimal:
        return _minimalDecoration();
    }
  }

  BoxDecoration _standardDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.accentColor.withValues(alpha: enableGlassmorphism ? 0.12 : 0.15),
          theme.accentColor.withValues(alpha: enableGlassmorphism ? 0.05 : 0.08),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? theme.accentColor.withValues(alpha: 0.2),
        width: borderWidth ?? 1,
      ),
      boxShadow: customShadows ??
          [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
    );
  }

  BoxDecoration _premiumDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.amber.withValues(alpha: 0.2),
          Colors.orange.withValues(alpha: 0.1),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? Colors.amber.withValues(alpha: 0.4),
        width: borderWidth ?? 1.5,
      ),
      boxShadow: customShadows ??
          [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.2),
              blurRadius: 12,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
    );
  }

  BoxDecoration _achievementDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.purple.withValues(alpha: 0.15),
          Colors.indigo.withValues(alpha: 0.08),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? Colors.purple.withValues(alpha: 0.3),
        width: borderWidth ?? 1.5,
      ),
      boxShadow: customShadows ??
          [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.15),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
    );
  }

  BoxDecoration _lockedDecoration() {
    return BoxDecoration(
      color: theme.backgroundColor.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? theme.accentColor.withValues(alpha: 0.1),
        width: borderWidth ?? 1,
      ),
    );
  }

  BoxDecoration _highlightedDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.foodColor.withValues(alpha: 0.2),
          theme.accentColor.withValues(alpha: 0.1),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? theme.foodColor.withValues(alpha: 0.5),
        width: borderWidth ?? 2,
      ),
      boxShadow: customShadows ??
          [
            BoxShadow(
              color: theme.foodColor.withValues(alpha: 0.3),
              blurRadius: 16,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
    );
  }

  BoxDecoration _minimalDecoration() {
    return BoxDecoration(
      color: theme.accentColor.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? theme.accentColor.withValues(alpha: 0.1),
        width: borderWidth ?? 1,
      ),
    );
  }
}

/// Internal widget for tap animation
class _TappableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double borderRadius;

  const _TappableCard({
    required this.child,
    required this.onTap,
    required this.borderRadius,
  });

  @override
  State<_TappableCard> createState() => _TappableCardState();
}

class _TappableCardState extends State<_TappableCard>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// A variant of GameCard specifically for list items
class GameListCard extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final GameTheme theme;
  final GameCardStyle style;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final EdgeInsets margin;

  const GameListCard({
    super.key,
    required this.leading,
    required this.title,
    required this.theme,
    this.subtitle,
    this.trailing,
    this.style = GameCardStyle.standard,
    this.onTap,
    this.padding = const EdgeInsets.all(12),
    this.margin = const EdgeInsets.symmetric(vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    return GameCard(
      theme: theme,
      style: style,
      onTap: onTap,
      padding: padding,
      margin: margin,
      borderRadius: 12,
      child: Row(
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                title,
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  subtitle!,
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

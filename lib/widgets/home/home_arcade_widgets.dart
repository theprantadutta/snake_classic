import 'package:flutter/material.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/typography.dart';

/// The small panels down the left of the arcade home screen.
///
/// One fact each, in the shape the runners use: a framed icon, a quiet label,
/// and the number underneath it in the theme's accent. They are readouts, not
/// buttons, unless [onTap] is given.
class HomeStatPanel extends StatelessWidget {
  const HomeStatPanel({
    super.key,
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.onTap,
    this.compact = false,
  });

  final GameTheme theme;
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tint = iconColor ?? theme.accentColor;
    final panel = Container(
      padding: EdgeInsets.fromLTRB(
        compact ? 6 : 8,
        compact ? 6 : 7,
        compact ? 10 : 14,
        compact ? 6 : 7,
      ),
      decoration: BoxDecoration(
        color: Color.lerp(
          theme.backgroundColor,
          Colors.black,
          0.25,
        )!.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.accentColor.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 32 : 38,
            height: compact ? 32 : 38,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: tint.withValues(alpha: 0.35)),
            ),
            child: Icon(icon, color: tint, size: compact ? 18 : 21),
          ),
          SizedBox(width: compact ? 8 : 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                maxLines: 1,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: compact ? 8.5 : 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: context.letterSpacing(1.2),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                maxLines: 1,
                style: TextStyle(
                  color: tint,
                  fontSize: compact ? 15 : 17,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (onTap == null) return panel;
    return Semantics(
      button: true,
      label: '$label: $value',
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: panel,
      ),
    );
  }
}

/// The offers and rewards rail down the right.
///
/// Loud on purpose — this is the one place on the arcade layout allowed to
/// shout, because it is where the free thing lives.
class HomeRailButton extends StatelessWidget {
  const HomeRailButton({
    super.key,
    required this.theme,
    required this.icon,
    required this.label,
    required this.onTap,
    this.tint,
    this.subtitle,
    this.badgeCount = 0,
    this.highlight = false,
  });

  final GameTheme theme;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? tint;

  /// A countdown or a hint under the label, when there is one.
  final String? subtitle;
  final int badgeCount;

  /// Filled rather than outlined. Reserve it for the rewarded slot.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final colour = tint ?? theme.accentColor;

    return Semantics(
      button: true,
      label: subtitle == null ? label : '$label, $subtitle',
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              constraints: const BoxConstraints(minWidth: 96, minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: highlight
                    ? LinearGradient(
                        colors: [
                          colour.withValues(alpha: 0.85),
                          colour.withValues(alpha: 0.55),
                        ],
                      )
                    : null,
                color: highlight
                    ? null
                    : Color.lerp(
                        theme.backgroundColor,
                        Colors.black,
                        0.25,
                      )!.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colour.withValues(alpha: highlight ? 0.9 : 0.35),
                  width: highlight ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: highlight ? Colors.white : colour,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label.toUpperCase(),
                        maxLines: 1,
                        style: TextStyle(
                          color: highlight ? Colors.white : colour,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: context.letterSpacing(1),
                          height: 1.1,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          style: TextStyle(
                            color: (highlight ? Colors.white : colour)
                                .withValues(alpha: 0.75),
                            fontSize: 9.5,
                            height: 1.2,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (badgeCount > 0)
              Positioned(top: -6, right: -6, child: CountBadge(badgeCount)),
          ],
        ),
      ),
    );
  }
}

/// The red dot with a number in it. Universal arcade shorthand for "there is
/// something here for you", and the reason those screens get opened.
class CountBadge extends StatelessWidget {
  const CountBadge(this.count, {super.key, this.size = 20});

  final int count;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE53935),
        borderRadius: BorderRadius.circular(size),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.85),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : '$count',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.55,
          fontWeight: FontWeight.w900,
          height: 1.0,
        ),
      ),
    );
  }
}

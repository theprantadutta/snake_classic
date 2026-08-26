import 'package:flutter/material.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/screen_shell.dart';
import 'package:snake_classic/utils/typography.dart';
import 'package:snake_classic/widgets/home/home_arcade_widgets.dart';

/// One destination in the arcade bar.
class ArcadeDestination {
  const ArcadeDestination({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badgeCount = 0,
    this.widgetKey,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int badgeCount;
  final Key? widgetKey;
}

/// Four quiet buttons across the bottom, replacing the eight-tile grid.
///
/// The grid gave every destination the same weight and the same shout: eight
/// tiles in eight hues, two rows deep, louder than the play button above them.
/// Four is what fits a thumb.
///
/// They are deliberately plain and deliberately identical — one translucent
/// panel, one hairline border, the theme's accent on the glyph — because a
/// row of navigation is not the point of this screen and should not be drawn
/// as though it were. The glyph and the word are the only things that differ
/// between them, which is all that needs to.
class HomeArcadeBar extends StatelessWidget {
  const HomeArcadeBar({
    super.key,
    required this.theme,
    required this.destinations,
    this.compact = false,
  });

  final GameTheme theme;
  final List<ArcadeDestination> destinations;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final destination in destinations) ...[
          Expanded(child: _button(context, destination)),
          if (destination != destinations.last)
            SizedBox(width: compact ? 6 : 8),
        ],
      ],
    );
  }

  Widget _button(BuildContext context, ArcadeDestination destination) {
    return Semantics(
      button: true,
      label: destination.badgeCount > 0
          ? '${destination.label}, ${destination.badgeCount}'
          : destination.label,
      onTap: destination.onTap,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: destination.onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              key: destination.widgetKey,
              width: double.infinity,
              height: compact ? 62 : 70,
              decoration: arcadeSurface(
                theme,
                borderRadius: BorderRadius.circular(14),
                borderColor: theme.accentColor.withValues(alpha: 0.40),
              ),
              child: HudCorners(
                color: theme.accentColor,
                // NEGATIVE inset, so these sit INSIDE the chip rather than
                // outside it. The rail chips can afford to be framed from
                // without — they have clear space around them. These four
                // sit shoulder to shoulder, and drawn outward their arms
                // reached across the gaps into each other, which reads as
                // one broken frame rather than four tidy ones. A
                // destination has no padding of its own to hide them in,
                // so they go inward.
                inset: compact ? -6 : -7,
                arm: compact ? 7 : 9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      destination.icon,
                      color: theme.accentColor,
                      size: compact ? 21 : 24,
                    ),
                    SizedBox(height: compact ? 5 : 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        destination.label.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: compact ? 9.5 : 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: context.letterSpacing(0.8),
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (destination.badgeCount > 0)
              Positioned(
                top: -6,
                right: -4,
                child: CountBadge(destination.badgeCount),
              ),
          ],
        ),
      ),
    );
  }
}

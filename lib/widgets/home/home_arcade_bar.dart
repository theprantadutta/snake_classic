import 'package:flutter/material.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/typography.dart';
import 'package:snake_classic/widgets/home/home_arcade_widgets.dart';

/// One destination in the arcade bar.
class ArcadeDestination {
  const ArcadeDestination({
    required this.icon,
    required this.label,
    required this.tint,
    required this.onTap,
    this.badgeCount = 0,
    this.widgetKey,
  });

  final IconData icon;
  final String label;
  final Color tint;
  final VoidCallback onTap;
  final int badgeCount;
  final Key? widgetKey;
}

/// Four big buttons across the bottom, replacing the eight-tile grid.
///
/// The grid gave every destination the same weight and the same shout: eight
/// tiles in eight hues, two rows deep, louder than the play button above them.
/// Four is what fits a thumb, and the runners settled on four for the same
/// reason. Everything the grid used to reach is still reachable — the four
/// here are the ones worth a permanent slot, and the rest live behind them.
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
              // Full width of its Expanded slot. Without this the Container
              // sizes to the icon and label inside it and the bar renders as
              // four narrow pills adrift in their own gaps.
              width: double.infinity,
              height: compact ? 62 : 72,
              decoration: BoxDecoration(
                // Themed, not eight different hues: the tint only colours the
                // glyph and the edge, so the bar reads as one control strip.
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    destination.tint.withValues(alpha: 0.22),
                    Color.lerp(
                      theme.backgroundColor,
                      Colors.black,
                      0.3,
                    )!.withValues(alpha: 0.75),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: destination.tint.withValues(alpha: 0.45),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    destination.icon,
                    color: destination.tint,
                    size: compact ? 22 : 26,
                  ),
                  SizedBox(height: compact ? 3 : 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      destination.label.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: compact ? 9.5 : 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: context.letterSpacing(0.8),
                        height: 1.0,
                      ),
                    ),
                  ),
                ],
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

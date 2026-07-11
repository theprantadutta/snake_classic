import 'package:flutter/material.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/utils/responsive.dart';
import 'package:snake_classic/widgets/dpad_controls.dart';

/// The D-Pad control bar with stats on either side
/// Layout: [Length] [D-Pad] [Speed]
/// The bottom bar reserves a fixed footprint regardless of whether the
/// D-Pad is enabled or the current game status. Previous build had two
/// completely separate widgets here (a tall D-Pad bar vs a short compact-
/// stats footer) and switched between them based on
/// `dPadEnabled && status == playing`, which caused:
///   - The board to shift up/down whenever the D-Pad setting toggled.
///   - The D-Pad to vanish entirely the moment the snake crashed,
///     because status went from playing → crashed.
///
/// Now we always render the same Row skeleton (left stat / center / right
/// stat) at a fixed height. The center swaps:
///   - dPadEnabled = true  → DPadControls, interactive while playing,
///     dimmed + non-interactive otherwise.
///   - dPadEnabled = false → a single Level stat card centered in the
///     same footprint.
class GameBottomBar extends StatelessWidget {
  const GameBottomBar({
    super.key,
    required this.gameState,
    required this.theme,
    required this.isSmallScreen,
    required this.dPadEnabled,
    required this.onDirection,
  });

  final GameState gameState;
  final GameTheme theme;
  final bool isSmallScreen;
  final bool dPadEnabled;
  final void Function(Direction) onDirection;

  // Convert game speed (ms per tick) to human-readable label
  String _getSpeedLabel(int gameSpeed) {
    if (gameSpeed >= 280) return 'Normal';
    if (gameSpeed >= 230) return 'Fast';
    if (gameSpeed >= 180) return 'Faster';
    if (gameSpeed >= 130) return 'Blazing';
    if (gameSpeed >= 80) return 'Insane';
    return 'MAX';
  }

  // Get icon for current speed level
  IconData _getSpeedIcon(int gameSpeed) {
    if (gameSpeed >= 230) return Icons.speed;
    if (gameSpeed >= 130) return Icons.local_fire_department;
    return Icons.bolt;
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;
    // Small-screen size bumped 115 -> 120 so the 0.38-ratio d-pad
    // buttons clear ~46px touch targets. Bar height grows uniformly
    // across all states, so the no-reflow contract holds.
    final dpadSize = (isSmallScreen ? 120.0 : 135.0) * scale;
    final verticalPadding = (isSmallScreen ? 8.0 : 12.0) * scale;
    // Total reserved height = dpad footprint + the row's own padding so the
    // box is the SAME pixel height in every branch and every status.
    final barHeight = dpadSize + verticalPadding * 2;
    final isInteractive = gameState.status == GameStatus.playing;

    return SizedBox(
      height: barHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 12 * scale,
          vertical: verticalPadding,
        ),
        child: dPadEnabled
            // D-Pad on: center reserves the dpadSize square, side stats
            // shrink to fit the remaining columns. Compact cards aligned
            // to the outer edges so the d-pad has breathing room.
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildControlBarStat(
                      'Length',
                      '${gameState.snake.length}',
                      Icons.straighten,
                      theme,
                      isSmallScreen,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      width: dpadSize,
                      height: dpadSize,
                      child: Opacity(
                        opacity: isInteractive ? 1.0 : 0.45,
                        child: IgnorePointer(
                          ignoring: !isInteractive,
                          child: DPadControls(
                            onDirection: onDirection,
                            theme: theme,
                            opacity: 0.8,
                            size: dpadSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildControlBarStat(
                      'Speed',
                      _getSpeedLabel(gameState.gameSpeed),
                      _getSpeedIcon(gameState.gameSpeed),
                      theme,
                      isSmallScreen,
                      alignment: Alignment.centerRight,
                    ),
                  ),
                ],
              )
            // D-Pad off: no center widget eats the middle, so the three
            // stats spread across the full row in even thirds. Each card
            // is normal-size — wider, not taller — and vertically
            // centered in the same-height bar.
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildWideStat(
                      'Length',
                      '${gameState.snake.length}',
                      Icons.straighten,
                      theme,
                      isSmallScreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildWideStat(
                      'Level',
                      '${gameState.level}',
                      Icons.trending_up,
                      theme,
                      isSmallScreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildWideStat(
                      'Speed',
                      _getSpeedLabel(gameState.gameSpeed),
                      _getSpeedIcon(gameState.gameSpeed),
                      theme,
                      isSmallScreen,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Stat card used when the D-Pad is disabled — fills its 1/3 of the
  /// bottom bar's width but only takes the height it needs. Normal text
  /// sizes; the extra space we won is horizontal, not vertical.
  Widget _buildWideStat(
    String label,
    String value,
    IconData icon,
    GameTheme theme,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 10 : 12,
        vertical: isSmallScreen ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.6),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.25),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: theme.accentColor.withValues(alpha: 0.7),
            size: isSmallScreen ? 16 : 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.accentColor,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: theme.accentColor.withValues(alpha: 0.5),
              fontSize: isSmallScreen ? 9 : 10,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a stat display for the control bar
  Widget _buildControlBarStat(
    String label,
    String value,
    IconData icon,
    GameTheme theme,
    bool isSmallScreen, {
    required Alignment alignment,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 10 : 14,
          vertical: isSmallScreen ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: theme.backgroundColor.withValues(alpha: 0.6),
          border: Border.all(color: theme.accentColor.withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: theme.accentColor.withValues(alpha: 0.7),
              size: isSmallScreen ? 16 : 20,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: theme.accentColor,
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.5),
                fontSize: isSmallScreen ? 9 : 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

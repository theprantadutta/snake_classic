import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/utils/responsive.dart';
import 'package:snake_classic/widgets/dpad_controls.dart';

/// The bar under the board. Two shapes, one per control mode:
///
///   - dPadEnabled = true  → [Length] [D-Pad] [Speed] at the full d-pad
///     footprint. The d-pad is interactive while playing and dimmed +
///     non-interactive otherwise, rather than being swapped out — an earlier
///     build rendered a completely different widget once status went
///     playing → crashed, which made the d-pad vanish and the board jump at
///     the worst possible moment.
///   - dPadEnabled = false → a slim inline strip of length + speed, sized to
///     its own content so the board keeps the height a d-pad would have
///     needed. Level is not repeated here; the HUD above already carries it.
///
/// The height is constant for the duration of a run in both modes (the mode
/// is a settings toggle and cannot change mid-game), so the board never
/// reflows while the player is steering — which is the property that matters.
class GameBottomBar extends StatelessWidget {
  const GameBottomBar({
    super.key,
    required this.gameState,
    required this.theme,
    required this.isSmallScreen,
    required this.dPadEnabled,
    required this.onDirection,
    this.dPadPosition = DPadPosition.bottomCenter,
  });

  final GameState gameState;
  final GameTheme theme;
  final bool isSmallScreen;
  final bool dPadEnabled;
  final void Function(Direction) onDirection;

  /// Where the player asked for the d-pad, from settings.
  ///
  /// The preference was stored, synced and offered in Settings, and then
  /// ignored by every gameplay screen — a visible promise that did nothing.
  /// Centre stays the default, and existing saved values start working as-is;
  /// nothing about them needed migrating.
  final DPadPosition dPadPosition;

  // Convert game speed (ms per tick) to human-readable label
  String _getSpeedLabel(AppLocalizations l10n, int gameSpeed) {
    if (gameSpeed >= 280) return l10n.gbSpeedNormal;
    if (gameSpeed >= 230) return l10n.gbSpeedFast;
    if (gameSpeed >= 180) return l10n.gbSpeedFaster;
    if (gameSpeed >= 130) return l10n.gbSpeedBlazing;
    if (gameSpeed >= 80) return l10n.gbSpeedInsane;
    return l10n.gbSpeedMax;
  }

  // Get icon for current speed level
  IconData _getSpeedIcon(int gameSpeed) {
    if (gameSpeed >= 230) return Icons.speed;
    if (gameSpeed >= 130) return Icons.local_fire_department;
    return Icons.bolt;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scale = context.uiScale;
    // Small-screen size bumped 115 -> 120 so the 0.38-ratio d-pad
    // buttons clear ~46px touch targets. Bar height grows uniformly
    // across all states, so the no-reflow contract holds.
    final dpadSize = (isSmallScreen ? 120.0 : 135.0) * scale;
    final verticalPadding = (isSmallScreen ? 8.0 : 12.0) * scale;

    // Height is sized to what the bar actually contains.
    //
    // It used to reserve the full d-pad footprint in BOTH modes, so a swipe
    // player gave up ~150dp — a fifth of the screen on a tall phone — to three
    // read-only stat cards, two of which (level, and the length that is
    // visible on the board anyway) are already shown in the HUD above. That
    // space belongs to the board: this is a game whose entire content is the
    // playfield, and it was rendering at roughly 40% of the screen.
    //
    // The no-reflow contract that motivated the fixed height still holds. What
    // it protects against is the board jumping DURING a run — when the status
    // goes playing → crashed, or the d-pad dims. `dPadEnabled` is a settings
    // toggle that cannot change mid-game, so branching the height on it is
    // constant for the whole run in either mode.
    final statsBarHeight = (isSmallScreen ? 40.0 : 46.0) * scale;
    final barHeight =
        dPadEnabled ? dpadSize + verticalPadding * 2 : statsBarHeight;
    final isInteractive = gameState.status == GameStatus.playing;

    return SizedBox(
      height: barHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 12 * scale,
          vertical: dPadEnabled ? verticalPadding : 4 * scale,
        ),
        child: dPadEnabled
            // D-Pad on: center reserves the dpadSize square, side stats
            // shrink to fit the remaining columns. Compact cards aligned
            // to the outer edges so the d-pad has breathing room.
            ? _buildDPadRow(
                context,
                l10n: l10n,
                dpadSize: dpadSize,
                isInteractive: isInteractive,
              )
            // D-Pad off: one slim inline strip instead of three stacked
            // cards.
            //
            // Level is deliberately NOT here. It is already the LV pill and
            // the progress bar in the HUD directly above, so showing it a
            // third time cost a fifth of the screen to repeat something the
            // player had just read. Length and speed stay because neither is
            // stated elsewhere — but as quiet inline chips, not as headline
            // cards competing with the board.
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildInlineStat(
                    '${gameState.snake.length}',
                    Icons.straighten,
                    theme,
                    isSmallScreen,
                  ),
                  SizedBox(width: 20 * scale),
                  _buildInlineStat(
                    _getSpeedLabel(l10n, gameState.gameSpeed),
                    _getSpeedIcon(gameState.gameSpeed),
                    theme,
                    isSmallScreen,
                  ),
                ],
              ),
      ),
    );
  }

  /// Single-line stat for the swipe-mode strip: icon and value side by side,
  /// no stacked label. Sized to sit in a ~44dp bar rather than an ~80dp card,
  /// which is where the board's reclaimed height comes from.
  Widget _buildInlineStat(
    String value,
    IconData icon,
    GameTheme theme,
    bool isSmallScreen,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: theme.accentColor.withValues(alpha: 0.55),
          size: isSmallScreen ? 14 : 16,
        ),
        const SizedBox(width: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: theme.accentColor.withValues(alpha: 0.75),
            fontWeight: FontWeight.w600,
            fontSize: isSmallScreen ? 12 : 13,
          ),
        ),
      ],
    );
  }

  /// Builds a stat display for the control bar
  /// Lay the lower bar out around the player's chosen d-pad position.
  ///
  /// Ordering inside the existing row, deliberately — not an overlay floated
  /// over the board. The board's geometry must not change with this setting,
  /// and a left-handed player should get a left-hand d-pad without giving up
  /// any playfield.
  ///
  /// Centre keeps the original [stat] [d-pad] [stat] shape. Left and right
  /// move the d-pad to that edge and put both stats together on the other
  /// side, which keeps the thumb's half of the bar clear of anything it might
  /// brush past on the way to a turn.
  Widget _buildDPadRow(
    BuildContext context, {
    required AppLocalizations l10n,
    required double dpadSize,
    required bool isInteractive,
  }) {
    final dPad = Padding(
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
    );

    Widget lengthStat(Alignment alignment) => _buildControlBarStat(
          l10n.gbLength,
          '${gameState.snake.length}',
          Icons.straighten,
          theme,
          isSmallScreen,
          alignment: alignment,
        );

    Widget speedStat(Alignment alignment) => _buildControlBarStat(
          l10n.gbSpeed,
          _getSpeedLabel(l10n, gameState.gameSpeed),
          _getSpeedIcon(gameState.gameSpeed),
          theme,
          isSmallScreen,
          alignment: alignment,
        );

    switch (dPadPosition) {
      case DPadPosition.bottomLeft:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            dPad,
            Expanded(child: lengthStat(Alignment.centerRight)),
            Expanded(child: speedStat(Alignment.centerRight)),
          ],
        );
      case DPadPosition.bottomRight:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: lengthStat(Alignment.centerLeft)),
            Expanded(child: speedStat(Alignment.centerLeft)),
            dPad,
          ],
        );
      case DPadPosition.bottomCenter:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: lengthStat(Alignment.centerLeft)),
            dPad,
            Expanded(child: speedStat(Alignment.centerRight)),
          ],
        );
    }
  }

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

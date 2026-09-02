import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/utils/responsive.dart';
import 'package:snake_classic/widgets/dpad_row_layout.dart';
import 'package:snake_classic/widgets/steerable_dpad.dart';
import 'package:snake_classic/widgets/turn_buttons.dart';

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
    this.controlLayout = ControlLayout.dPad,
    this.onRelativeTurn,
    this.canSteerOverride,
  });

  final GameState gameState;
  final GameTheme theme;
  final bool isSmallScreen;
  final bool dPadEnabled;
  final void Function(Direction) onDirection;

  /// Forces the d-pad's usable state instead of deriving it from the game
  /// status. Only the game tutorial sets it: it pauses the game and then asks
  /// for a turn, so the control has to work while the status says paused.
  /// Null everywhere else, which keeps the ordinary rule.
  final bool? canSteerOverride;

  /// Where the player asked for the d-pad, from settings.
  ///
  /// The preference was stored, synced and offered in Settings, and then
  /// ignored by every gameplay screen — a visible promise that did nothing.
  /// Centre stays the default, and existing saved values start working as-is;
  /// nothing about them needed migrating.
  final DPadPosition dPadPosition;

  /// Which on-screen control [dPadEnabled] draws. Turn buttons need
  /// [onRelativeTurn]; without it the bar falls back to the d-pad.
  final ControlLayout controlLayout;
  final void Function(RelativeTurn)? onRelativeTurn;

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
    final barHeight = dPadEnabled
        ? dpadSize + verticalPadding * 2
        : statsBarHeight;
    // Normally "you may steer" means "the game is running". The tutorial is
    // the one exception: it deliberately pauses the game and then asks the
    // player to turn, so it passes true and the control stays live.
    final isInteractive =
        canSteerOverride ?? gameState.status == GameStatus.playing;

    return SizedBox(
      height: barHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 12 * scale,
          vertical: dPadEnabled ? verticalPadding : 4 * scale,
        ),
        child: dPadEnabled
            // On-screen controls on. Turn buttons take both ends of the
            // bar with the readouts between them; the d-pad reserves its
            // square and the side stats shrink to the remaining columns.
            ? (controlLayout == ControlLayout.turnButtons &&
                      onRelativeTurn != null
                  ? _buildTurnButtonsRow(
                      l10n: l10n,
                      height: dpadSize,
                      isInteractive: isInteractive,
                    )
                  : _buildDPadRow(
                      context,
                      l10n: l10n,
                      dpadSize: dpadSize,
                      isInteractive: isInteractive,
                    ))
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
  /// Turn buttons fill both ends of the bar; the readouts sit between
  /// them, stacked, so the buttons keep the full bar height.
  Widget _buildTurnButtonsRow({
    required AppLocalizations l10n,
    required double height,
    required bool isInteractive,
  }) {
    return SteerableTurnButtons(
      onTurn: onRelativeTurn!,
      theme: theme,
      height: height,
      canSteer: isInteractive,
      centre: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInlineStat(
              '${gameState.snake.length}',
              Icons.straighten,
              theme,
              isSmallScreen,
            ),
            const SizedBox(height: 8),
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

  Widget _buildDPadRow(
    BuildContext context, {
    required AppLocalizations l10n,
    required double dpadSize,
    required bool isInteractive,
  }) {
    final dPad = SteerableDPad(
      onDirection: onDirection,
      theme: theme,
      size: dpadSize,
      canSteer: isInteractive,
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

    return DPadRowLayout.build(
      position: dPadPosition,
      dPad: dPad,
      leading: lengthStat,
      trailing: speedStat,
    );
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
        // A three-line readout in a row whose height is set by the d-pad
        // beside it. At a 2.0 text scale the labels alone were 90px taller
        // than the space they had. Accessibility text scaling is honoured up
        // to a point and then the whole chip shrinks to fit rather than
        // painting over the board — the number stays legible either way, and
        // the row height (and therefore the board) never moves.
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: FittedBox(
            fit: BoxFit.scaleDown,
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
        ),
      ),
    );
  }
}

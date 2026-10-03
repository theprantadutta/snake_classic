import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/catalog_l10n.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/models/tournament.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// Gameplay top bar (Living Board screens 04–05): `LV n` on the left, the
/// combo chip in the middle (or the tournament badge when there is no
/// combo), the pause block on the right.
class LBGameTopBar extends StatelessWidget {
  const LBGameTopBar({
    super.key,
    required this.gameState,
    required this.onPause,
    this.pauseButtonKey,
    this.tournamentMode,
  });

  final GameState gameState;
  final VoidCallback onPause;
  final Key? pauseButtonKey;
  final TournamentGameMode? tournamentMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final cell = context.lbCell;
    final playing = gameState.status == GameStatus.playing;
    return SizedBox(
      height: cell * 2.4,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.lbGutter),
        child: Row(
          children: [
            SizedBox(
              width: cell * 3.5,
              child: Semantics(
                liveRegion: true,
                label: '${l10n.lbLevelShort('${gameState.level}')}, '
                    '${l10n.lbScoreLabel} ${gameState.score}',
                excludeSemantics: true,
                child: Text(
                  l10n.lbLevelShort('${gameState.level}'),
                  maxLines: 1,
                  style: LBText.button(p, color: p.lime, size: 14).copyWith(letterSpacing: 2),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: gameState.currentCombo >= 2
                    ? LBComboChip(gameState: gameState)
                    : tournamentMode != null
                        ? LBChip(
                            label: '${l10n.hudTournamentBadge} · '
                                '${tournamentMode!.localizedName(l10n).toUpperCase()}',
                            kind: LBChipKind.gold,
                            icon: LBIcon.trophy,
                            height: 26,
                          )
                        : const SizedBox.shrink(),
              ),
            ),
            SizedBox(
              width: cell * 3.5,
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: KeyedSubtree(
                  key: pauseButtonKey,
                  child: LBIconBlock(
                    icon: playing ? LBIcon.pause : LBIcon.play,
                    semanticLabel: playing ? l10n.gamePauseGame : l10n.gameResumeGame,
                    size: cell * 2,
                    // Looks 2 cells; takes taps across the 48 dp minimum.
                    minHitSize: 48,
                    onTap: onPause,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The combo chip with its decay warning: `×3 HOT · KEEP EATING`, turning
/// red with `EAT SOMETHING. NOW.` in the last 1.5 s before the streak
/// breaks. Pops 1.08× when the streak grows. Self-ticking, because the
/// decay clock advances between HUD rebuilds.
class LBComboChip extends StatefulWidget {
  const LBComboChip({super.key, required this.gameState});

  final GameState gameState;

  @override
  State<LBComboChip> createState() => _LBComboChipState();
}

class _LBComboChipState extends State<LBComboChip> with TickerProviderStateMixin {
  static const int _dangerMs = 1500;
  late final AnimationController _ticker =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  late final AnimationController _pop =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 180));

  @override
  void didUpdateWidget(LBComboChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gameState.currentCombo > oldWidget.gameState.currentCombo) {
      _pop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _pop.dispose();
    super.dispose();
  }

  /// Milliseconds left before the combo breaks, extrapolated with wall time
  /// between ticks (game time and wall time advance 1:1 in live play).
  int? _remainingMs() {
    final gs = widget.gameState;
    if (gs.currentCombo <= 0 || gs.gameMode == GameMode.zen) return null;
    var idle = gs.comboIdleMs;
    if (gs.status == GameStatus.playing && gs.pausedAt == null && gs.lastMoveTime != null) {
      idle += DateTime.now().difference(gs.lastMoveTime!).inMilliseconds.clamp(0, 1000);
    }
    return GameConstants.comboDecayMs - idle;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final combo = widget.gameState.currentCombo;
    final mult = '$combo';
    return AnimatedBuilder(
      animation: Listenable.merge([_ticker, _pop]),
      builder: (context, _) {
        final remaining = _remainingMs();
        final danger = remaining != null && remaining <= _dangerMs;
        final label = danger
            ? l10n.lbComboDecay
            : combo >= 5
                ? l10n.lbComboFire(mult)
                : combo >= 3
                    ? l10n.lbComboHot(mult)
                    : l10n.lbComboWarm(mult);
        final popScale = 1 + .08 * math.sin(_pop.value * math.pi);
        final shake = danger ? math.sin(_ticker.value * math.pi * 16) * 1.5 : 0.0;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: Transform.scale(
            scale: popScale,
            child: LBChip(
              label: label,
              kind: danger ? LBChipKind.danger : LBChipKind.gold,
              icon: LBIcon.flame,
              height: 26,
            ),
          ),
        );
      },
    );
  }
}

/// The level-progress cell row that doubles as the board's top wall. A
/// level-up sweeps the cells left→right (DESIGN_SPEC §6).
class LBLevelWall extends StatefulWidget {
  const LBLevelWall({super.key, required this.gameState, required this.width});

  final GameState gameState;
  final double width;

  @override
  State<LBLevelWall> createState() => _LBLevelWallState();
}

class _LBLevelWallState extends State<LBLevelWall> with SingleTickerProviderStateMixin {
  late final AnimationController _sweep =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 420), value: 1);

  @override
  void didUpdateWidget(LBLevelWall oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gameState.level > oldWidget.gameState.level) _sweep.forward(from: 0);
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    // One cell per board column, capped so dense boards keep readable cells.
    final count = math.min(widget.gameState.boardWidth, 20);
    final cell = widget.width / count;
    return Semantics(
      label: AppLocalizations.of(context)!.lbLevelShort('${widget.gameState.level}'),
      child: SizedBox(
        width: widget.width,
        height: cell + 3,
        child: AnimatedBuilder(
          animation: _sweep,
          builder: (context, _) {
            final sweeping = _sweep.value < 1;
            return Column(
              children: [
                LBCellsBar(
                  count: count,
                  cell: cell,
                  value: sweeping ? _sweep.value : widget.gameState.levelProgress,
                  colorAt: (i) => sweeping
                      ? p.head
                      : Color.lerp(p.lime.withValues(alpha: .55), p.lime.withValues(alpha: .8), i / count)!,
                ),
                const SizedBox(height: 2),
                Container(height: 1, color: p.wall),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The strip under the board: what is running (power-up, Time Attack clock,
/// Survival lives) on the left, `LEN n · SPEED` on the right. Self-ticking so
/// countdowns move between ticks.
class LBGameInfoRow extends StatefulWidget {
  const LBGameInfoRow({
    super.key,
    required this.gameState,
    this.showJoke = true,
    this.callout,
  });

  final GameState gameState;

  /// A short-lived event line (level up, life lost…) shown in place of the
  /// power-up readout while it is non-null.
  final ValueListenable<String?>? callout;

  /// Room for the power-up's secondary line (swipe players, no controls).
  final bool showJoke;

  @override
  State<LBGameInfoRow> createState() => _LBGameInfoRowState();
}

class _LBGameInfoRowState extends State<LBGameInfoRow> with SingleTickerProviderStateMixin {
  late final AnimationController _ticker =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  static String speedLabel(AppLocalizations l10n, int gameSpeed) {
    if (gameSpeed >= 280) return l10n.gbSpeedNormal;
    if (gameSpeed >= 230) return l10n.gbSpeedFast;
    if (gameSpeed >= 180) return l10n.gbSpeedFaster;
    if (gameSpeed >= 130) return l10n.gbSpeedBlazing;
    if (gameSpeed >= 80) return l10n.gbSpeedInsane;
    return l10n.gbSpeedMax;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final gs = widget.gameState;
    return SizedBox(
      height: context.lbCell * 2,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.lbGutter),
        child: AnimatedBuilder(
          animation: Listenable.merge([_ticker, widget.callout]),
          builder: (context, _) {
            final left = <Widget>[];
            final callout = widget.callout?.value;
            if (gs.gameMode.timeLimit != null) {
              final s = gs.timeAttackSecondsRemaining;
              final low = s <= 10;
              left.add(_Readout(
                text: '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}',
                color: low ? LB.bonk : LB.gold,
                icon: LBIcon.hourglass,
              ));
            }
            if (gs.initialLives > 1) {
              left.add(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < gs.initialLives; i++)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 3),
                      child: LBPixelIcon(
                        LBIcon.heart,
                        cell: 2.6,
                        color: i < gs.livesRemaining ? LB.bonk : LB.bonk.withValues(alpha: .25),
                      ),
                    ),
                ],
              ));
            }
            final active = gs.activePowerUps.where((x) => !x.isExpired).toList();
            if (callout != null) {
              left.add(Text(
                callout,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LBText.button(p, color: p.lime, size: 12.5).copyWith(letterSpacing: 1.6),
              ));
            } else if (active.isNotEmpty) {
              left.add(_PowerUpReadout(powerUp: active.last, showJoke: widget.showJoke && left.isEmpty));
            }
            return Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 14,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: left,
                  ),
                ),
                Text(
                  '${l10n.lbHudLen('${gs.snake.length}')} · ${speedLabel(l10n, gs.gameSpeed).toUpperCase()}',
                  style: LBText.label(p, color: p.inkMuted).copyWith(fontSize: 10.5, letterSpacing: 1.6),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Readout extends StatelessWidget {
  const _Readout({required this.text, required this.color, required this.icon});

  final String text;
  final Color color;
  final LBIcon icon;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LBPixelIcon(icon, cell: 2.6, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: LBText.button(context.lb, color: color, size: 13)
                .copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
          ),
        ],
      );
}

class _PowerUpReadout extends StatelessWidget {
  const _PowerUpReadout({required this.powerUp, required this.showJoke});

  final ActivePowerUp powerUp;
  final bool showJoke;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final secs = powerUp.remainingTime.inSeconds + 1;
    final ending = powerUp.remainingTime.inSeconds < 5;
    final (String name, String full, String joke, LBIcon icon) = switch (powerUp.type) {
      PowerUpType.invincibility => (
          l10n.puInvincibility,
          l10n.lbPowerInvincible('$secs'),
          l10n.lbPowerInvincibleLine,
          LBIcon.shield,
        ),
      PowerUpType.speedBoost => (l10n.puSpeedBoost, l10n.lbPowerSpeed('$secs'), l10n.lbPowerSpeedLine, LBIcon.bolt),
      PowerUpType.slowMotion => (l10n.puSlowMotion, l10n.lbPowerSlow('$secs'), l10n.lbPowerSlowLine, LBIcon.hourglass),
      PowerUpType.scoreMultiplier => (l10n.puScoreMultiplier, l10n.lbPowerScore('$secs'), '', LBIcon.star),
    };
    // The ending line uses the chip's short name (SPEED, SLOW-MO…): the
    // full catalogue name ("SCORE MULTIPLIER ENDING · 3") ran ~30 dp past
    // the room beside LEN · SPEED on a 384 dp phone.
    final short = full.contains(' · ') ? full.split(' · ').first : name.toUpperCase();
    final label = ending ? l10n.lbPowerEnding(short, '$secs') : full;
    final color = ending ? LB.bonk : LB.gold;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LBPixelIcon(icon, cell: 2.6, color: color),
        const SizedBox(width: 6),
        Flexible(
          flex: 3,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: LBText.button(p, color: color, size: 12.5).copyWith(letterSpacing: 1.6),
          ),
        ),
        if (showJoke && joke.isNotEmpty && !ending) ...[
          const SizedBox(width: 10),
          Flexible(
            flex: 2,
            child: Text(
              joke.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LBText.label(p, color: LB.gold.withValues(alpha: .7)).copyWith(fontSize: 8.5),
            ),
          ),
        ],
      ],
    );
  }
}

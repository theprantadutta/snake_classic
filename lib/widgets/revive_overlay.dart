import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb/lb_crash_copy.dart';
import 'package:snake_classic/widgets/tap_arm_guard.dart';

/// Post-crash "second chance" offer (Living Board screen 07), shown over
/// the frozen board. The crash headline in red cells, then the offer: watch
/// a rewarded ad (free) or pay coins, with a countdown that auto-declines.
/// Pro players get one free-revive button instead (no ads for Pro).
///
/// Rendered while [GameCubitState.offeringRevive].
class ReviveOverlay extends StatefulWidget {
  final GameTheme theme;
  final int coinCost;
  final bool canAffordCoins;

  /// Runs the rewarded watch. Resolves true if an ad was actually displayed
  /// (whether or not the player sat through it), false if none could be shown.
  ///
  /// The button is always live: it never gates on a loaded ad (that hid the
  /// app's highest-eCPM offer exactly when the pool was empty). The load
  /// happens on demand.
  final Future<bool> Function() onWatchAd;
  final VoidCallback onUseCoins;
  final VoidCallback onDecline;

  /// Pro perk: revive instantly, free, no ad and no coins.
  final bool isPro;
  final VoidCallback? onProRevive;
  final int seconds;

  /// The crashed run, for the headline and the "keep length / points" line.
  final GameState? gameState;

  /// The player's coin balance, shown next to the pay button.
  final int? coinBalance;

  const ReviveOverlay({
    super.key,
    required this.theme,
    required this.coinCost,
    required this.canAffordCoins,
    required this.onWatchAd,
    required this.onUseCoins,
    required this.onDecline,
    this.isPro = false,
    this.onProRevive,
    this.seconds = 6,
    this.gameState,
    this.coinBalance,
  });

  @override
  State<ReviveOverlay> createState() => _ReviveOverlayState();
}

class _ReviveOverlayState extends State<ReviveOverlay> {
  late int _remaining = widget.seconds;
  Timer? _timer;
  bool _resolved = false;
  // True while an on-demand rewarded load is in flight.
  bool _loadingAd = false;
  // Set when a watch attempt found no ad, so the player is told why.
  bool _adUnavailable = false;
  final int _seed = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  /// (Re)start the auto-decline countdown. Restartable because a failed ad
  /// attempt hands the offer back to the player — see [_onWatchAd].
  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) _resolve(widget.onDecline);
    });
  }

  void _resolve(VoidCallback action) {
    if (_resolved) return;
    _resolved = true;
    _timer?.cancel();
    action();
  }

  /// Watching the ad is NOT terminal: cancel the countdown (so it can't fire
  /// mid-ad) and trigger the ad. If the player earns the reward the game
  /// revives and this overlay unmounts; if nothing could be shown, the
  /// countdown restarts so the player is never stranded on a dead board.
  Future<void> _onWatchAd() async {
    if (_resolved || _loadingAd) return;
    _timer?.cancel();
    setState(() {
      _loadingAd = true;
      _adUnavailable = false;
    });

    final shown = await widget.onWatchAd();

    if (!mounted || _resolved) return;
    setState(() {
      _loadingAd = false;
      _adUnavailable = !shown;
    });
    if (!shown) _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final cell = context.lbCell;
    final gs = widget.gameState;
    final copy = gs == null
        ? null
        : LBCrashCopy.of(
            l10n,
            LBCrashCopy.reasonOf(gs),
            length: gs.snake.length,
            food: 0,
            seed: _seed,
          );

    return Positioned.fill(
      child: ColoredBox(
        // Dense enough that the info row under the board (LEN · SPEED, the
        // swipe compass) cannot read through the NAH link that lands on it.
        color: p.board.withValues(alpha: .93),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              // One gutter, not gutter + a cell, on narrow phones: at 360 dp
              // the extra cell each side left the card too little room and
              // the coin price read "PAY 1…" (Realme RMX3771). Wider phones
              // and tablets keep the original margin.
              padding: EdgeInsets.symmetric(
                horizontal: context.lbGutter + (MediaQuery.sizeOf(context).width < 380 ? 0 : cell),
                vertical: 20,
              ),
              // The offer lands while the player may still be mid-swipe; a
              // tap meant for the board must not be taken as "watch an ad".
              child: TapArmGuard(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (copy != null) ...[
                        Center(
                          child: LBCellText(copy.title, cell: 10 * context.uiScale, color: LB.bonk, glow: true),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          copy.line,
                          textAlign: TextAlign.center,
                          style: LBText.body(p, color: p.ink, size: 13.5).copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (copy.tagline != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            copy.tagline!,
                            textAlign: TextAlign.center,
                            style: LBText.label(p, color: LB.bonk).copyWith(fontSize: 10),
                          ),
                        ],
                        SizedBox(height: cell * 1.4),
                      ],
                      LBBlock(
                        kind: LBBlockKind.sheet,
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  // One line, shrinking if it must, rather
                                  // than wrapping beside the countdown.
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: AlignmentDirectional.centerStart,
                                    child: Text(
                                      l10n.lbReviveTitle,
                                      maxLines: 1,
                                      style: LBText.button(p, color: LB.gold, size: 15).copyWith(letterSpacing: 2.4),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 62,
                                  child: LBCellsBar(
                                    count: 5,
                                    value: widget.seconds == 0 ? 0 : _remaining / widget.seconds,
                                    color: LB.gold,
                                    offColor: LB.gold.withValues(alpha: .15),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Semantics(
                                  liveRegion: true,
                                  child: Text(
                                    l10n.lbSeconds('$_remaining'),
                                    style: LBText.button(p, color: LB.gold, size: 13),
                                  ),
                                ),
                              ],
                            ),
                            if (gs != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                l10n.lbReviveLine('${gs.snake.length}', context.formatInt(gs.score)),
                                style: LBText.body(p, color: p.ink.withValues(alpha: .75), size: 12),
                              ),
                            ],
                            const SizedBox(height: 16),
                            if (widget.isPro)
                              _OfferButton(
                                kind: LBBlockKind.fill,
                                icon: LBIcon.heart,
                                label: l10n.lbRevivePro,
                                onTap: () => _resolve(widget.onProRevive ?? widget.onDecline),
                              )
                            else ...[
                              _OfferButton(
                                kind: LBBlockKind.fill,
                                icon: _loadingAd ? LBIcon.hourglass : LBIcon.tv,
                                label: _loadingAd ? l10n.rvoLoadingAd : l10n.lbReviveWatch,
                                onTap: _loadingAd ? null : _onWatchAd,
                              ),
                              if (_adUnavailable)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Text(
                                    l10n.lbNoAdNow,
                                    textAlign: TextAlign.center,
                                    style: LBText.body(p, color: p.inkMuted, size: 11.5),
                                  ),
                                ),
                              // Coin alternative (works offline).
                              Opacity(
                                opacity: widget.canAffordCoins ? 1 : .45,
                                child: _OfferButton(
                                  kind: LBBlockKind.gold,
                                  icon: LBIcon.coin,
                                  label: l10n.lbRevivePay(context.formatInt(widget.coinCost)),
                                  aside: widget.coinBalance == null
                                      ? null
                                      : l10n.lbReviveYouHave(context.formatInt(widget.coinBalance!)),
                                  onTap: widget.canAffordCoins ? () => _resolve(widget.onUseCoins) : null,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: Semantics(
                          button: true,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              LBFeedback.back();
                              _resolve(widget.onDecline);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              child: Text(
                                l10n.lbReviveDecline,
                                style: LBText.button(p, color: p.inkMuted, size: 12).copyWith(
                                  decoration: TextDecoration.underline,
                                  decorationColor: p.inkDim,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (!widget.isPro) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const LBPixelIcon(LBIcon.crown, cell: 2.8, color: LB.gold),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                l10n.lbReviveProHint,
                                style: LBText.body(p, color: p.inkMuted, size: 11.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OfferButton extends StatelessWidget {
  const _OfferButton({
    required this.kind,
    required this.icon,
    required this.label,
    required this.onTap,
    this.aside,
  });

  final LBBlockKind kind;
  final LBIcon icon;
  final String label;
  final String? aside;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final fg = LBBlock.foregroundOf(kind, p);
    return LBBlock(
      kind: kind,
      height: context.lbCell * 3.2,
      onTap: onTap,
      // The ad/coin handlers own their feedback.
      feedback: false,
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LBPixelIcon(icon, cell: 3.6, color: fg),
          const SizedBox(width: 12),
          // The label is what the player is agreeing to — "PAY 1,500¢" —
          // so it is never cut; it shrinks if it must. [aside] (the balance)
          // sits under it instead of beside it, where it used to take the
          // label's room and ellipsize the price.
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: LBText.button(p, color: fg, size: 15).copyWith(letterSpacing: 2.4),
                  ),
                ),
                if (aside != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    aside!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LBText.body(p, color: fg.withValues(alpha: .7), size: 11).copyWith(height: 1.2),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

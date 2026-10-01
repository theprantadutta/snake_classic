import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/tap_arm_guard.dart';

/// Time-Attack "out of time" offer shown over the frozen board when the clock
/// hits zero with a rewarded extension still available. Counts down, then
/// auto-declines into game-over. Watching a rewarded ad adds bonus seconds and
/// resumes the run. Mirrors [ReviveOverlay]'s conditional-overlay-in-Stack
/// pattern (rendered while [GameCubitState.offeringTimeBonus]).
class TimeBonusOverlay extends StatefulWidget {
  final GameTheme theme;
  final int bonusSeconds;

  /// Runs the rewarded watch. Resolves true if an ad was actually displayed
  /// (whether or not the player sat through it), false if none could be shown.
  ///
  /// Replaces an `isAdReady` predicate that disabled this button whenever the
  /// rewarded pool was empty — which, at real fill rates, hid the app's
  /// highest-eCPM offer a large share of the time and never let the tap kick a
  /// load. The button is always live now; the load happens on demand.
  final Future<bool> Function() onWatchAd;
  final VoidCallback onDecline;
  final int seconds;

  const TimeBonusOverlay({
    super.key,
    required this.theme,
    required this.bonusSeconds,
    required this.onWatchAd,
    required this.onDecline,
    this.seconds = 6,
  });

  @override
  State<TimeBonusOverlay> createState() => _TimeBonusOverlayState();
}

class _TimeBonusOverlayState extends State<TimeBonusOverlay> {
  late int _remaining = widget.seconds;
  Timer? _timer;
  bool _resolved = false;
  bool _loadingAd = false;
  bool _adUnavailable = false;

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

  /// Watching the ad is NOT terminal: cancel the auto-decline countdown (so it
  /// can't fire mid-ad) and trigger the ad. If the reward is earned the run
  /// resumes and this overlay unmounts; if the ad is skipped/abandoned the
  /// overlay stays interactive so the player can still decline.
  /// The ad may have to load first, which means it can fail. On failure the
  /// countdown restarts — cancelling it and never restoring it would strand
  /// the player on a frozen board with no auto-decline.
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
    return Positioned.fill(
      child: ColoredBox(
        color: p.board.withValues(alpha: .82),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: context.lbGutter + cell, vertical: 20),
              // The offer lands while the player may still be mid-swipe; a tap
              // meant for the board must not be taken as "watch an ad".
              child: TapArmGuard(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Semantics(
                          header: true,
                          child: LBCellText(l10n.tbTimesUp, cell: 9 * context.uiScale, color: LB.bonk, glow: true),
                        ),
                      ),
                      SizedBox(height: cell * 1.2),
                      LBBlock(
                        kind: LBBlockKind.sheet,
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const LBPixelIcon(LBIcon.hourglass, cell: 3.4, color: LB.gold),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Semantics(
                                    liveRegion: true,
                                    child: Text(
                                      l10n.tbKeepGoing(_remaining),
                                      style: LBText.button(p, color: LB.gold, size: 13),
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
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Watch ad — the only way to extend.
                            Opacity(
                              opacity: _loadingAd ? 0.6 : 1,
                              child: LBBlock(
                                kind: LBBlockKind.fill,
                                height: cell * 3.2,
                                onTap: _loadingAd ? null : _onWatchAd,
                                // The ad flow owns its feedback.
                                feedback: false,
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    LBPixelIcon(
                                      _loadingAd ? LBIcon.hourglass : LBIcon.tv,
                                      cell: 3.6,
                                      color: p.onLime,
                                    ),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: Text(
                                        _loadingAd ? l10n.rvoLoadingAd : l10n.tbWatchAd(widget.bonusSeconds),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: LBText.button(p, color: p.onLime, size: 15).copyWith(letterSpacing: 1.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_adUnavailable)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  l10n.lbNoAdNow,
                                  textAlign: TextAlign.center,
                                  style: LBText.body(p, color: p.inkMuted, size: 11.5),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
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
                                l10n.tbEndRun.toUpperCase(),
                                style: LBText.button(p, color: p.inkMuted, size: 12).copyWith(
                                  decoration: TextDecoration.underline,
                                  decorationColor: p.inkDim,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/screen_shell.dart';
import 'package:snake_classic/utils/typography.dart';

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
    final theme = widget.theme;
    final l10n = AppLocalizations.of(context)!;
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.78),
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.backgroundColor,
                theme.backgroundColor.withValues(alpha: 0.92),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.accentColor.withValues(alpha: 0.45),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.accentColor.withValues(alpha: 0.3),
                blurRadius: 26,
                spreadRadius: 1,
              ),
            ],
          ),
          child: HudCorners(
            color: kRewardGold,
            inset: 10,
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Countdown ring with a stopwatch.
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: CircularProgressIndicator(
                        value: widget.seconds == 0
                            ? 0
                            : _remaining / widget.seconds,
                        strokeWidth: 5,
                        backgroundColor:
                            theme.accentColor.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(theme.accentColor),
                      ),
                    ),
                    Icon(Icons.timer, color: theme.foodColor, size: 30),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.tbTimesUp,
                style: TextStyle(
                  color: theme.accentColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: context.letterSpacing(2),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.tbKeepGoing(_remaining),
                style: TextStyle(
                  color: theme.accentColor.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),

              // Watch ad — the only way to extend.
              Opacity(
                opacity: _loadingAd ? 0.6 : 1,
                child: GestureDetector(
                  onTap: _loadingAd ? null : _onWatchAd,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.accentColor, theme.foodColor],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.accentColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _loadingAd
                              ? Icons.hourglass_top
                              : Icons.play_circle_fill,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _loadingAd
                              ? l10n.rvoLoadingAd
                              : l10n.tbWatchAd(widget.bonusSeconds),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_adUnavailable) ...[
                const SizedBox(height: 6),
                Text(
                  l10n.goNoAdAvailable,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.accentColor.withValues(alpha: 0.75),
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => _resolve(widget.onDecline),
                child: Text(
                  l10n.tbEndRun,
                  style: TextStyle(
                    color: theme.accentColor.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/screen_shell.dart';
import 'package:snake_classic/utils/typography.dart';

/// Post-crash "Continue?" offer shown over the frozen board. Counts down, then
/// auto-declines. The player can revive by watching a rewarded ad or paying
/// coins. Pro users never see ads, so instead of the (always-disabled) watch-ad
/// button they get a single "Get Life · Free for Pro" button that revives for
/// free. Mirrors the conditional-overlay-in-Stack pattern of pause_overlay /
/// crash_feedback_overlay (rendered while [GameCubitState.offeringRevive]).
class ReviveOverlay extends StatefulWidget {
  final GameTheme theme;
  final int coinCost;
  final bool canAffordCoins;
  /// Runs the rewarded watch. Resolves true if an ad was actually displayed
  /// (whether or not the player sat through it), false if none could be shown.
  ///
  /// This used to be paired with an `isAdReady` predicate that disabled the
  /// button whenever the rewarded pool was empty. That was costing impressions
  /// of the app's highest-eCPM format: at real fill rates the pool is empty
  /// often, so the button greyed out precisely when the ad was worth the most,
  /// and the tap that would have kicked a load never happened. The button is
  /// now always live and the load happens on demand.
  final Future<bool> Function() onWatchAd;
  final VoidCallback onUseCoins;
  final VoidCallback onDecline;
  /// Pro perk: revive instantly, free, no ad and no coins. When [isPro] is true
  /// the overlay swaps the watch-ad / coins buttons for a single free-life
  /// button wired to this callback.
  final bool isPro;
  final VoidCallback? onProRevive;
  final int seconds;

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
  });

  @override
  State<ReviveOverlay> createState() => _ReviveOverlayState();
}

class _ReviveOverlayState extends State<ReviveOverlay> {
  late int _remaining = widget.seconds;
  Timer? _timer;
  bool _resolved = false;
  // True while an on-demand rewarded load is in flight, so the button shows
  // progress instead of looking unresponsive.
  bool _loadingAd = false;
  // Set when a watch attempt found no ad, so the player is told why nothing
  // happened rather than being left staring at a button that did nothing.
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
  /// can't fire mid-ad) and trigger the ad. If the player earns the reward the
  /// game revives and this overlay unmounts; if they skip/abandon the ad, the
  /// overlay stays interactive so they can still use coins or decline.
  ///
  /// The ad may now have to load first, which means it can also fail. When it
  /// does we restart the countdown rather than leaving the overlay frozen —
  /// cancelling the timer and never restoring it would strand the player on a
  /// dead board with no auto-decline.
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
    // Nothing was displayed, so the offer is still open — give the player the
    // rest of their countdown back to choose coins or decline.
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
            color: theme.accentColor,
            inset: 10,
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Countdown ring with a heart.
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
                        valueColor:
                            AlwaysStoppedAnimation(theme.accentColor),
                      ),
                    ),
                    Icon(Icons.favorite,
                        color: theme.foodColor, size: 30),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.rvoContinue,
                style: TextStyle(
                  color: theme.accentColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: context.letterSpacing(2),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.isPro
                    ? l10n.rvoSubtitlePro
                    : l10n.rvoSubtitleTimer(_remaining),
                style: TextStyle(
                  color: theme.accentColor.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),

              if (widget.isPro)
                // Pro perk: one free life, no ad, no coins.
                _ActionButton(
                  theme: theme,
                  icon: Icons.workspace_premium,
                  label: l10n.rvoGetLifePro,
                  enabled: true,
                  filled: true,
                  onTap: () => _resolve(widget.onProRevive ?? widget.onDecline),
                )
              else ...[
                // Watch ad — primary when available.
                _ActionButton(
                  theme: theme,
                  icon: _loadingAd
                      ? Icons.hourglass_top
                      : Icons.play_circle_fill,
                  label: _loadingAd ? l10n.rvoLoadingAd : l10n.rvoWatchAd,
                  enabled: !_loadingAd,
                  filled: true,
                  onTap: _onWatchAd,
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
                const SizedBox(height: 10),
                // Coin alternative (works offline).
                _ActionButton(
                  theme: theme,
                  icon: Icons.monetization_on,
                  label: l10n.rvoUseCoins(widget.coinCost),
                  enabled: widget.canAffordCoins,
                  filled: false,
                  onTap: () => _resolve(widget.onUseCoins),
                ),
              ],
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => _resolve(widget.onDecline),
                child: Text(
                  l10n.rvoNoThanks,
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

class _ActionButton extends StatelessWidget {
  final GameTheme theme;
  final IconData icon;
  final String label;
  final bool enabled;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.theme,
    required this.icon,
    required this.label,
    required this.enabled,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = theme.accentColor;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            gradient: filled
                ? LinearGradient(colors: [accent, theme.foodColor])
                : null,
            color: filled ? null : accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: filled ? Colors.white : accent, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: filled ? Colors.white : accent,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

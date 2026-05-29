import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snake_classic/utils/constants.dart';

/// Post-crash "Continue?" offer shown over the frozen board. Counts down, then
/// auto-declines. The player can revive by watching a rewarded ad or paying
/// coins. Mirrors the conditional-overlay-in-Stack pattern of pause_overlay /
/// crash_feedback_overlay (rendered while [GameCubitState.offeringRevive]).
class ReviveOverlay extends StatefulWidget {
  final GameTheme theme;
  final int coinCost;
  /// Live readiness check — evaluated on every (re)build, including the 1s
  /// countdown ticks, so the button enables the moment the rewarded ad finishes
  /// (re)loading instead of being frozen on a stale snapshot.
  final bool Function() isAdReady;
  final bool canAffordCoins;
  final VoidCallback onWatchAd;
  final VoidCallback onUseCoins;
  final VoidCallback onDecline;
  final int seconds;

  const ReviveOverlay({
    super.key,
    required this.theme,
    required this.coinCost,
    required this.isAdReady,
    required this.canAffordCoins,
    required this.onWatchAd,
    required this.onUseCoins,
    required this.onDecline,
    this.seconds = 6,
  });

  @override
  State<ReviveOverlay> createState() => _ReviveOverlayState();
}

class _ReviveOverlayState extends State<ReviveOverlay> {
  late int _remaining = widget.seconds;
  Timer? _timer;
  bool _resolved = false;

  @override
  void initState() {
    super.initState();
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
  void _onWatchAd() {
    if (_resolved) return;
    _timer?.cancel();
    widget.onWatchAd();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
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
                'CONTINUE?',
                style: TextStyle(
                  color: theme.accentColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Revive and keep your score · ${_remaining}s',
                style: TextStyle(
                  color: theme.accentColor.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),

              // Watch ad — primary when available.
              _ActionButton(
                theme: theme,
                icon: Icons.play_circle_fill,
                label: 'Watch ad to revive',
                enabled: widget.isAdReady(),
                filled: true,
                onTap: _onWatchAd,
              ),
              const SizedBox(height: 10),
              // Coin alternative (works offline).
              _ActionButton(
                theme: theme,
                icon: Icons.monetization_on,
                label: 'Use ${widget.coinCost} coins',
                enabled: widget.canAffordCoins,
                filled: false,
                onTap: () => _resolve(widget.onUseCoins),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => _resolve(widget.onDecline),
                child: Text(
                  'No thanks',
                  style: TextStyle(
                    color: theme.accentColor.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snake_classic/utils/constants.dart';

/// Time-Attack "out of time" offer shown over the frozen board when the clock
/// hits zero with a rewarded extension still available. Counts down, then
/// auto-declines into game-over. Watching a rewarded ad adds bonus seconds and
/// resumes the run. Mirrors [ReviveOverlay]'s conditional-overlay-in-Stack
/// pattern (rendered while [GameCubitState.offeringTimeBonus]).
class TimeBonusOverlay extends StatefulWidget {
  final GameTheme theme;
  final int bonusSeconds;

  /// Live readiness check — evaluated on every (re)build including the 1s
  /// countdown ticks, so the button enables the moment the ad finishes loading.
  final bool Function() isAdReady;
  final VoidCallback onWatchAd;
  final VoidCallback onDecline;
  final int seconds;

  const TimeBonusOverlay({
    super.key,
    required this.theme,
    required this.bonusSeconds,
    required this.isAdReady,
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
  /// can't fire mid-ad) and trigger the ad. If the reward is earned the run
  /// resumes and this overlay unmounts; if the ad is skipped/abandoned the
  /// overlay stays interactive so the player can still decline.
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
                "TIME'S UP!",
                style: TextStyle(
                  color: theme.accentColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Keep going · ${_remaining}s',
                style: TextStyle(
                  color: theme.accentColor.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),

              // Watch ad — the only way to extend.
              Opacity(
                opacity: widget.isAdReady() ? 1 : 0.4,
                child: GestureDetector(
                  onTap: widget.isAdReady() ? _onWatchAd : null,
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
                        const Icon(Icons.play_circle_fill,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Watch ad — +${widget.bonusSeconds}s',
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
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => _resolve(widget.onDecline),
                child: Text(
                  'End run',
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

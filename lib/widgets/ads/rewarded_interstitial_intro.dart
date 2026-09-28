import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/typography.dart';
import 'package:snake_classic/widgets/screen_shell.dart';
import 'package:snake_classic/widgets/tap_arm_guard.dart';

/// The intro screen Google requires before every rewarded interstitial.
///
/// AdMob's rules for the format: before the ad starts the player must see
/// clear reward messaging, get enough time to take it in, and have a clear,
/// unobstructed way to skip. The SDK provides none of that. The app shipped
/// with only a one-line notice above PLAY AGAIN / MENU, both of which played
/// the ad, so there was no way to decline at all.
///
/// Resolves `true` to play the ad (WATCH NOW, or the countdown ran out) and
/// `false` to skip it (NO THANKS, or the system back gesture). Skipping is a
/// first-class answer: the caller plays nothing in its place.
Future<bool> showRewardedInterstitialIntro(
  BuildContext context, {
  required GameTheme theme,
  required int coins,
  int seconds = 5,
}) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.78),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (_, _, _) => _RewardedInterstitialIntro(
      theme: theme,
      coins: coins,
      seconds: seconds,
    ),
    transitionBuilder: (_, animation, _, child) => FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween(begin: 0.94, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    ),
  );
  return result ?? false;
}

class _RewardedInterstitialIntro extends StatefulWidget {
  const _RewardedInterstitialIntro({
    required this.theme,
    required this.coins,
    required this.seconds,
  });

  final GameTheme theme;
  final int coins;
  final int seconds;

  @override
  State<_RewardedInterstitialIntro> createState() =>
      _RewardedInterstitialIntroState();
}

class _RewardedInterstitialIntroState extends State<_RewardedInterstitialIntro>
    with WidgetsBindingObserver {
  late int _remaining = widget.seconds;
  Timer? _timer;
  bool _resolved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) _resolve(true);
    });
  }

  // The countdown only runs while the player can see it. Left running in the
  // background it would run out unseen and start the ad while the app is not
  // in front, which is neither an informed choice nor a showable ad.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_resolved) return;
    if (state == AppLifecycleState.resumed) {
      _startCountdown();
    } else {
      _timer?.cancel();
    }
  }

  void _resolve(bool watch) {
    if (_resolved) return;
    _resolved = true;
    _timer?.cancel();
    Navigator.of(context).pop(watch);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: ConstrainedBox(
        // No-op on phones (the margins already keep the card narrower);
        // stops it stretching across a tablet.
        constraints: const BoxConstraints(maxWidth: 420),
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
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
                color: kRewardGold.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: kRewardGold.withValues(alpha: 0.25),
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
                  // Countdown ring around the reward.
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
                                kRewardGold.withValues(alpha: 0.15),
                            valueColor:
                                const AlwaysStoppedAnimation(kRewardGold),
                          ),
                        ),
                        const Icon(
                          Icons.monetization_on,
                          color: kRewardGold,
                          size: 32,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.adIntroTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kRewardGold,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: context.letterSpacing(1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.adIntroBody(widget.coins),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.accentColor.withValues(alpha: 0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      l10n.adIntroCountdown(_remaining.clamp(0, 99)),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.accentColor.withValues(alpha: 0.65),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // The card lands where a double-tap on PLAY AGAIN may still
                  // be arriving, so neither choice is live for its first beat.
                  TapArmGuard(
                    child: Column(
                      children: [
                        _IntroButton(
                          label: l10n.adIntroWatch,
                          icon: Icons.play_circle_fill,
                          filled: true,
                          theme: theme,
                          onTap: () => _resolve(true),
                        ),
                        const SizedBox(height: 10),
                        // Same size and weight as WATCH NOW on purpose: Google
                        // requires the skip to be clear and unobstructed, and
                        // a faint text link would not be.
                        _IntroButton(
                          label: l10n.adIntroSkip,
                          icon: Icons.close,
                          filled: false,
                          theme: theme,
                          onTap: () => _resolve(false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroButton extends StatelessWidget {
  const _IntroButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.theme,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final GameTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : theme.accentColor;
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            gradient: filled
                ? LinearGradient(colors: [theme.accentColor, theme.foodColor])
                : null,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.accentColor.withValues(alpha: filled ? 0.4 : 0.7),
              width: filled ? 1 : 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: fg, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fg,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
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

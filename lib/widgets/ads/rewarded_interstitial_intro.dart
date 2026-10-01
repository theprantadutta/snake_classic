import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final cell = context.lbCell;
    final scale = context.uiScale;
    final coins = context.formatInt(widget.coins);
    final secs = '${_remaining.clamp(0, 99)}';

    return Material(
      type: MaterialType.transparency,
      child: LBGridBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, box) {
              final h = box.maxHeight;
              // Everything below is sized from the height this phone actually
              // has, then the slack is spread between the groups. Very short
              // windows (split screen) and large text fall back to a plain
              // scrolling column so nothing is ever cut off.
              final bigText = MediaQuery.textScalerOf(context).scale(10) > 11.5;
              final fits = h >= 540 && !bigText;
              final logo = (h * .06).clamp(34.0, 56.0) * (fits ? 1 : .8);
              final digitCell = fits ? ((h - 440) / 7).clamp(12.0, 24.0) * scale : 12.0 * scale;
              final buttonHeight = fits ? (h * .088).clamp(60.0, 82.0) : cell * 3.2;

              Widget gap(double flex, double fixed) =>
                  fits ? Spacer(flex: (flex * 10).round()) : SizedBox(height: fixed);

              final children = <Widget>[
                gap(2, cell * .4),
                Center(child: LBCellSMark(size: logo * scale)),
                gap(3, cell * .8),
                Center(
                  child: Semantics(
                    header: true,
                    child: LBCellText(l10n.lbAdBreak, cell: 6.5 * scale, color: LB.gold, glow: true),
                  ),
                ),
                gap(1.5, cell * .6),
                // The reward, stated plainly, before anything plays.
                Text(
                  l10n.lbAdBreakLine(coins),
                  textAlign: TextAlign.center,
                  style: LBText.body(p, color: p.ink, size: 14).copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.lbAdBreakLine2,
                  textAlign: TextAlign.center,
                  style: LBText.body(p, color: p.inkMuted, size: 12),
                ),
                gap(2, cell * .7),
                Center(
                  child: ExcludeSemantics(
                    child: LBAnimatedCellText(
                      secs,
                      cell: digitCell,
                      color: LB.gold,
                      glow: true,
                      duration: const Duration(milliseconds: 160),
                    ),
                  ),
                ),
                gap(1.5, cell * .6),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.lbAdStartsIn(secs),
                    textAlign: TextAlign.center,
                    style: LBText.label(p, color: p.inkMuted).copyWith(fontSize: 10),
                  ),
                ),
                gap(1.5, cell * .6),
                Center(
                  child: LBBlock(
                    kind: LBBlockKind.gold,
                    height: cell * 2,
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const LBPixelIcon(LBIcon.coin, cell: 3.2, color: LB.gold),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            l10n.lbAdRewardWhenEnds(coins),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: LBText.button(p, color: LB.gold, size: 12).copyWith(letterSpacing: 2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                gap(2, cell * .7),
                // The intro lands where a double-tap on PLAY AGAIN may still
                // be arriving, so neither choice is live for its first beat.
                TapArmGuard(
                  child: Row(
                    children: [
                      Expanded(
                        child: _IntroButton(
                          label: l10n.lbWatchNow,
                          icon: LBIcon.play,
                          filled: true,
                          height: buttonHeight,
                          onTap: () => _resolve(true),
                        ),
                      ),
                      // Same size, icon, type and weight as WATCH NOW on
                      // purpose: Google requires the skip to be clear and
                      // unobstructed. A lime fill against a full-ink outline
                      // keeps the two equally prominent.
                      Expanded(
                        child: _IntroButton(
                          label: l10n.lbNoThanks,
                          icon: LBIcon.x,
                          filled: false,
                          height: buttonHeight,
                          onTap: () => _resolve(false),
                        ),
                      ),
                    ],
                  ),
                ),
                gap(1.2, cell * .7),
                Text(
                  l10n.lbAdBackHint,
                  textAlign: TextAlign.center,
                  style: LBText.body(p, color: p.inkMuted, size: 11.5),
                ),
                gap(3, cell * .6),
              ];

              final column = Column(
                mainAxisSize: fits ? MainAxisSize.max : MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              );

              return Center(
                child: ConstrainedBox(
                  // No-op on phones; stops the choices stretching across a
                  // tablet.
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.lbGutter),
                    child: fits
                        ? SizedBox(height: h, child: column)
                        : SingleChildScrollView(child: column),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// One of the two equal choices. Both are the same size with the same icon
/// and text size; WATCH NOW is the lime fill, NO THANKS a high-contrast ink
/// outline with full-ink text.
class _IntroButton extends StatefulWidget {
  const _IntroButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.height,
    required this.onTap,
  });

  final String label;
  final LBIcon icon;
  final bool filled;
  final double height;
  final VoidCallback onTap;

  @override
  State<_IntroButton> createState() => _IntroButtonState();
}

class _IntroButtonState extends State<_IntroButton> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed != v && mounted) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final height = widget.height;
    final fg = widget.filled ? p.onLime : p.ink;
    final iconCell = (height * .06).clamp(3.6, 5.0);

    final face = FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LBPixelIcon(widget.icon, cell: iconCell, color: fg),
          const SizedBox(height: 9),
          Text(
            widget.label,
            maxLines: 1,
            style: LBText.button(p, color: fg, size: 13).copyWith(letterSpacing: 2.6),
          ),
        ],
      ),
    );

    final Widget surface = widget.filled
        ? LBBlock(
            kind: LBBlockKind.fill,
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            child: face,
          )
        : Padding(
            padding: const EdgeInsets.all(LB.inset),
            child: SizedBox(
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: p.ink.withValues(alpha: .05),
                  borderRadius: BorderRadius.circular(LB.blockRadius),
                  border: Border.all(color: p.ink.withValues(alpha: .85), width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Center(child: face),
                ),
              ),
            ),
          );

    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _pressed ? .97 : 1,
          duration: LB.tap,
          curve: Curves.easeOut,
          child: surface,
        ),
      ),
    );
  }
}

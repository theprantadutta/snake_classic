import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/services/ads/ad_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/overlays/lb_overlay_parts.dart';

/// Generic "watch an ad for X" card used by the rewarded placements (free
/// power-up, bonus XP, …). Self-hides for Pro / when ads are disabled, disables
/// itself when no ad is loaded, and enables **the instant** the rewarded ad
/// finishes loading — it listens on [AdService.rewardedReadyListenable] rather
/// than polling, so there is no up-to-two-seconds lag between the ad being
/// ready and the button becoming tappable (and no periodic rebuild for the
/// widget's whole life). Rewarded ads are opt-in and uncapped — the only gate
/// is whether an ad is loaded.
///
/// [onWatch] performs the actual ad show + grant (typically
/// `AdService.showRewardedFor(...)`); the button just handles gating + UI.
class RewardedActionButton extends StatefulWidget {
  final GameTheme theme;
  final IconData icon;
  final String label;

  /// AdService placement id (e.g. [AdService.placementFreePowerUp]). Identifies the
  /// placement; gating is purely on a loaded ad either way.
  final String? placement;

  /// Does the ad + grant. Should call AdService.showRewarded(Capped). Awaited so
  /// the button can refresh its state after.
  final Future<void> Function() onWatch;

  const RewardedActionButton({
    super.key,
    required this.theme,
    required this.icon,
    required this.label,
    required this.onWatch,
    this.placement,
  });

  @override
  State<RewardedActionButton> createState() => _RewardedActionButtonState();
}

class _RewardedActionButtonState extends State<RewardedActionButton> {
  AdService? get _ads =>
      GetIt.I.isRegistered<AdService>() ? GetIt.I<AdService>() : null;

  @override
  void initState() {
    super.initState();
    _ads?.preloadRewarded();
    _ads?.rewardedReadyListenable.addListener(_onReadyChanged);
    // Ads may not be enabled yet (SDK still initialising on a cold start).
    _ads?.adsEnabledListenable.addListener(_onReadyChanged);
  }

  void _onReadyChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ads?.rewardedReadyListenable.removeListener(_onReadyChanged);
    _ads?.adsEnabledListenable.removeListener(_onReadyChanged);
    super.dispose();
  }

  bool _enabled(AdService ads) => widget.placement != null
      ? ads.isRewardedReady
      : ads.isRewardedReady;

  Future<void> _onTap() async {
    await widget.onWatch();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ads = _ads;
    if (ads == null || !ads.adsEnabled) return const SizedBox.shrink();

    final enabled = _enabled(ads);
    final l10n = AppLocalizations.of(context)!;
    final subtitle = enabled ? l10n.raOptIn : l10n.rcNoAd;
    final p = context.lb;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: LBBlock(
          kind: LBBlockKind.gold,
          onTap: enabled ? _onTap : null,
          // The ad flow owns its own feedback.
          feedback: false,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              const LBPixelIcon(LBIcon.tv, cell: 4, color: LB.gold),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label.toUpperCase(),
                      style: LBText.button(p, color: LB.gold, size: 12.5),
                    ),
                    const SizedBox(height: 3),
                    Text(subtitle, style: LBText.body(p, size: 11)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              LBMappedIcon(widget.icon, cell: 3.6, color: LB.gold),
            ],
          ),
        ),
      ),
    );
  }
}

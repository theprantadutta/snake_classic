import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/services/ads/ad_service.dart';
import 'package:snake_classic/utils/constants.dart';

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

    final theme = widget.theme;
    final enabled = _enabled(ads);
    final l10n = AppLocalizations.of(context)!;
    final subtitle = enabled ? l10n.raOptIn : l10n.rcNoAd;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: enabled ? _onTap : null,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.accentColor.withValues(alpha: 0.18),
                theme.foodColor.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.accentColor.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(Icons.play_circle_fill, color: theme.accentColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: theme.accentColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.accentColor.withValues(alpha: 0.65),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(widget.icon,
                  color: theme.accentColor.withValues(alpha: 0.9), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

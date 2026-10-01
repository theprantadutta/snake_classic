import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/services/ads/ad_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/ads/reward_toast.dart';

/// Shared show-ad-then-credit flow for the free-coins placements. Captures
/// the messenger BEFORE showing the ad (the grant fires after dismissal —
/// an async gap where reading context is unsafe), credits via [CoinsCubit],
/// and confirms with the standard reward toast.
Future<void> watchAdForCoins(
  BuildContext context,
  AdService ads, {
  required String placement,
}) async {
  final coins = context.read<CoinsCubit>();
  final messenger = ScaffoldMessenger.of(context);
  // Captured before the ad — onCoins fires after dismissal, an async gap
  // where reading context is unsafe.
  final l10n = AppLocalizations.of(context)!;
  await ads.showRewardedForCoins(
    onCoins: (amount) {
      coins.earnCoins(
        CoinEarningSource.watchedAd,
        customAmount: amount,
        itemName: 'Watched ad',
        metadata: {'placement': placement},
      );
      showRewardToast(
        messenger,
        l10n.rcCoinsAdded(amount),
        icon: Icons.monetization_on,
      );
    },
  );
}

/// "Watch an ad for coins" card. Self-hides for Pro users / when ads are
/// unavailable, and disables itself only when no ad is loaded (opt-in, uncapped).
/// Credits coins offline-first via [CoinsCubit.earnCoins].
class RewardedCoinsButton extends StatefulWidget {
  final GameTheme theme;
  const RewardedCoinsButton({super.key, required this.theme});

  @override
  State<RewardedCoinsButton> createState() => _RewardedCoinsButtonState();
}

class _RewardedCoinsButtonState extends State<RewardedCoinsButton> {
  AdService? get _ads =>
      GetIt.I.isRegistered<AdService>() ? GetIt.I<AdService>() : null;

  @override
  void initState() {
    super.initState();
    _ads?.preloadRewarded();
    // Enable the moment an ad is ready, rather than only after some unrelated
    // rebuild — the card used to sit greyed out with "no ad" while one was
    // already loaded.
    _ads?.rewardedReadyListenable.addListener(_onReadyChanged);
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

  Future<void> _watch() async {
    final ads = _ads;
    if (ads == null) return;
    await watchAdForCoins(context, ads, placement: 'store_free_coins');
    if (mounted) setState(() {}); // refresh enabled state
  }

  @override
  Widget build(BuildContext context) {
    final ads = _ads;
    if (ads == null || !ads.adsEnabled) return const SizedBox.shrink();

    final enabled = ads.canShowFreeCoinAd;
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: LBBlock(
          kind: LBBlockKind.gold,
          onTap: enabled ? _watch : null,
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
                      l10n.lbFreeCoins(context.formatInt(AdService.freeCoinsPerAd)),
                      style: LBText.button(p, color: LB.gold, size: 12.5),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      enabled ? l10n.lbFreeCoinsLine : l10n.rcNoAd,
                      style: LBText.body(p, size: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const LBPixelIcon(LBIcon.coin, cell: 3.6, color: LB.gold),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact "watch ad → +25" pill for tight spots (the store's balance
/// header). Same gating + grant + toast as [RewardedCoinsButton], just a
/// pill. Self-hides for Pro / when ads are unavailable; dims only when no ad is
/// loaded (opt-in, uncapped). Lights up the moment the rewarded ad finishes
/// loading, via [AdService.rewardedReadyListenable] rather than a ticker.
class RewardedCoinsPill extends StatefulWidget {
  const RewardedCoinsPill({super.key});

  @override
  State<RewardedCoinsPill> createState() => _RewardedCoinsPillState();
}

class _RewardedCoinsPillState extends State<RewardedCoinsPill> {
  AdService? get _ads =>
      GetIt.I.isRegistered<AdService>() ? GetIt.I<AdService>() : null;

  @override
  void initState() {
    super.initState();
    _ads?.preloadRewarded();
    _ads?.rewardedReadyListenable.addListener(_onReadyChanged);
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

  Future<void> _watch() async {
    final ads = _ads;
    if (ads == null) return;
    await watchAdForCoins(context, ads, placement: 'store_balance_pill');
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ads = _ads;
    if (ads == null || !ads.adsEnabled) return const SizedBox.shrink();
    final enabled = ads.canShowFreeCoinAd;
    final p = context.lb;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Semantics(
        button: true,
        enabled: enabled,
        child: GestureDetector(
          onTap: enabled ? _watch : null,
          child: Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 9),
            decoration: BoxDecoration(
              color: LB.goldFill,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: LB.goldStroke),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LBPixelIcon(LBIcon.tv, cell: 3, color: LB.gold),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.of(context)!.lbCoinsReward(context.formatInt(AdService.freeCoinsPerAd)),
                  style: LBText.button(p, color: LB.gold, size: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

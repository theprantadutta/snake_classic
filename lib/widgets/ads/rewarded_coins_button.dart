import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/services/ads/ad_service.dart';
import 'package:snake_classic/utils/constants.dart';
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
        '🎉 +$amount coins added to your wallet!',
        icon: Icons.monetization_on,
      );
    },
  );
}

/// "Watch an ad for coins" card. Self-hides for Pro users / when ads are
/// unavailable, and disables itself once the daily cap is hit or no ad is
/// loaded. Credits coins offline-first via [CoinsCubit.earnCoins].
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
  }

  Future<void> _watch() async {
    final ads = _ads;
    if (ads == null) return;
    await watchAdForCoins(context, ads, placement: 'store_free_coins');
    if (mounted) setState(() {}); // refresh "N left today"
  }

  @override
  Widget build(BuildContext context) {
    final ads = _ads;
    if (ads == null || !ads.adsEnabled) return const SizedBox.shrink();

    final theme = widget.theme;
    final remaining = ads.freeCoinAdsRemainingToday;
    final enabled = ads.canShowFreeCoinAd;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: enabled ? _watch : null,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.withValues(alpha: 0.18),
                Colors.orange.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.play_circle_fill, color: Colors.amber, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Watch an ad — +${AdService.freeCoinsPerAd} coins',
                      style: TextStyle(
                        color: theme.accentColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      enabled
                          ? '$remaining left today'
                          : (remaining == 0
                              ? 'Come back tomorrow for more'
                              : 'No ad available right now'),
                      style: TextStyle(
                        color: theme.accentColor.withValues(alpha: 0.65),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.monetization_on,
                  color: Colors.amber.withValues(alpha: 0.9), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact "watch ad → +25" pill for tight spots (the store's balance
/// header). Same gating + grant + toast as [RewardedCoinsButton], just a
/// pill. Self-hides for Pro / when ads are unavailable; dims when no ad is
/// loaded or the daily cap is hit. A 1s ticker re-checks readiness so the
/// pill lights up the moment the rewarded ad finishes loading.
class RewardedCoinsPill extends StatefulWidget {
  const RewardedCoinsPill({super.key});

  @override
  State<RewardedCoinsPill> createState() => _RewardedCoinsPillState();
}

class _RewardedCoinsPillState extends State<RewardedCoinsPill> {
  Timer? _ticker;
  bool _lastEnabled = false;

  AdService? get _ads =>
      GetIt.I.isRegistered<AdService>() ? GetIt.I<AdService>() : null;

  @override
  void initState() {
    super.initState();
    _ads?.preloadRewarded();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final enabled = _ads?.canShowFreeCoinAd ?? false;
      if (enabled != _lastEnabled && mounted) {
        setState(() => _lastEnabled = enabled);
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
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
    _lastEnabled = enabled;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: enabled ? _watch : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.withValues(alpha: 0.25),
                Colors.orange.withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_circle_fill, color: Colors.amber, size: 18),
              const SizedBox(width: 5),
              Text(
                '+${AdService.freeCoinsPerAd}',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

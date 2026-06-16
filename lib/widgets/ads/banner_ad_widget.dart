import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/services/ads/ad_config.dart';
import 'package:snake_classic/services/ads/ad_service.dart';

/// A self-contained anchored banner (standard 320×50).
///
/// For non-Pro mobile users it **reserves the fixed banner height from the very
/// first frame** — before the SDK is ready and before any ad has filled — so the
/// page never shifts when the ad pops in a moment later. The reserved box is
/// empty until an ad loads, then the ad fills it in place.
///
/// For Pro users and non-mobile platforms it takes **zero space, from the first
/// render** — and it reacts to premium status (via [BlocBuilder]) so a
/// mid-session upgrade collapses the space immediately.
///
/// Uses the fixed [AdSize.banner] deliberately: it's compact and non-deprecated.
/// The SDK's adaptive anchored sizes are either deprecated or the tall "Large"
/// variant that grows up to 15% of screen height — neither suits a bottom anchor.
class SnakeBannerAd extends StatefulWidget {
  const SnakeBannerAd({super.key});

  @override
  State<SnakeBannerAd> createState() => _SnakeBannerAdState();
}

class _SnakeBannerAdState extends State<SnakeBannerAd> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    if (!GetIt.I.isRegistered<AdService>()) return;
    if (!GetIt.I<AdService>().adsEnabled) return;
    final ad = BannerAd(
      adUnitId: AdConfig.bannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _ad = ad as BannerAd;
            _loaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    );
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when premium status changes so Pro users never reserve space
    // (even on the first frame) and a mid-session upgrade collapses it at once.
    return BlocBuilder<PremiumCubit, PremiumState>(
      builder: (context, _) {
        final reserve = GetIt.I.isRegistered<AdService>() &&
            GetIt.I<AdService>().shouldReserveBannerSpace;

        // Pro / non-mobile → zero footprint from the first render.
        if (!reserve) return const SizedBox.shrink();

        // Non-Pro mobile → reserve the fixed banner height NOW, regardless of
        // SDK/ad load state, so the layout never shifts. Empty until filled.
        final ad = _ad;
        return SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: AdSize.banner.height.toDouble(),
            child: (_loaded && ad != null)
                ? Center(
                    child: SizedBox(
                      width: ad.size.width.toDouble(),
                      height: ad.size.height.toDouble(),
                      child: AdWidget(ad: ad),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

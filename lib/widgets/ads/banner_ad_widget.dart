import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:snake_classic/services/ads/ad_config.dart';
import 'package:snake_classic/services/ads/ad_service.dart';

/// A self-contained anchored banner for **non-gameplay** list screens
/// (leaderboard / replays / achievements / statistics). Renders nothing for
/// Pro users, on web/desktop, before the SDK is ready, or until an ad loads —
/// so it's always safe to drop into a layout.
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
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}

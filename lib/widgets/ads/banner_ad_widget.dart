import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:snake_classic/services/ads/ad_config.dart';
import 'package:snake_classic/services/ads/ad_service.dart';

/// A self-contained **anchored adaptive** banner.
///
/// Anchored adaptive banners fill the device width and let the SDK pick the
/// optimal height for the screen (typically 50–60 dp on phones). They earn a
/// higher eCPM and fill better than the old fixed 320×50 `AdSize.banner`, while
/// reusing the same banner ad unit id — no console change needed.
///
/// For Pro users and non-mobile platforms it renders nothing (takes zero
/// space). For everyone else it **always reserves the banner height up front**
/// — even while the adaptive size is still resolving, while the ad is loading,
/// after it fails, or when the device is offline — and the ad simply fills that
/// reserved box once it arrives. Reserving the space up front is what prevents
/// the layout shift users would otherwise see when a banner pops in a moment
/// after the screen renders.
class SnakeBannerAd extends StatefulWidget {
  const SnakeBannerAd({super.key});

  @override
  State<SnakeBannerAd> createState() => _SnakeBannerAdState();
}

class _SnakeBannerAdState extends State<SnakeBannerAd> {
  BannerAd? _ad;
  bool _loaded = false;
  // The resolved anchored-adaptive size. Null until the platform call returns;
  // we reserve the standard banner height in the meantime so the box never
  // starts at zero and then jump-expands.
  AdSize? _size;
  bool _sizeRequested = false;

  bool get _adsOn =>
      GetIt.I.isRegistered<AdService>() && GetIt.I<AdService>().adsEnabled;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery is available here (not in initState), so resolve the adaptive
    // size from the real screen width — but only once.
    if (!_sizeRequested) {
      _sizeRequested = true;
      _resolveSizeAndLoad();
    }
  }

  Future<void> _resolveSizeAndLoad() async {
    if (!_adsOn) return;
    final width = MediaQuery.of(context).size.width.truncate();
    // Anchored adaptive: full-width, SDK-chosen height for this device (capped
    // at 15% of screen height, min 50px). Falls back to the fixed banner if the
    // platform can't supply one (e.g. width 0).
    final adaptive =
        await AdSize.getLargeAnchoredAdaptiveBannerAdSizeWithOrientation(
      Orientation.portrait,
      width,
    );
    if (!mounted) return;
    final size = adaptive ?? AdSize.banner;
    setState(() => _size = size);
    _load(size);
  }

  void _load(AdSize size) {
    if (!_adsOn) return;
    final ad = BannerAd(
      adUnitId: AdConfig.bannerUnitId,
      size: size,
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
    // Pro / non-mobile / no AdService → take no space at all.
    if (!GetIt.I.isRegistered<AdService>() ||
        !GetIt.I<AdService>().shouldReserveBannerSpace) {
      return const SizedBox.shrink();
    }

    // Non-Pro mobile users: reserve the banner height NOW and keep it reserved
    // regardless of resolve/load/fill/offline state. Use the resolved adaptive
    // height once known, falling back to the standard banner height while it
    // resolves. The reserved box never shrinks, so the ad fills it without
    // shifting surrounding layout.
    final reservedHeight = (_size?.height ?? AdSize.banner.height).toDouble();
    final ad = _ad;
    return SafeArea(
      top: false,
      child: SizedBox(
        width: double.infinity,
        height: reservedHeight,
        child: (_loaded && ad != null)
            ? Center(
                child: SizedBox(
                  width: ad.size.width.toDouble(),
                  height: ad.size.height.toDouble(),
                  child: AdWidget(ad: ad),
                ),
              )
            : const SizedBox.shrink(), // reserved but empty until an ad loads
      ),
    );
  }
}

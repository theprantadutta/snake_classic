import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/services/ads/ad_config.dart';
import 'package:snake_classic/services/ads/ad_service.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';

/// A self-contained anchored banner (full-width anchored adaptive).
///
/// For non-Pro mobile users it **reserves the banner height from the very
/// first frame** — before the SDK is ready and before any ad has filled — so the
/// page never shifts when the ad pops in a moment later. The reserved box is
/// empty until an ad loads, then the ad fills it in place.
///
/// For Pro users and non-mobile platforms it takes **zero space, from the first
/// render** — and it reacts to premium status (via [BlocBuilder]) so a
/// mid-session upgrade collapses the space immediately.
///
/// Loading is resilient, not one-shot:
/// - If the widget mounts before [AdService] finishes initializing (the
///   cold-start home screen always does — UMP consent takes seconds), it
///   listens on [AdService.adsEnabledListenable] and loads the moment ads
///   come online, instead of staying blank for the screen's whole life.
/// - A failed load (routine no-fill) retries with capped backoff. AdMob's
///   auto-refresh only starts after a first successful fill, so without this
///   one no-fill meant a permanently empty reserved box.
class SnakeBannerAd extends StatefulWidget {
  const SnakeBannerAd({super.key});

  @override
  State<SnakeBannerAd> createState() => _SnakeBannerAdState();
}

class _SnakeBannerAdState extends State<SnakeBannerAd> {
  // Retry backoff for failed loads (no-fill / network). Capped: after the last
  // entry the widget gives up for its lifetime — a fresh screen tries again.
  static const List<Duration> _retryDelays = [
    Duration(seconds: 2),
    Duration(seconds: 8),
    Duration(seconds: 30),
  ];

  // The anchored adaptive size is device-wide and orientation-fixed (the app
  // is portrait-locked), so resolve it once per session and share it: every
  // later banner reserves the exact final height from its very first frame.
  static AnchoredAdaptiveBannerAdSize? _adaptiveSize;
  static Future<void>? _adaptiveSizeResolving;

  BannerAd? _ad;
  bool _loaded = false;
  bool _loading = false;
  int _failedAttempts = 0;
  Timer? _retryTimer;
  bool _sizeRequested = false;

  AdService? get _ads =>
      GetIt.I.isRegistered<AdService>() ? GetIt.I<AdService>() : null;

  @override
  void initState() {
    super.initState();
    // Late-init recovery: if the SDK isn't ready yet, load as soon as it is.
    _ads?.adsEnabledListenable.addListener(_onAdsEnabledChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sizeRequested) return;
    _sizeRequested = true;
    final width = MediaQuery.sizeOf(context).width.truncate();
    unawaited(_ensureAdaptiveSize(width).then((_) {
      if (mounted) setState(() {}); // reserve the exact height once known
      _maybeLoad();
    }));
  }

  /// Resolve the anchored adaptive size once per session (deduped across all
  /// banner instances). Falls back to the fixed 320×50 [AdSize.banner] when
  /// the platform can't provide one.
  static Future<void> _ensureAdaptiveSize(int width) {
    if (_adaptiveSize != null) return Future.value();
    return _adaptiveSizeResolving ??= () async {
      try {
        // The non-deprecated replacement is the "Large" anchored adaptive
        // variant, which may grow up to 15% of screen height — unacceptable
        // for a banner anchored over gameplay. The classic anchored adaptive
        // size is the right fit here; the deprecation is accepted knowingly.
        _adaptiveSize = await AdSize
            // ignore: deprecated_member_use
            .getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
      } catch (_) {
        _adaptiveSize = null; // fall back to AdSize.banner
      }
    }();
  }

  void _onAdsEnabledChanged() {
    if (_ads?.adsEnabledListenable.value ?? false) _maybeLoad();
  }

  void _maybeLoad() {
    if (!mounted || _loading || _ad != null) return;
    final ads = _ads;
    if (ads == null || !ads.adsEnabled) return;

    _loading = true;
    final ad = BannerAd(
      adUnitId: AdConfig.bannerUnitId,
      size: _adaptiveSize ?? AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          if (GetIt.I.isRegistered<AnalyticsFacade>()) {
            GetIt.I<AnalyticsFacade>().trackAdImpression(format: 'banner');
          }
          setState(() {
            _ad = ad as BannerAd;
            _loaded = true;
            _loading = false;
            _failedAttempts = 0;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _loading = false;
          _scheduleRetry();
        },
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
          if (GetIt.I.isRegistered<AnalyticsFacade>()) {
            GetIt.I<AnalyticsFacade>().trackAdRevenue(
              format: 'banner',
              valueMicros: valueMicros,
              currencyCode: currencyCode,
              precision: precision.name,
            );
          }
        },
      ),
    );
    ad.load();
  }

  void _scheduleRetry() {
    if (!mounted || _failedAttempts >= _retryDelays.length) return;
    final delay = _retryDelays[_failedAttempts];
    _failedAttempts++;
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () {
      if (mounted) _maybeLoad();
    });
  }

  @override
  void dispose() {
    _ads?.adsEnabledListenable.removeListener(_onAdsEnabledChanged);
    _retryTimer?.cancel();
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when premium status changes so Pro users never reserve space
    // (even on the first frame) and a mid-session upgrade collapses it at once.
    return BlocBuilder<PremiumCubit, PremiumState>(
      builder: (context, _) {
        final reserve = _ads?.shouldReserveBannerSpace ?? false;

        // Pro / non-mobile → zero footprint from the first render.
        if (!reserve) return const SizedBox.shrink();

        // Non-Pro mobile → reserve the banner height NOW, regardless of
        // SDK/ad load state, so the layout never shifts. Empty until filled.
        // The adaptive height resolves in a platform call lasting milliseconds
        // — long before any ad could fill — so the 320×50 fallback height is
        // only ever visible when no adaptive size exists at all.
        final ad = _ad;
        final reservedHeight =
            (_adaptiveSize?.height ?? AdSize.banner.height).toDouble();
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
                : const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

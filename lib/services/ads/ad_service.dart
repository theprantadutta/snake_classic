import 'dart:async';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/services/ads/ad_config.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/connectivity_service.dart';
import 'package:snake_classic/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central AdMob wrapper: owns the SDK init + consent, preloads interstitial /
/// rewarded ads, enforces the **Pro gate** (Pro users never see ads),
/// the **connectivity gate**, and an interstitial **frequency cap**.
///
/// Mobile-only: no-ops on web/desktop. Reward grants happen in the calling
/// code (placement-specific), not here — see the rewarded placements.
class AdService {
  // ---- tunables ----
  // Show on every 4th game-over. The min-gap below is the real UX guard — it
  // stops rapid-fire ads during a hot streak — and counting 4 games keeps the
  // interstitial a rare interruption rather than a constant one.
  static const int _interstitialEveryNGames = 4;
  static const Duration _interstitialMinGap = Duration(minutes: 5);

  // Minimum spacing between ANY two full-screen ads (interstitial / rewarded /
  // app-open), so an opt-in rewarded watch can't be chased by an interstitial
  // seconds later — that combination is policy-fine but *feels* like an ad
  // ambush. Tracked in-memory only; a restart resetting it is acceptable.
  static const Duration _fullScreenAdMinGap = Duration(minutes: 5);

  // App Open ads expire 4h after load (Google's documented limit). We only show
  // one on a genuine return after the user has been AWAY for [_appOpenMinAway]
  // — so a quick app-switch (checking a message, a share sheet) never pops an
  // ad — and never more than once per [_appOpenMinGap].
  static const Duration _appOpenExpiry = Duration(hours: 4);
  static const Duration _appOpenMinGap = Duration(minutes: 15);
  static const Duration _appOpenMinAway = Duration(minutes: 3);

  // Backoff for a failed load. AdMob no-fill is routine — especially without
  // mediation — and until this existed a single failure left that format empty
  // for the rest of the session, which is the main reason an ad "wasn't ready"
  // when the user asked for one. The tail is long on purpose: fill often
  // recovers minutes later, and a retry costs nothing when nothing is loaded.
  static const List<Duration> _loadRetryDelays = [
    Duration(seconds: 2),
    Duration(seconds: 10),
    Duration(seconds: 45),
    Duration(minutes: 3),
    Duration(minutes: 10),
  ];

  // Keep two rewarded ads warm, so a second "watch for coins" straight after
  // the first doesn't meet a disabled button while the replacement loads.
  static const int _rewardedBufferTarget = 2;

  // One banner is kept loaded and handed to the next placement that mounts, so
  // the strip fills on its FIRST frame instead of a second or two later. Held
  // ads go stale; a spare older than this is dropped rather than shown.
  static const Duration _warmBannerMaxAge = Duration(minutes: 30);

  // Retry bucket keys.
  static const String _kLoadInterstitial = 'interstitial';
  static const String _kLoadRewarded = 'rewarded';
  static const String _kLoadAppOpen = 'app_open';
  static const String _kLoadBanner = 'banner';

  // SharedPreferences keys (device-only, never synced).
  static const _kGamesSinceInterstitial = 'ads_games_since_interstitial';
  static const _kLastInterstitialMs = 'ads_last_interstitial_ms';
  // The very first game-over ever is exempt from the interstitial (don't greet
  // a brand-new player with an ad). Key string kept from the old
  // "first session" naming so existing installs don't get a second free pass.
  static const _kFirstGameOverDone = 'ads_first_session_done';

  bool _initialized = false;
  bool _sdkReady = false;
  bool _consentGathered = false;
  // UMP's verdict on whether ad requests are allowed at all (e.g. an EEA user
  // who fully declined consent). Fail-open: a failed query never disables ads.
  bool _canRequestAds = true;
  // Whether UMP says a privacy-options entry point should be offered. Only
  // true when a consent form is actually available + required for this user —
  // so we never surface a "Privacy & ad choices" button that opens nothing
  // (e.g. when no form is configured in the AdMob console, or consent isn't
  // required in the user's region).
  bool _privacyOptionsRequired = false;

  InterstitialAd? _interstitial;
  bool _interstitialLoading = false;

  // A small buffer rather than a single ad — see [_rewardedBufferTarget].
  final List<RewardedAd> _rewardedPool = [];
  int _rewardedLoading = 0;

  // One banner loaded ahead of the widget that will show it. A BannerAd can
  // only be attached to one AdWidget at a time, so this is a hand-off, not a
  // shared instance: the widget takes ownership and a replacement is loaded.
  BannerAd? _warmBanner;
  int _warmBannerLoadedAtMs = 0;
  bool _warmBannerLoading = false;
  AdSize? _bannerSize;

  // Per-format retry state for [_loadRetryDelays].
  final Map<String, int> _loadAttempts = {};
  final Map<String, Timer> _retryTimers = {};

  ConnectivityService? _connectivity;
  bool _lastHadInternet = true;
  StreamSubscription<PremiumState>? _premiumSub;
  bool _wasPro = false;

  AppOpenAd? _appOpenAd;
  bool _appOpenLoading = false;
  int _appOpenLoadedAtMs = 0;
  int _lastAppOpenShownMs = 0;
  // When ANY full-screen ad was last dismissed — see [_fullScreenAdMinGap].
  int _lastFullScreenAdMs = 0;
  // When the app last went to background — App Open only shows after the user
  // has been away at least [_appOpenMinAway].
  int _backgroundedAtMs = 0;

  // True while ANY of our full-screen ads (interstitial / rewarded / app-open)
  // is on screen, so the three can never stack.
  bool _fullScreenAdShowing = false;
  // True only after a real background→foreground round trip, so an App Open ad
  // never shows on the first cold start (over the splash).
  bool _wasInBackground = false;
  // One-shot suppression for returns from flows we launch ourselves (a purchase
  // sheet, the consent form) where an App Open ad would be jarring / off-policy.
  bool _suppressNextAppOpen = false;
  // Set by the game screen; we never cover live/paused gameplay with App Open.
  bool _gameInProgress = false;

  SharedPreferences? _prefs;

  bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  bool get _isPro {
    if (!GetIt.I.isRegistered<PremiumCubit>()) return false;
    return GetIt.I<PremiumCubit>().state.hasPremium;
  }

  /// Whether the DEVICE can reach the internet.
  ///
  /// Deliberately not [ConnectivityService.isOnline], which is
  /// `network && internet && backendReachable`. AdMob has nothing to do with
  /// our backend, so gating ad loads on `isOnline` meant an outage or a slow
  /// cold start on OUR server silently stopped every ad in the app from
  /// loading — with no retry, for the rest of the session. Fail-open when the
  /// service isn't registered yet.
  bool get _hasInternet {
    final service = _connectivity ??
        (GetIt.I.isRegistered<ConnectivityService>()
            ? GetIt.I<ConnectivityService>()
            : null);
    return service?.hasInternetAccess ?? true;
  }

  AnalyticsFacade? get _analytics =>
      GetIt.I.isRegistered<AnalyticsFacade>() ? GetIt.I<AnalyticsFacade>() : null;

  /// The single master switch. Everything checks this.
  bool get adsEnabled => _sdkReady && _isMobile && !_isPro && _canRequestAds;

  // Flipped whenever [adsEnabled] may have changed (SDK became ready, consent
  // changed). Lets widgets created BEFORE init finished (the cold-start home
  // screen banner) load their ad the moment ads come online instead of staying
  // blank for the screen's whole life.
  final ValueNotifier<bool> _adsEnabledNotifier = ValueNotifier(false);
  ValueListenable<bool> get adsEnabledListenable => _adsEnabledNotifier;
  void _notifyAdsEnabled() => _adsEnabledNotifier.value = adsEnabled;

  /// Whether a banner placement should reserve its fixed height up front.
  /// True for any non-Pro mobile user — deliberately INDEPENDENT of SDK
  /// readiness and whether an ad has filled — so the space is reserved from the
  /// very first frame and the page never shifts when the ad pops in later.
  /// Pro users and non-mobile platforms reserve nothing (zero footprint).
  bool get shouldReserveBannerSpace => _isMobile && !_isPro;

  /// Bumped every time a re-arm happens (network returned, consent changed,
  /// Pro lapsed). Widgets that own their own ad — the banner — listen and try
  /// again instead of staying empty after they exhausted their own backoff.
  final ValueNotifier<int> _rearmNotifier = ValueNotifier(0);
  ValueListenable<int> get rearmListenable => _rearmNotifier;

  /// A rewarded ad is loaded and ready to show right now.
  bool get isRewardedReady => adsEnabled && _rewardedPool.isNotEmpty;

  /// Push-based readiness for the "watch an ad" buttons. Without it they poll
  /// on a 2s timer, so the button can sit disabled for up to two seconds after
  /// the ad is genuinely ready — and burns a periodic rebuild forever.
  final ValueNotifier<bool> _rewardedReadyNotifier = ValueNotifier(false);
  ValueListenable<bool> get rewardedReadyListenable => _rewardedReadyNotifier;
  void _notifyRewardedReady() =>
      _rewardedReadyNotifier.value = isRewardedReady;

  // ==================== Load retry ====================

  /// Schedule a backoff retry for [key]. Gives up after the last delay; a
  /// [_rearmAll] (network back, consent granted, Pro lapsed) resets the count.
  void _scheduleRetry(String key, void Function() load) {
    if (!adsEnabled) return;
    final attempt = _loadAttempts[key] ?? 0;
    if (attempt >= _loadRetryDelays.length) return;
    _loadAttempts[key] = attempt + 1;
    _retryTimers.remove(key)?.cancel();
    _retryTimers[key] = Timer(_loadRetryDelays[attempt], load);
  }

  void _clearRetry(String key) {
    _loadAttempts[key] = 0;
    _retryTimers.remove(key)?.cancel();
  }

  /// Reset every backoff and kick a fresh load of everything. Called on the
  /// three transitions that take ads from "cannot load" to "can": the device
  /// regaining internet, consent changing, and Pro lapsing.
  void _rearmAll() {
    if (!adsEnabled) return;
    _loadAttempts.clear();
    for (final timer in _retryTimers.values) {
      timer.cancel();
    }
    _retryTimers.clear();
    _loadInterstitial();
    _loadRewarded();
    _loadAppOpen();
    _loadWarmBanner();
    _rearmNotifier.value++;
  }

  void _onConnectivityChanged() {
    final hasInternet = _hasInternet;
    if (hasInternet && !_lastHadInternet) {
      AppLogger.info('Network returned — re-arming ad preloads');
      _rearmAll();
    }
    _lastHadInternet = hasInternet;
  }

  /// Call when premium status changes. A lapsed subscription turns ads back
  /// on, and nothing would otherwise start loading until the next app launch.
  void onPremiumChanged() {
    _notifyAdsEnabled();
    if (adsEnabled) {
      _rearmAll();
    } else {
      // Became Pro — stop paying for ads nobody will see.
      for (final timer in _retryTimers.values) {
        timer.cancel();
      }
      _retryTimers.clear();
      _notifyRewardedReady();
    }
  }

  // ==================== Init + consent ====================

  Future<void> initialize() async {
    if (_initialized || !_isMobile) return;
    _initialized = true;
    try {
      _prefs = await SharedPreferences.getInstance();

      // Watch connectivity so a load that failed while offline gets another
      // chance the moment the device is back, instead of leaving the session
      // ad-free. Registered before anything can fail below.
      if (GetIt.I.isRegistered<ConnectivityService>()) {
        _connectivity = GetIt.I<ConnectivityService>();
        _lastHadInternet = _connectivity!.hasInternetAccess;
        _connectivity!.addListener(_onConnectivityChanged);
      }

      // A lapsed subscription turns ads back on mid-session. Without this,
      // nothing would start loading until the next app launch, so the first
      // ad the ex-Pro user met would always be a cold one.
      if (GetIt.I.isRegistered<PremiumCubit>()) {
        final premium = GetIt.I<PremiumCubit>();
        _wasPro = premium.state.hasPremium;
        _premiumSub = premium.stream.listen((state) {
          if (state.hasPremium == _wasPro) return;
          _wasPro = state.hasPremium;
          onPremiumChanged();
        });
      }

      // Brand safety for an all-ages arcade game: never serve creatives above
      // PG (blocks gambling / mature ads). Applies to all builds — debug
      // already uses Google's test ad UNIT ids, so no test-device config is
      // needed here.
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(maxAdContentRating: MaxAdContentRating.pg),
      );

      // Start the SDK IN PARALLEL with consent rather than after it. Consent
      // is a network round trip that can also present a form, so awaiting it
      // first delayed every preload by seconds on a cold start. Only the ad
      // REQUEST has to wait for consent, and it still does — the loads below
      // run after both futures, gated on `_canRequestAds`.
      final sdkReady = MobileAds.instance.initialize();
      await _gatherConsentAndAtt();
      await _refreshCanRequestAds();
      await sdkReady;

      _sdkReady = true;
      AppLogger.success('AdService initialized (ads ${adsEnabled ? 'on' : 'off'})');
      if (adsEnabled) {
        _loadInterstitial();
        _loadRewarded();
        _loadAppOpen();
        _loadWarmBanner();
      }
    } catch (e) {
      AppLogger.error('AdService init failed', e);
    } finally {
      _notifyAdsEnabled();
    }
  }

  /// Ask UMP whether ad requests are allowed under the current consent state.
  /// Fail-open — a failed query never turns ads off.
  Future<void> _refreshCanRequestAds() async {
    try {
      _canRequestAds = await ConsentInformation.instance.canRequestAds();
    } catch (_) {
      _canRequestAds = true;
    }
  }

  /// UMP (GDPR) consent + iOS ATT. Never throws — ads just stay off on failure.
  Future<void> _gatherConsentAndAtt() async {
    try {
      final params = ConsentRequestParameters();
      final completer = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () async {
          try {
            await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
          } catch (_) {}
          if (!completer.isCompleted) completer.complete();
        },
        (FormError error) {
          AppLogger.warning('UMP consent update failed: ${error.message}');
          if (!completer.isCompleted) completer.complete();
        },
      );
      await completer.future;
      _consentGathered = true;
      // Cache whether a privacy-options form should be offered, so the
      // Settings entry point can gate on it synchronously.
      try {
        final status = await ConsentInformation.instance
            .getPrivacyOptionsRequirementStatus();
        _privacyOptionsRequired =
            status == PrivacyOptionsRequirementStatus.required;
      } catch (_) {
        _privacyOptionsRequired = false;
      }
    } catch (e) {
      AppLogger.warning('Consent gathering errored: $e');
    }

    // iOS App Tracking Transparency — request once if undetermined.
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final status =
            await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.notDetermined) {
          await AppTrackingTransparency.requestTrackingAuthorization();
        }
      }
    } catch (_) {/* ATT optional — ignore */}
  }

  /// Whether a "Privacy & ad choices" entry point should be shown. False when
  /// no consent form is available/required (so we don't show a dead button).
  bool get privacyOptionsRequired => _privacyOptionsRequired;

  /// Re-show the consent form so users can change their choice (Settings).
  /// Returns true if the form was shown, false if it failed (e.g. no form is
  /// configured for this app ID in the AdMob console).
  Future<bool> showPrivacyOptions() async {
    final completer = Completer<bool>();
    try {
      await ConsentForm.showPrivacyOptionsForm((FormError? error) {
        if (!completer.isCompleted) completer.complete(error == null);
      });
    } catch (e) {
      AppLogger.warning('Privacy options form failed: $e');
      if (!completer.isCompleted) completer.complete(false);
    }
    final shown = await completer.future;
    // The user may have just granted or revoked consent — re-derive whether
    // ads can be requested and (re)start preloading if they just came on.
    await _refreshCanRequestAds();
    _notifyAdsEnabled();
    // Consent may have just been granted, which is one of the transitions from
    // "cannot load" to "can" — reset any exhausted backoff, don't just retry.
    _rearmAll();
    return shown;
  }

  bool get consentGathered => _consentGathered;

  // ==================== Interstitial ====================

  void _loadInterstitial() {
    if (!adsEnabled || _interstitial != null || _interstitialLoading) return;
    if (!_hasInternet) return;
    _interstitialLoading = true;
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.onPaidEvent = (ad, valueMicros, precision, currencyCode) {
            _analytics?.trackAdRevenue(
              format: 'interstitial',
              valueMicros: valueMicros,
              currencyCode: currencyCode,
              precision: precision.name,
            );
          };
          _interstitial = ad;
          _interstitialLoading = false;
          _clearRetry(_kLoadInterstitial);
        },
        onAdFailedToLoad: (error) {
          _interstitial = null;
          _interstitialLoading = false;
          AppLogger.warning('Interstitial failed to load: ${error.message}');
          _scheduleRetry(_kLoadInterstitial, _loadInterstitial);
        },
      ),
    );
  }

  /// Warm an interstitial ahead of the moment it might show. Called when a
  /// game STARTS: that buys a minute or two of load time before the game-over
  /// where the ad is actually offered, so a cold or failed startup load has
  /// recovered by then instead of being discovered empty at show time.
  void preloadInterstitial() => _loadInterstitial();

  /// Show an interstitial if the frequency cap allows. Call this on game-over.
  /// Returns true if an ad was shown. Counts the game regardless.
  Future<bool> maybeShowInterstitialOnGameOver() async {
    if (!adsEnabled) return false;
    final prefs = _prefs;
    if (prefs == null) return false;

    // Very first game-over ever → never interrupt; just mark it done.
    if (!(prefs.getBool(_kFirstGameOverDone) ?? false)) {
      await prefs.setBool(_kFirstGameOverDone, true);
      return false;
    }

    final games = (prefs.getInt(_kGamesSinceInterstitial) ?? 0) + 1;
    final lastMs = prefs.getInt(_kLastInterstitialMs) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    // The gap counts from the last interstitial AND from any other full-screen
    // ad (rewarded / app-open) — no back-to-back full-screen ads, ever.
    final gapOk = now - lastMs >= _interstitialMinGap.inMilliseconds &&
        now - _lastFullScreenAdMs >= _fullScreenAdMinGap.inMilliseconds;

    if (games < _interstitialEveryNGames || !gapOk || _interstitial == null) {
      await prefs.setInt(_kGamesSinceInterstitial, games);
      _loadInterstitial();
      return false;
    }

    final ad = _interstitial!;
    final shown = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _fullScreenAdShowing = false;
        _lastFullScreenAdMs = DateTime.now().millisecondsSinceEpoch;
        ad.dispose();
        _interstitial = null;
        if (!shown.isCompleted) shown.complete(true);
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _fullScreenAdShowing = false;
        ad.dispose();
        _interstitial = null;
        if (!shown.isCompleted) shown.complete(false);
        _loadInterstitial();
      },
    );
    _fullScreenAdShowing = true;
    _analytics?.trackAdImpression(format: 'interstitial', placement: 'game_over');
    await ad.show();
    await prefs.setInt(_kGamesSinceInterstitial, 0);
    await prefs.setInt(
        _kLastInterstitialMs, DateTime.now().millisecondsSinceEpoch);
    return shown.future;
  }

  // ==================== Rewarded ====================

  /// Top the rewarded buffer back up to [_rewardedBufferTarget]. The counter is
  /// incremented synchronously before each async load, so the loop terminates
  /// and concurrent calls can't over-request.
  void _loadRewarded() {
    if (!adsEnabled || !_hasInternet) return;
    while (_rewardedPool.length + _rewardedLoading < _rewardedBufferTarget) {
      _rewardedLoading++;
      RewardedAd.load(
        adUnitId: AdConfig.rewardedUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            ad.onPaidEvent = (ad, valueMicros, precision, currencyCode) {
              _analytics?.trackAdRevenue(
                format: 'rewarded',
                valueMicros: valueMicros,
                currencyCode: currencyCode,
                precision: precision.name,
              );
            };
            _rewardedLoading--;
            _rewardedPool.add(ad);
            _clearRetry(_kLoadRewarded);
            _notifyRewardedReady();
          },
          onAdFailedToLoad: (error) {
            _rewardedLoading--;
            AppLogger.warning('Rewarded failed to load: ${error.message}');
            _scheduleRetry(_kLoadRewarded, _loadRewarded);
          },
        ),
      );
    }
  }

  /// Eagerly (re)load a rewarded ad — call when entering a screen that offers
  /// one, so it's ready by the time the user taps.
  void preloadRewarded() => _loadRewarded();

  /// Show the rewarded ad. [onReward] fires only if the user earned the reward
  /// (watched to completion) AND **after the ad is dismissed** — never while
  /// it's still on screen. This matters for the revive placement: granting on
  /// the earn callback resumed the game loop behind the ad, so the snake moved
  /// (and re-crashed) before the player closed it. Granting on dismiss means
  /// the player is back in the app when the reward applies.
  ///
  /// The returned future resolves AFTER the ad is dismissed, with whether the
  /// reward was actually granted — so callers can await it for accurate
  /// "did they earn it" feedback. (Previously it resolved as soon as the ad
  /// APPEARED, which was always before the user could earn anything, so the
  /// return value lied to every caller that checked it.)
  ///
  /// Race handling: google_mobile_ads delivers onUserEarnedReward and
  /// onAdDismissedFullScreenContent over the platform channel with NO ordering
  /// guarantee — the earn event regularly lands a beat AFTER dismissal. The
  /// old implementation read `earned` exactly once at dismiss time, so every
  /// time the events arrived flipped, the user watched the whole ad, Google
  /// granted the reward, and the app silently dropped it. Now the earn
  /// handler grants late-arriving rewards itself, plus a short post-dismiss
  /// grace wait before declaring the watch unrewarded.
  Future<bool> showRewarded({
    required VoidCallback onReward,
    String placement = 'unspecified',
  }) async {
    if (!adsEnabled || _rewardedPool.isEmpty) {
      _loadRewarded();
      return false;
    }
    final ad = _rewardedPool.removeAt(0);
    _notifyRewardedReady();
    // Immediately start replacing the one we just took, so a second watch
    // right after this one finds the buffer already topped up.
    _loadRewarded();
    var earned = false;
    var dismissed = false;
    var granted = false;
    final done = Completer<bool>();

    void grantOnce() {
      if (granted) return;
      granted = true;
      _analytics?.trackRewardedCompleted(placement);
      try {
        onReward();
      } catch (e) {
        AppLogger.error('Rewarded onReward callback threw', e);
      }
      if (!done.isCompleted) done.complete(true);
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _fullScreenAdShowing = false;
        _lastFullScreenAdMs = DateTime.now().millisecondsSinceEpoch;
        dismissed = true;
        ad.dispose();
        _loadRewarded();
        if (earned) {
          grantOnce();
          return;
        }
        // Grace window for the earn event arriving after dismissal (the
        // plugin race described above). If it lands within the window the
        // earn handler grants; otherwise the watch genuinely wasn't
        // completed (user closed early).
        Future<void>.delayed(const Duration(milliseconds: 800), () {
          if (!done.isCompleted) {
            done.complete(granted);
            if (!granted) _analytics?.trackRewardedAbandoned(placement);
          }
        });
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _fullScreenAdShowing = false;
        ad.dispose();
        _loadRewarded();
        AppLogger.warning('Rewarded failed to show: ${error.message}');
        if (!done.isCompleted) done.complete(false);
      },
    );
    _fullScreenAdShowing = true;
    _analytics?.trackAdImpression(format: 'rewarded', placement: placement);
    await ad.show(
      onUserEarnedReward: (_, _) {
        earned = true;
        if (dismissed) {
          // The race case: reward event arrived after the dismiss event.
          AppLogger.info('Rewarded earn event arrived post-dismiss — granting');
          grantOnce();
        }
      },
    );
    return done.future;
  }

  // ==================== App Open ====================

  /// The game screen calls this so App Open never covers a live/paused game.
  void setGameActive(bool active) => _gameInProgress = active;

  /// Call before launching a purchase / consent flow so the resume it causes
  /// doesn't pop an App Open ad on return.
  void suppressNextAppOpen() => _suppressNextAppOpen = true;

  /// Record that the app went to background (from the lifecycle observer). Only
  /// a genuine background counts — ignored while our own full-screen ad is up
  /// (those don't represent the user actually leaving the app).
  void markBackgrounded() {
    if (_fullScreenAdShowing) return;
    _wasInBackground = true;
    _backgroundedAtMs = DateTime.now().millisecondsSinceEpoch;
  }

  bool get _appOpenAvailable {
    if (_appOpenAd == null) return false;
    final age = DateTime.now().millisecondsSinceEpoch - _appOpenLoadedAtMs;
    return age < _appOpenExpiry.inMilliseconds;
  }

  void _loadAppOpen() {
    if (!adsEnabled || _appOpenAd != null || _appOpenLoading) return;
    if (!_hasInternet) return;
    _appOpenLoading = true;
    AppOpenAd.load(
      adUnitId: AdConfig.appOpenUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          ad.onPaidEvent = (ad, valueMicros, precision, currencyCode) {
            _analytics?.trackAdRevenue(
              format: 'app_open',
              valueMicros: valueMicros,
              currencyCode: currencyCode,
              precision: precision.name,
            );
          };
          _appOpenAd = ad;
          _appOpenLoadedAtMs = DateTime.now().millisecondsSinceEpoch;
          _appOpenLoading = false;
          _clearRetry(_kLoadAppOpen);
        },
        onAdFailedToLoad: (error) {
          _appOpenAd = null;
          _appOpenLoading = false;
          AppLogger.warning('App Open failed to load: ${error.message}');
          _scheduleRetry(_kLoadAppOpen, _loadAppOpen);
        },
      ),
    );
  }

  /// Eagerly (re)load an App Open ad — call when the app goes to background so
  /// one is ready for the next foreground.
  void preloadAppOpen() => _loadAppOpen();

  /// Show an App Open ad on a genuine return to the foreground, if every guard
  /// passes. Called from the app lifecycle observer on `resumed`.
  ///
  /// Guards (AdMob-compliant): only after a real background→foreground trip
  /// (never on cold start over the splash), only once the user has been away at
  /// least [_appOpenMinAway], never when suppressed (purchase / consent return),
  /// never while another full-screen ad is showing, never over active gameplay,
  /// only with a loaded + unexpired ad, and at most once per [_appOpenMinGap].
  Future<void> maybeShowAppOpenOnResume() async {
    // Consume the one-shot flags up front, regardless of outcome.
    final wasBackground = _wasInBackground;
    _wasInBackground = false;
    final suppressed = _suppressNextAppOpen;
    _suppressNextAppOpen = false;

    if (!adsEnabled) return;
    if (!wasBackground || suppressed) return;
    if (_fullScreenAdShowing || _gameInProgress) return;
    // Only on a genuine return after a real break — a quick app-switch never
    // pops an ad. Keep the loaded ad for the next real return.
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _backgroundedAtMs < _appOpenMinAway.inMilliseconds) return;
    if (!_appOpenAvailable) {
      _loadAppOpen();
      return;
    }
    if (now - _lastAppOpenShownMs < _appOpenMinGap.inMilliseconds) return;
    // Respect the global full-screen spacing too — e.g. the user watched a
    // rewarded ad, briefly left, and came right back.
    if (now - _lastFullScreenAdMs < _fullScreenAdMinGap.inMilliseconds) return;

    final ad = _appOpenAd!;
    _appOpenAd = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _fullScreenAdShowing = false;
        final nowMs = DateTime.now().millisecondsSinceEpoch;
        _lastAppOpenShownMs = nowMs;
        _lastFullScreenAdMs = nowMs;
        ad.dispose();
        _loadAppOpen();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _fullScreenAdShowing = false;
        ad.dispose();
        AppLogger.warning('App Open failed to show: ${error.message}');
        _loadAppOpen();
      },
    );
    _fullScreenAdShowing = true;
    _analytics?.trackAdImpression(format: 'app_open');
    await ad.show();
  }

  // ==================== Banner warm-up ====================
  //
  // A BannerAd can only be attached to ONE AdWidget at a time, so a banner
  // cannot be shared between screens the way a full-screen ad is reused. What
  // it CAN do is be loaded before the widget that will display it exists: this
  // keeps exactly one loaded banner and hands ownership to the next placement
  // that mounts, which is why the strip fills on its first frame rather than a
  // second or two in.
  //
  // Depth is deliberately one. An impression is only counted when the ad is
  // displayed, so a spare that is never shown is a wasted request — harmless
  // in small numbers, but a deep pool would drag the match rate down for no
  // benefit, since only one banner is on screen at a time anyway.
  //
  // The subtle part is what happens AFTER the hand-off. A BannerAd's listener
  // is final — fixed at construction — so the listener built here keeps firing
  // for the whole life of the ad, including once a widget owns it. AdMob
  // auto-refreshes a displayed banner roughly once a minute and calls
  // onAdLoaded again each time. Treating that as "a warm banner is ready"
  // re-armed the slot with an ad that was on screen, and the next placement to
  // mount got the same BannerAd — which Flutter rejects with "This AdWidget is
  // already in the Widget tree". Ownership is therefore tracked, and a refresh
  // for an ad we no longer own is forwarded to its owner instead.

  /// Refresh hooks for banners a widget has taken ownership of, keyed by the
  /// ad itself. Non-null means "handed out — not ours to give away again".
  ///
  /// An [Expando] rather than a Set/Map on purpose: it holds the ad weakly, so
  /// a placement torn down without releasing cannot pin a dead banner in
  /// memory for the rest of the session.
  final Expando<void Function()> _bannerOwners = Expando<void Function()>();

  /// Register the anchored adaptive size once the banner widget has resolved
  /// it for this device. The app is portrait-locked, so it is stable for the
  /// session — and the warm banner must be the same size as the placement it
  /// will fill.
  void setBannerSize(AdSize size) {
    if (_bannerSize == size) return;
    _bannerSize = size;
    // A spare at the old size can't fill a placement at the new one.
    _warmBanner?.dispose();
    _warmBanner = null;
    _loadWarmBanner();
  }

  /// Hand the warm banner to a placement mounting right now, transferring
  /// ownership (the caller disposes it, via [releaseBanner]), and start loading
  /// a replacement. Returns null when none is ready or the spare has gone stale
  /// — the widget then loads its own, exactly as before.
  ///
  /// [onRefreshed] fires when AdMob auto-refreshes the ad while the caller
  /// still owns it. The caller needs this because the ad carries THIS
  /// listener, not the caller's: without it a warm-served banner would silently
  /// stop counting impressions on refresh, while a self-loaded one kept
  /// counting them.
  BannerAd? takeWarmBanner(AdSize size, {required void Function() onRefreshed}) {
    final ad = _warmBanner;
    if (ad == null || _bannerSize != size) {
      _loadWarmBanner();
      return null;
    }
    _warmBanner = null;
    final age = DateTime.now().millisecondsSinceEpoch - _warmBannerLoadedAtMs;
    if (age > _warmBannerMaxAge.inMilliseconds) {
      ad.dispose();
      _loadWarmBanner();
      return null;
    }
    _bannerOwners[ad] = onRefreshed;
    _loadWarmBanner();
    AppLogger.info('Banner served from warm cache (no load wait)');
    return ad;
  }

  /// Give up ownership of a banner taken from [takeWarmBanner], immediately
  /// before disposing it. After this the ad is dead, so its refresh hook must
  /// not be called again.
  void releaseBanner(BannerAd ad) => _bannerOwners[ad] = null;

  void _loadWarmBanner() {
    if (!adsEnabled || !_hasInternet) return;
    final size = _bannerSize;
    if (size == null || _warmBanner != null || _warmBannerLoading) return;
    _warmBannerLoading = true;
    final ad = BannerAd(
      adUnitId: AdConfig.bannerUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          final banner = ad as BannerAd;

          // An auto-refresh of an ad a placement already owns. It is in the
          // widget tree right now, so putting it back in the warm slot would
          // hand the same BannerAd to a second AdWidget. Tell the owner it
          // refreshed (that is their impression) and leave the slot alone —
          // including _warmBannerLoading, which belongs to a different,
          // genuinely in-flight request.
          final owner = _bannerOwners[banner];
          if (owner != null) {
            owner();
            return;
          }

          // A load that finished after setBannerSize moved on. Its size no
          // longer matches the placements it would fill, and takeWarmBanner
          // compares against _bannerSize, so it would be handed out at the
          // wrong size rather than rejected.
          if (size != _bannerSize) {
            banner.dispose();
            _warmBannerLoading = false;
            _loadWarmBanner();
            return;
          }

          _warmBanner = banner;
          _warmBannerLoadedAtMs = DateTime.now().millisecondsSinceEpoch;
          _warmBannerLoading = false;
          _clearRetry(_kLoadBanner);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _warmBannerLoading = false;
          AppLogger.warning('Warm banner failed to load: ${error.message}');
          _scheduleRetry(_kLoadBanner, _loadWarmBanner);
        },
        // Revenue is attributed here because this listener travels with the ad
        // into whichever widget displays it. The IMPRESSION is tracked by that
        // widget when it actually renders — a loaded-but-unshown ad is not an
        // impression, and reporting it here would inflate the count.
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
          _analytics?.trackAdRevenue(
            format: 'banner',
            valueMicros: valueMicros,
            currencyCode: currencyCode,
            precision: precision.name,
          );
        },
      ),
    );
    ad.load();
  }

  // ==================== Opt-in rewarded placements ====================
  //
  // Rewarded ads are opt-in (the user chooses to watch for a reward) and pay
  // well, so they are intentionally UNCAPPED — the more a user wants to watch,
  // the better for both them and revenue. The only gate is "is an ad loaded".
  // (The daily caps that used to live here were removed; some placements remain
  // naturally bounded by gameplay — revive/time-bonus once per run, game-over
  // 2× once per screen, daily-bonus/challenge claims once per day.)

  /// Placement identifiers, passed through to [showRewardedCapped] so callers
  /// keep their existing call shape. They no longer impose a cap.
  static const String capFreeCoins = 'free_coins';
  static const String capFreePowerUp = 'free_powerup';
  static const String capBattlePassXp = 'bp_xp';
  static const String capTournamentEntry = 'tournament_entry';

  /// Coins granted per "watch for coins" ad.
  static const int freeCoinsPerAd = 25;

  /// True when a rewarded ad can be shown now (loaded). No daily cap.
  bool canShowCapped(String capKey) => isRewardedReady;

  /// Show a rewarded ad for an opt-in placement. [onReward] fires (on ad
  /// dismiss, via [showRewarded]) only if the user earned it. The [capKey]
  /// doubles as the analytics placement id.
  Future<bool> showRewardedCapped({
    required String capKey,
    required VoidCallback onReward,
  }) =>
      showRewarded(onReward: onReward, placement: capKey);

  /// Convenience wrapper for the free-coins placement.
  Future<bool> showRewardedForCoins({
    required void Function(int coins) onCoins,
  }) =>
      showRewarded(
        onReward: () => onCoins(freeCoinsPerAd),
        placement: capFreeCoins,
      );

  // Back-compat getter used by RewardedCoinsButton.
  bool get canShowFreeCoinAd => isRewardedReady;

  void dispose() {
    _connectivity?.removeListener(_onConnectivityChanged);
    _premiumSub?.cancel();
    for (final timer in _retryTimers.values) {
      timer.cancel();
    }
    _retryTimers.clear();
    _interstitial?.dispose();
    for (final ad in _rewardedPool) {
      ad.dispose();
    }
    _rewardedPool.clear();
    _appOpenAd?.dispose();
    _warmBanner?.dispose();
    _interstitial = null;
    _appOpenAd = null;
    _warmBanner = null;
    _notifyRewardedReady();
  }
}

import 'dart:async';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/services/ads/ad_config.dart';
import 'package:snake_classic/services/connectivity_service.dart';
import 'package:snake_classic/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central AdMob wrapper: owns the SDK init + consent, preloads interstitial /
/// rewarded ads, enforces the **Pro gate** (Pro/trial users never see ads),
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

  // App Open ads expire 4h after load (Google's documented limit). We only show
  // one on a genuine return after the user has been AWAY for [_appOpenMinAway],
  // and never more than once per [_appOpenMinGap] — so a quick app-switch never
  // pops an ad; only coming back to the game after a real break does.
  static const Duration _appOpenExpiry = Duration(hours: 4);
  static const Duration _appOpenMinGap = Duration(minutes: 30);
  static const Duration _appOpenMinAway = Duration(minutes: 30);

  // SharedPreferences keys (device-only, never synced).
  static const _kGamesSinceInterstitial = 'ads_games_since_interstitial';
  static const _kLastInterstitialMs = 'ads_last_interstitial_ms';
  static const _kSessionIsFirst = 'ads_first_session_done';

  bool _initialized = false;
  bool _sdkReady = false;
  bool _consentGathered = false;
  // Whether UMP says a privacy-options entry point should be offered. Only
  // true when a consent form is actually available + required for this user —
  // so we never surface a "Privacy & ad choices" button that opens nothing
  // (e.g. when no form is configured in the AdMob console, or consent isn't
  // required in the user's region).
  bool _privacyOptionsRequired = false;

  InterstitialAd? _interstitial;
  bool _interstitialLoading = false;
  RewardedAd? _rewarded;
  bool _rewardedLoading = false;

  AppOpenAd? _appOpenAd;
  bool _appOpenLoading = false;
  int _appOpenLoadedAtMs = 0;
  int _lastAppOpenShownMs = 0;
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

  bool get _isOnline {
    if (!GetIt.I.isRegistered<ConnectivityService>()) return true;
    return GetIt.I<ConnectivityService>().isOnline;
  }

  /// The single master switch. Everything checks this.
  bool get adsEnabled => _sdkReady && _isMobile && !_isPro;

  /// Whether a banner placement should reserve its fixed height up front.
  /// True for any non-Pro mobile user — deliberately INDEPENDENT of SDK
  /// readiness and whether an ad has filled — so the space is reserved from the
  /// very first frame and the page never shifts when the ad pops in later.
  /// Pro users and non-mobile platforms reserve nothing (zero footprint).
  bool get shouldReserveBannerSpace => _isMobile && !_isPro;

  /// A rewarded ad is loaded and ready to show right now.
  bool get isRewardedReady => adsEnabled && _rewarded != null;

  // ==================== Init + consent ====================

  Future<void> initialize() async {
    if (_initialized || !_isMobile) return;
    _initialized = true;
    try {
      _prefs = await SharedPreferences.getInstance();
      await _gatherConsentAndAtt();
      await MobileAds.instance.initialize();
      if (kDebugMode) {
        // Emulators/sim are test devices automatically; this covers physical
        // dev phones too so we never serve real impressions in debug.
        await MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: const []),
        );
      }
      _sdkReady = true;
      AppLogger.success('AdService initialized (ads ${adsEnabled ? 'on' : 'off'})');
      if (adsEnabled) {
        _loadInterstitial();
        _loadRewarded();
        _loadAppOpen();
      }
    } catch (e) {
      AppLogger.error('AdService init failed', e);
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
    return completer.future;
  }

  bool get consentGathered => _consentGathered;

  // ==================== Interstitial ====================

  void _loadInterstitial() {
    if (!adsEnabled || _interstitial != null || _interstitialLoading) return;
    if (!_isOnline) return;
    _interstitialLoading = true;
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _interstitialLoading = false;
        },
        onAdFailedToLoad: (error) {
          _interstitial = null;
          _interstitialLoading = false;
          AppLogger.warning('Interstitial failed to load: ${error.message}');
        },
      ),
    );
  }

  /// Show an interstitial if the frequency cap allows. Call this on game-over.
  /// Returns true if an ad was shown. Counts the game regardless.
  Future<bool> maybeShowInterstitialOnGameOver() async {
    if (!adsEnabled) return false;
    final prefs = _prefs;
    if (prefs == null) return false;

    // First session ever → never interrupt; just mark it done.
    if (!(prefs.getBool(_kSessionIsFirst) ?? false)) {
      await prefs.setBool(_kSessionIsFirst, true);
      return false;
    }

    final games = (prefs.getInt(_kGamesSinceInterstitial) ?? 0) + 1;
    final lastMs = prefs.getInt(_kLastInterstitialMs) ?? 0;
    final gapOk = DateTime.now().millisecondsSinceEpoch - lastMs >=
        _interstitialMinGap.inMilliseconds;

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
    await ad.show();
    await prefs.setInt(_kGamesSinceInterstitial, 0);
    await prefs.setInt(
        _kLastInterstitialMs, DateTime.now().millisecondsSinceEpoch);
    return shown.future;
  }

  // ==================== Rewarded ====================

  void _loadRewarded() {
    if (!adsEnabled || _rewarded != null || _rewardedLoading) return;
    if (!_isOnline) return;
    _rewardedLoading = true;
    RewardedAd.load(
      adUnitId: AdConfig.rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          _rewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          _rewarded = null;
          _rewardedLoading = false;
          AppLogger.warning('Rewarded failed to load: ${error.message}');
        },
      ),
    );
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
  Future<bool> showRewarded({required VoidCallback onReward}) async {
    if (!adsEnabled || _rewarded == null) {
      _loadRewarded();
      return false;
    }
    final ad = _rewarded!;
    _rewarded = null;
    var earned = false;
    var dismissed = false;
    var granted = false;
    final done = Completer<bool>();

    void grantOnce() {
      if (granted) return;
      granted = true;
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
          if (!done.isCompleted) done.complete(granted);
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
    if (!_isOnline) return;
    _appOpenLoading = true;
    AppOpenAd.load(
      adUnitId: AdConfig.appOpenUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _appOpenLoadedAtMs = DateTime.now().millisecondsSinceEpoch;
          _appOpenLoading = false;
        },
        onAdFailedToLoad: (error) {
          _appOpenAd = null;
          _appOpenLoading = false;
          AppLogger.warning('App Open failed to load: ${error.message}');
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

    final ad = _appOpenAd!;
    _appOpenAd = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _fullScreenAdShowing = false;
        _lastAppOpenShownMs = DateTime.now().millisecondsSinceEpoch;
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
    await ad.show();
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
  /// dismiss, via [showRewarded]) only if the user earned it.
  Future<bool> showRewardedCapped({
    required String capKey,
    required VoidCallback onReward,
  }) =>
      showRewarded(onReward: onReward);

  /// Convenience wrapper for the free-coins placement.
  Future<bool> showRewardedForCoins({
    required void Function(int coins) onCoins,
  }) =>
      showRewarded(onReward: () => onCoins(freeCoinsPerAd));

  // Back-compat getter used by RewardedCoinsButton.
  bool get canShowFreeCoinAd => isRewardedReady;

  void dispose() {
    _interstitial?.dispose();
    _rewarded?.dispose();
    _appOpenAd?.dispose();
    _interstitial = null;
    _rewarded = null;
    _appOpenAd = null;
  }
}

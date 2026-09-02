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

/// Result of an on-demand rewarded watch — see [AdService.showRewardedOrWait].
enum RewardedOutcome {
  /// Watched through; [onReward] has fired.
  rewarded,

  /// An ad was shown but closed before the reward was earned. The player made
  /// that choice — do not apologise to them for it.
  dismissedEarly,

  /// Nothing could be shown (no fill within the wait window, or ads are off).
  /// This is the only outcome that warrants a "try again shortly" message.
  unavailable,
}

/// Central AdMob wrapper: owns the SDK init + consent, preloads interstitial /
/// rewarded ads, enforces the **Pro gate** (Pro users never see ads),
/// the **connectivity gate**, and an interstitial **frequency cap**.
///
/// Mobile-only: no-ops on web/desktop. Reward grants happen in the calling
/// code (placement-specific), not here — see the rewarded placements.
class AdService {
  // ---- tunables ----
  // Show on every 2nd game-over. This was 4, which — with the first-game-over
  // exemption below — meant a player needed FIVE lifetime games before the
  // first interstitial could ever fire. Only ~22% of players reach a fifth
  // game, so the format was switched off for roughly four in five installs.
  // At 2 the first one lands on game three and the cadence reaches ~half the
  // base instead of a fifth of it.
  static const int _interstitialEveryNGames = 2;
  static const Duration _interstitialMinGap = Duration(seconds: 90);

  // Minimum spacing between ANY two full-screen ads (interstitial / rewarded /
  // app-open), so an opt-in rewarded watch can't be chased by an interstitial
  // seconds later — that combination is policy-fine but *feels* like an ad
  // ambush. Tracked in-memory only; a restart resetting it is acceptable.
  //
  // This is the constant that actually binds. A revive is offered on nearly
  // every crash, so at 5 minutes a single rewarded watch blocked the next
  // interstitial for the rest of a typical session no matter what
  // [_interstitialMinGap] said — lowering that alone would have changed
  // nothing. 2 minutes still prevents the back-to-back ambush this guard
  // exists for, without silently cancelling the cadence above.
  static const Duration _fullScreenAdMinGap = Duration(minutes: 2);

  // App Open ads expire 4h after load (Google's documented limit). We only show
  // one on a genuine return after the user has been AWAY for [_appOpenMinAway]
  // — so a quick app-switch (checking a message, a share sheet) never pops an
  // ad — and never more than once per [_appOpenMinGap].
  //
  // These were 15min / 3min, which combined with the guards below produced 25
  // impressions a WEEK across the whole user base — the format was effectively
  // off. 4min / 45s still skips the app-switch case (a share sheet or a glance
  // at a message is back well inside 45 seconds) while letting a genuine return
  // actually count.
  static const Duration _appOpenExpiry = Duration(hours: 4);
  static const Duration _appOpenMinGap = Duration(minutes: 4);
  static const Duration _appOpenMinAway = Duration(seconds: 45);

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

  // How long a "watch an ad" button waits for a load before telling the user
  // nothing is available. Long enough for a normal fill on mobile data, short
  // enough that the button never feels stuck.
  static const Duration _rewardedOnDemandWait = Duration(seconds: 4);

  // Retry bucket keys.
  static const String _kLoadInterstitial = 'interstitial';
  static const String _kLoadRewarded = 'rewarded';
  static const String _kLoadRewardedInterstitial = 'rewarded_interstitial';
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
  // Set once [initialize] has run to completion (success or failure), so a
  // caller waiting on the first rewarded fill can tell "ads are off" apart
  // from "ads aren't on YET". See [waitForRewardedReady].
  bool _initFinished = false;
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

  // Preferred over the plain interstitial in the game-over slot — same
  // interruption, rewarded-tier eCPM, and the player walks away with coins.
  RewardedInterstitialAd? _rewardedInterstitial;
  bool _rewardedInterstitialLoading = false;

  // Completers waiting on an on-demand rewarded load — see
  // [showRewardedOrWait]. Resolved by the load callbacks so a waiting button
  // reacts the instant an ad arrives instead of polling.
  final List<Completer<void>> _rewardedWaiters = [];

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
  void _notifyRewardedReady() {
    _rewardedReadyNotifier.value = isRewardedReady;
    if (!isRewardedReady) return;
    // Wake anything blocked in [showRewardedOrWait] the moment fill arrives.
    for (final waiter in _rewardedWaiters) {
      if (!waiter.isCompleted) waiter.complete();
    }
    _rewardedWaiters.clear();
  }

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
    _loadRewardedInterstitial();
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

      // Ceiling on ad content, matched to the audience we actually declared.
      //
      // Play Console -> App content -> Target audience: 13-15, 16-17, and 18+.
      // No under-13 group, so this app is neither child-directed nor in
      // Designed for Families, and the Families ad restrictions do not apply.
      // T ("Teens") is the rating that maps to a 13+ audience, and the ratings
      // are cumulative — T serves G, PG and T.
      //
      // This was PG, which is the setting for an audience that includes
      // children. That was a guess, and an expensive one: AdMob's own account
      // ceiling is MA with nothing blocked, so PG here was the ONLY thing
      // narrowing the eligible pool, against a 32.84% match rate — two of
      // every three requests coming back empty.
      //
      // Deliberately NOT MA. MA permits alcohol, weapons and sexual content,
      // and 13-15 year olds are inside the declared audience. Legality is not
      // the point; those creatives do not belong next to a snake game.
      //
      // Revisit if the target audience declaration ever changes — this
      // constant and that declaration have to agree, and Play's is the one
      // that binds.
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(maxAdContentRating: MaxAdContentRating.t),
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
        _loadRewardedInterstitial();
        _loadRewarded();
        _loadAppOpen();
        _loadWarmBanner();
      }
    } catch (e) {
      AppLogger.error('AdService init failed', e);
    } finally {
      _initFinished = true;
      _notifyAdsEnabled();
      // Re-evaluate readiness now that the verdict is final, so anything in
      // [waitForRewardedReady] stops waiting when ads turned out to be off.
      _notifyRewardedReady();
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

  // ==================== Rewarded interstitial ====================

  /// A rewarded interstitial is loaded and ready to show right now.
  bool get isRewardedInterstitialReady =>
      adsEnabled && _rewardedInterstitial != null;

  void _loadRewardedInterstitial() {
    if (!adsEnabled || !_hasInternet) return;
    if (_rewardedInterstitial != null || _rewardedInterstitialLoading) return;
    _rewardedInterstitialLoading = true;
    RewardedInterstitialAd.load(
      adUnitId: AdConfig.rewardedInterstitialUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.onPaidEvent = (ad, valueMicros, precision, currencyCode) {
            _analytics?.trackAdRevenue(
              format: 'rewarded_interstitial',
              valueMicros: valueMicros,
              currencyCode: currencyCode,
              precision: precision.name,
            );
          };
          _rewardedInterstitial = ad;
          _rewardedInterstitialLoading = false;
          _clearRetry(_kLoadRewardedInterstitial);
        },
        onAdFailedToLoad: (error) {
          _rewardedInterstitial = null;
          _rewardedInterstitialLoading = false;
          AppLogger.warning(
              'Rewarded interstitial failed to load: ${error.message}');
          _scheduleRetry(
              _kLoadRewardedInterstitial, _loadRewardedInterstitial);
        },
      ),
    );
  }

  /// Show the loaded rewarded interstitial. Returns true if it was displayed.
  ///
  /// [onReward] fires on dismiss, only when the watch was completed — same
  /// contract (and the same plugin event race) as [showRewarded], so the
  /// handling here mirrors it.
  Future<bool> _showRewardedInterstitial({
    required VoidCallback onReward,
    required String placement,
  }) async {
    final ad = _rewardedInterstitial;
    if (ad == null) return false;
    _rewardedInterstitial = null;

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
        AppLogger.error('Rewarded interstitial onReward callback threw', e);
      }
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _fullScreenAdShowing = false;
        _lastFullScreenAdMs = DateTime.now().millisecondsSinceEpoch;
        dismissed = true;
        ad.dispose();
        _loadRewardedInterstitial();
        if (earned) grantOnce();
        // Grace window for an earn event that lands after dismissal.
        Future<void>.delayed(const Duration(milliseconds: 800), () {
          if (!granted) _analytics?.trackRewardedAbandoned(placement);
          if (!done.isCompleted) done.complete(true);
        });
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _fullScreenAdShowing = false;
        ad.dispose();
        _loadRewardedInterstitial();
        AppLogger.warning(
            'Rewarded interstitial failed to show: ${error.message}');
        if (!done.isCompleted) done.complete(false);
      },
    );

    _fullScreenAdShowing = true;
    _analytics?.trackAdImpression(
        format: 'rewarded_interstitial', placement: placement);
    await ad.show(
      onUserEarnedReward: (_, _) {
        earned = true;
        if (dismissed) grantOnce();
      },
    );
    return done.future;
  }

  /// Warm an interstitial ahead of the moment it might show. Called when a
  /// game STARTS: that buys a minute or two of load time before the game-over
  /// where the ad is actually offered, so a cold or failed startup load has
  /// recovered by then instead of being discovered empty at show time.
  void preloadGameOverAd() {
    _loadRewardedInterstitial();
    _loadInterstitial();
  }

  /// Show the game-over ad if the frequency cap allows. Returns true if one
  /// was shown. Counts the game regardless.
  ///
  /// Two formats compete for this one slot. A **rewarded interstitial** is
  /// preferred whenever one is loaded: it is the same single interruption, but
  /// it earns rewarded-tier eCPM instead of interstitial-tier and hands the
  /// player coins on the way out, so it reads as a bonus rather than a toll.
  /// The plain interstitial is the fallback when the rewarded one hasn't
  /// filled — which, at current fill rates, is often.
  ///
  /// [onReward] is only invoked on the rewarded-interstitial path, and only
  /// when the player actually watched it through.
  Future<bool> maybeShowGameOverAd({VoidCallback? onReward}) async {
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
    final haveAd = _rewardedInterstitial != null || _interstitial != null;

    if (games < _interstitialEveryNGames || !gapOk || !haveAd) {
      await prefs.setInt(_kGamesSinceInterstitial, games);
      _loadInterstitial();
      _loadRewardedInterstitial();
      return false;
    }

    // Preferred path: rewarded interstitial. Resets the same counter and gap
    // as the plain one, so the slot fires at one cadence regardless of which
    // format filled it.
    if (_rewardedInterstitial != null) {
      final shown = await _showRewardedInterstitial(
        placement: 'game_over',
        onReward: onReward ?? () {},
      );
      if (shown) {
        await prefs.setInt(_kGamesSinceInterstitial, 0);
        await prefs.setInt(
            _kLastInterstitialMs, DateTime.now().millisecondsSinceEpoch);
        return true;
      }
      // Failed to show — fall through to the plain interstitial if we have one.
      if (_interstitial == null) {
        await prefs.setInt(_kGamesSinceInterstitial, games);
        return false;
      }
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

  /// Wait for the first rewarded ad to be loaded, bounded by [timeout].
  ///
  /// Used by the loading screen so a free user reaches Home with an ad
  /// already in the pool — tapping the Free button then shows it at once
  /// instead of meeting "no ad ready". The loads themselves were already
  /// kicked off from main() via [initialize]; this only waits for the fill.
  ///
  /// Resolves `true` the moment a rewarded ad is ready. Resolves `false`
  /// early — without burning the whole timeout — when there is nothing to
  /// wait for: not a mobile platform, a Pro user, or init finished with ads
  /// disabled (no consent, SDK failure). Never throws.
  Future<bool> waitForRewardedReady({required Duration timeout}) async {
    if (isRewardedReady) return true;
    if (!_isMobile || _isPro) return false;
    if (_initFinished && !adsEnabled) return false;
    if (!_hasInternet) return false;

    final done = Completer<bool>();
    void check() {
      if (done.isCompleted) return;
      if (isRewardedReady) {
        done.complete(true);
      } else if (_initFinished && !adsEnabled) {
        done.complete(false);
      }
    }

    _rewardedReadyNotifier.addListener(check);
    _adsEnabledNotifier.addListener(check);
    try {
      // A load may already be in flight from initialize(); this is a no-op
      // then, and the real request when init finished before the pool
      // filled (e.g. a failed load sitting in backoff).
      if (adsEnabled) _loadRewarded();
      check();
      return await done.future.timeout(timeout, onTimeout: () => false);
    } catch (_) {
      return false;
    } finally {
      _rewardedReadyNotifier.removeListener(check);
      _adsEnabledNotifier.removeListener(check);
    }
  }

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

  /// Show a rewarded ad, waiting briefly for a load if the pool is empty.
  ///
  /// Every "watch an ad" button in the app should call THIS rather than
  /// [showRewarded] directly, and should stay tappable regardless of
  /// [isRewardedReady].
  ///
  /// Gating the buttons on `isRewardedReady` was quietly costing real money:
  /// rewarded is the highest-eCPM format in the app by a wide margin, and at
  /// the fill rates we actually see the pool is empty a lot of the time. So the
  /// button greyed out (or vanished) exactly when the ad was worth the most,
  /// the user never got to ask for it, and the request that would have filled a
  /// second later was never made. Letting the tap through both surfaces the
  /// offer and *triggers* the load.
  ///
  /// The outcome is three-way on purpose. "No ad could be shown" and "the user
  /// watched and closed it early" both leave the reward ungranted, but only the
  /// first one should tell the player to try again later — showing that message
  /// to someone who deliberately skipped the ad reads as a bug.
  Future<RewardedOutcome> showRewardedOrWait({
    required VoidCallback onReward,
    String placement = 'unspecified',
    VoidCallback? onWaitStart,
  }) async {
    if (!adsEnabled) return RewardedOutcome.unavailable;

    if (_rewardedPool.isEmpty) {
      onWaitStart?.call();
      _loadRewarded();
      final waiter = Completer<void>();
      _rewardedWaiters.add(waiter);
      await waiter.future
          .timeout(_rewardedOnDemandWait, onTimeout: () {})
          .catchError((_) {});
      _rewardedWaiters.remove(waiter);
      if (_rewardedPool.isEmpty) return RewardedOutcome.unavailable;
    }

    final granted = await showRewarded(onReward: onReward, placement: placement);
    return granted
        ? RewardedOutcome.rewarded
        : RewardedOutcome.dismissedEarly;
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
    // Idempotent: while a background trip is already in progress, do NOT
    // restart the clock. The trip ends when maybeShowAppOpenOnResume consumes
    // the flag, so a second lifecycle event before that is the same trip.
    //
    // Belt and braces with the caller only passing `paused` now. Anything that
    // re-marks mid-trip resets _backgroundedAtMs, and since the away-gate
    // measures from it, a reset silently means no App Open ad ever shows.
    if (_wasInBackground) return;
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

  /// Placement identifiers. Analytics labels, nothing more — they used to key
  /// the daily caps described above, which is where the old `cap*` naming came
  /// from. The caps went; the names outlived them and read as though a limit
  /// is being consulted when none is.
  static const String placementFreeCoins = 'free_coins';
  static const String placementFreePowerUp = 'free_powerup';
  static const String placementBattlePassXp = 'bp_xp';
  static const String placementTournamentEntry = 'tournament_entry';

  /// Coins granted per "watch for coins" ad.
  static const int freeCoinsPerAd = 25;

  /// Show a rewarded ad for an opt-in placement. [onReward] fires (on ad
  /// dismiss, via [showRewarded]) only if the user earned it. [placement] is
  /// the analytics label.
  Future<bool> showRewardedFor({
    required String placement,
    required VoidCallback onReward,
  }) =>
      showRewarded(onReward: onReward, placement: placement);

  /// Convenience wrapper for the free-coins placement.
  Future<bool> showRewardedForCoins({
    required void Function(int coins) onCoins,
  }) =>
      showRewarded(
        onReward: () => onCoins(freeCoinsPerAd),
        placement: placementFreeCoins,
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
    _rewardedInterstitial?.dispose();
    for (final ad in _rewardedPool) {
      ad.dispose();
    }
    _rewardedPool.clear();
    _appOpenAd?.dispose();
    _warmBanner?.dispose();
    _interstitial = null;
    _rewardedInterstitial = null;
    _appOpenAd = null;
    _warmBanner = null;
    // Release anything blocked in showRewardedOrWait — the pool is gone, so
    // these can never be woken by a load callback now.
    for (final waiter in _rewardedWaiters) {
      if (!waiter.isCompleted) waiter.complete();
    }
    _rewardedWaiters.clear();
    _notifyRewardedReady();
  }
}

/// What the game-over ad slot will do.
enum GameOverAdFormat {
  /// Nothing plays; the button goes straight where it says.
  none,

  /// A rewarded interstitial: one interruption, and the player walks away
  /// with coins for sitting through it.
  rewarded,

  /// A plain interstitial: the fallback when no rewarded one has filled.
  interstitial,
}

/// The rule for the one full-screen ad the game shows on its own initiative.
///
/// Pure, so the game over screen can ask "what happens if I press this?"
/// and tell the player BEFORE they press — the same rule, the same inputs,
/// no side effects. An ad a player was warned about is a toll they agreed
/// to; the same ad springing from a button labelled MENU is the thing
/// reviews complain about.
class GameOverAdGate {
  const GameOverAdGate._();

  static GameOverAdFormat decide({
    required bool firstGameOverDone,
    required int gamesSinceLastAd,
    required int msSinceInterstitial,
    required int msSinceAnyFullScreenAd,
    required bool rewardedLoaded,
    required bool interstitialLoaded,
    required int everyNGames,
    required int minGapMs,
    required int fullScreenGapMs,
  }) =>
      evaluate(
        firstGameOverDone: firstGameOverDone,
        gamesSinceLastAd: gamesSinceLastAd,
        msSinceInterstitial: msSinceInterstitial,
        msSinceAnyFullScreenAd: msSinceAnyFullScreenAd,
        rewardedLoaded: rewardedLoaded,
        interstitialLoaded: interstitialLoaded,
        everyNGames: everyNGames,
        minGapMs: minGapMs,
        fullScreenGapMs: fullScreenGapMs,
      ).format;

  /// [decide], plus which rule settled it. The reason is one of
  /// [GameOverAdReason]; it feeds the `game_over_ad` analytics event, which
  /// exists because the slot fires on roughly 1 game over in 10 against a
  /// cadence of every 2nd, and nothing said which rule was holding it back.
  static ({GameOverAdFormat format, String reason}) evaluate({
    required bool firstGameOverDone,
    required int gamesSinceLastAd,
    required int msSinceInterstitial,
    required int msSinceAnyFullScreenAd,
    required bool rewardedLoaded,
    required bool interstitialLoaded,
    required int everyNGames,
    required int minGapMs,
    required int fullScreenGapMs,
  }) {
    const none = GameOverAdFormat.none;
    // The very first game over of an install never interrupts.
    if (!firstGameOverDone) {
      return (format: none, reason: GameOverAdReason.firstGame);
    }

    // Cadence: this game over is the (gamesSinceLastAd + 1)th since the
    // last ad; the slot opens every N.
    if (gamesSinceLastAd + 1 < everyNGames) {
      return (format: none, reason: GameOverAdReason.cadence);
    }

    // No back-to-back full-screen ads, whatever kind the last one was.
    if (msSinceInterstitial < minGapMs) {
      return (format: none, reason: GameOverAdReason.interstitialGap);
    }
    if (msSinceAnyFullScreenAd < fullScreenGapMs) {
      return (format: none, reason: GameOverAdReason.fullScreenGap);
    }

    if (rewardedLoaded) {
      return (
        format: GameOverAdFormat.rewarded,
        reason: GameOverAdReason.rewarded,
      );
    }
    if (interstitialLoaded) {
      return (
        format: GameOverAdFormat.interstitial,
        reason: GameOverAdReason.interstitial,
      );
    }
    return (format: none, reason: GameOverAdReason.notLoaded);
  }
}

/// The `outcome` values of the `game_over_ad` analytics event: what the
/// game-over slot did, and when it did nothing, why. Exactly one per game
/// over that reaches [AdService.maybeShowGameOverAd].
abstract final class GameOverAdReason {
  // Nothing played, and the rule that said so.
  static const adsOff = 'ads_off'; // Pro, no consent, or SDK not ready
  static const firstGame = 'first_game';
  static const cadence = 'cadence';
  static const interstitialGap = 'interstitial_gap';
  static const fullScreenGap = 'fullscreen_gap'; // e.g. a revive ad just played
  static const notLoaded = 'not_loaded';
  // The screen told the player "no ad" on build; an ad that filled while
  // they read the score is not sprung on them.
  static const toldNone = 'told_none';
  // The screen took the slot back before anything showed (e.g. it closed).
  static const cancelled = 'cancelled';
  static const showFailed = 'show_failed';

  // Something played.
  static const rewarded = 'shown_rewarded_interstitial';
  static const interstitial = 'shown_interstitial';
  // SHORT AD on the rewarded intro: the plain interstitial played instead.
  static const shortAd = 'short_ad';
  // SHORT AD, but no plain interstitial was loaded, so nothing played.
  static const shortAdNone = 'short_ad_unavailable';
}

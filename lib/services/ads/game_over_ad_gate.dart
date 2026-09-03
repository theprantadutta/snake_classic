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
  }) {
    // The very first game over of an install never interrupts.
    if (!firstGameOverDone) return GameOverAdFormat.none;

    // Cadence: this game over is the (gamesSinceLastAd + 1)th since the
    // last ad; the slot opens every N.
    if (gamesSinceLastAd + 1 < everyNGames) return GameOverAdFormat.none;

    // No back-to-back full-screen ads, whatever kind the last one was.
    if (msSinceInterstitial < minGapMs) return GameOverAdFormat.none;
    if (msSinceAnyFullScreenAd < fullScreenGapMs) return GameOverAdFormat.none;

    if (rewardedLoaded) return GameOverAdFormat.rewarded;
    if (interstitialLoaded) return GameOverAdFormat.interstitial;
    return GameOverAdFormat.none;
  }
}

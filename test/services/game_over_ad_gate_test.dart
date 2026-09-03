import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/services/ads/game_over_ad_gate.dart';

/// The one rule behind "will an ad play when I press this?". The game over
/// screen asks it to warn the player, then the press honours the answer.
void main() {
  GameOverAdFormat decide({
    bool firstDone = true,
    int gamesSince = 1,
    int sinceInterstitial = 10 * 60 * 1000,
    int sinceAnyFullScreen = 10 * 60 * 1000,
    bool rewarded = true,
    bool interstitial = true,
  }) =>
      GameOverAdGate.decide(
        firstGameOverDone: firstDone,
        gamesSinceLastAd: gamesSince,
        msSinceInterstitial: sinceInterstitial,
        msSinceAnyFullScreenAd: sinceAnyFullScreen,
        rewardedLoaded: rewarded,
        interstitialLoaded: interstitial,
        everyNGames: 2,
        minGapMs: 90 * 1000,
        fullScreenGapMs: 2 * 60 * 1000,
      );

  test('the first game over of an install never interrupts', () {
    expect(decide(firstDone: false), GameOverAdFormat.none);
  });

  test('the slot opens every second game', () {
    expect(decide(gamesSince: 0), GameOverAdFormat.none,
        reason: 'first game since the last ad');
    expect(decide(gamesSince: 1), isNot(GameOverAdFormat.none),
        reason: 'second game since the last ad');
  });

  test('never back to back: the interstitial gap holds it', () {
    expect(decide(sinceInterstitial: 60 * 1000), GameOverAdFormat.none);
  });

  test('never back to back: any full-screen ad holds it too', () {
    // A rewarded revive a minute ago counts.
    expect(decide(sinceAnyFullScreen: 60 * 1000), GameOverAdFormat.none);
  });

  test('a rewarded interstitial is preferred when loaded', () {
    expect(decide(), GameOverAdFormat.rewarded);
  });

  test('the plain interstitial is the fallback', () {
    expect(decide(rewarded: false), GameOverAdFormat.interstitial);
  });

  test('nothing loaded, nothing plays', () {
    expect(
      decide(rewarded: false, interstitial: false),
      GameOverAdFormat.none,
    );
  });
}

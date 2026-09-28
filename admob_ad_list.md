# AdMob configuration — fill this in

Paste your real AdMob IDs below and hand this file back. Until it's filled,
**debug builds use Google's official test ad IDs**, so the app runs fine
without these. Release builds need the real values.

Where to find these in the AdMob console (https://apps.admob.com):
- **App ID**: AdMob → *Apps* → select the app → *App settings* → "App ID".
  Looks like `ca-app-pub-0000000000000000~1111111111` (note the **`~`**).
  You have a separate app (and App ID) for **Android** and for **iOS**.
- **Ad unit ID**: AdMob → *Apps* → your app → *Ad units* → create one unit per
  format (Banner, Interstitial, Rewarded). Looks like
  `ca-app-pub-0000000000000000/2222222222` (note the **`/`**).
  Create them per platform too (so 3 units × 2 platforms = 6 unit IDs).

> Tip: create the **app** first to get the App ID, then create the 3 ad units
> under it. Do this once for the Android app and once for the iOS app.

---

## 1. App IDs  (go into AndroidManifest.xml / iOS Info.plist)

```
ANDROID_ADMOB_APP_ID = ca-app-pub-9242904787767394~9115144122
IOS_ADMOB_APP_ID     = ca-app-pub-9242904787767394~3519202517
```

## 2. Ad unit IDs  (baked into lib/services/ads/ad_config.dart — they're not secret)

### Android
```
ANDROID_BANNER_AD_UNIT_ID       = ca-app-pub-9242904787767394/3016639636
ANDROID_INTERSTITIAL_AD_UNIT_ID = ca-app-pub-9242904787767394/6572741266
ANDROID_REWARDED_AD_UNIT_ID     = ca-app-pub-9242904787767394/7829982619
```

### iOS
```
IOS_BANNER_AD_UNIT_ID       = ca-app-pub-9242904787767394/3952271184
IOS_INTERSTITIAL_AD_UNIT_ID = ca-app-pub-9242904787767394/9378033857
IOS_REWARDED_AD_UNIT_ID     = ca-app-pub-9242904787767394/3896430862
```

---

## 3. App Open ad units  (LIVE — created and wired)

App Open ads show on a genuine return to the foreground (not cold start, not
during gameplay, not after a purchase). Real units are created in the AdMob
console and baked into `lib/services/ads/ad_config.dart` (debug builds still
use Google's test ids). No manifest change is needed — the App ID already in
`AndroidManifest.xml` covers all formats.

```
ANDROID_APP_OPEN_AD_UNIT_ID = ca-app-pub-9242904787767394/2112367445
IOS_APP_OPEN_AD_UNIT_ID     = ca-app-pub-9242904787767394/9799285770
```

---

## 4. Rewarded interstitial ad units  (LIVE — created and wired)

A full-screen ad that appears WITHOUT an opt-in tap but still pays a reward.
**Google requires US to show an intro screen before it**: clear reward
messaging, enough time to read it, and a clear, unobstructed way to skip. The
SDK does NOT render one. (This file used to say it did, and the app shipped
without an intro until September 2026.) Ours is
`lib/widgets/ads/rewarded_interstitial_intro.dart`: a 5-second countdown,
WATCH NOW, and an equally prominent NO THANKS, with the system back gesture
counting as a skip. A skip plays nothing in its place and uses up the slot.
Console reward is set to **25 Coins**, matching `AdService.freeCoinsPerAd`.

It competes with the plain interstitial for the single game-over slot and wins
whenever one is loaded: same interruption, rewarded-tier eCPM instead of
interstitial-tier, and the player leaves with coins. The plain interstitial is
the fallback for when it hasn't filled.

```
ANDROID_REWARDED_INTERSTITIAL_AD_UNIT_ID = ca-app-pub-9242904787767394/8753884101
IOS_REWARDED_INTERSTITIAL_AD_UNIT_ID     = ca-app-pub-9242904787767394/3391193437
```

---

## What each ad unit is used for in the game
| Format | Where it shows | Notes |
| --- | --- | --- |
| **Rewarded** | Revive after death, Time-Attack +30s, double game-over coins, "2×" daily bonus / challenge claims, free-coins button in store, free power-up, Battle Pass XP, tournament entry | Opt-in only, uncapped; grants a reward on completion (on dismiss). Buttons are **always tappable** — they load on demand via `showRewardedOrWait` rather than greying out when the pool is empty. One ad kept warm (was two) |
| **Rewarded interstitial** | Game-over → Play Again / Menu, preferred over the plain interstitial | Shares the interstitial's cadence and gaps; pays 25 coins when watched through. **Always behind the intro screen** (skippable) |
| **Interstitial** | Game-over → Play Again / Menu, fallback when no rewarded interstitial is loaded | Every 2nd game-over, ≥90 s since the last one and ≥2 min since any full-screen ad; the very first game-over ever is exempt. **Only requested when the rewarded interstitial failed to load.** Preceded by a 0.7 s tap-absorbing "Ad starting…" curtain |
| **Banner** | Most screens; gameplay only for **swipe** players (bottom, 12 px gap) | Anchored **adaptive**; reserves space up front to avoid layout shift; retries failed loads. **Hidden during gameplay when on-screen controls are on.** Game over uses a 20 px gap under Play Again / Menu |
| **App Open** | Genuine return to foreground | Skips cold start, gameplay, and purchase returns; only after **≥30 min away**, at most once per **30 min**; 4-h ad expiry (an expired ad is now dropped and replaced) |

## Frequency tuning — why these numbers  (Aug 2026)

The caps above were retuned after a dashboard audit found the app was earning
~$24/month against 8.5K MAU. The findings, for whoever changes them next:

- **Interstitial was every 4th game-over, and the first game-over is exempt** —
  so a player needed **five lifetime games** before the format could fire once.
  Only ~22% of players ever reach a fifth game, so interstitials were switched
  off for roughly four in five installs. Now every 2nd, first one on game three.
- **`_fullScreenAdMinGap` is the constant that actually binds.** It counts from
  a rewarded or app-open ad too, and a revive is offered on nearly every crash —
  so at 5 minutes one revive watch blocked the next interstitial for the rest of
  a typical session no matter what `_interstitialMinGap` said. Lowering the
  interstitial gap alone changes nothing; lower this one with it.
- **App Open produced 25 impressions a WEEK** across the entire user base at
  15-min / 3-min. Most of that was the `inactive` lifecycle bug (see main.dart),
  not the thresholds. It was cut to 4-min / 45-s, then raised again to
  30-min / 30-min after the September audit below.
- **Rewarded buttons must never gate on `isRewardedReady`.** Rewarded is the
  highest-eCPM format in the app by ~48× over banner, and at real fill rates the
  pool is empty a large share of the time — so gating hid the offer exactly when
  it was worth the most, and the tap that would have kicked a load never
  happened. Use `showRewardedOrWait`, which waits out a short load window and
  returns a three-way [RewardedOutcome] so callers can tell "no ad" apart from
  "user skipped it".

## Ad UX / policy audit  (Sep 28, 2026)

Read against the AdMob console and every AdMob email up to that date. Snake
Classic had **no Policy Center issues**, but the data showed where it was
heading:

- **The rewarded interstitial had no intro screen**, so it did not meet Google's
  requirements for the format (see §4). Fixed with a skippable intro.
- **Accidental clicks.** Interstitial CTR ran 12.8% (Jun) → 19.3% (Jul) →
  **53.2% (Aug)**; rewarded 8% → 26% (Jun → Sep); App Open 17–30%. Full-screen
  ads opened in the same instant as the tap that triggered them, and new
  buttons (game over bar, revive, +30s) were live the moment they appeared under
  a moving thumb. Fixes: `TapArmGuard` on those surfaces, a double-press guard
  on the game over bar, the `AdBreakCurtain` before full-screen ads, and a much
  rarer App Open. **Watch CTR after this ships.** Full-screen CTR back in the
  single digits to low teens means it worked.
- **Banners next to controls.** In gameplay the banner sat 6 px under the
  d-pad; on game over, ~10 px under Play Again. Google's placement policy names
  both. See the Banner row above.
- **Over-requesting.** Sep: interstitial 19.7K requests / 155 impressions
  (1% show rate), App Open 21.7K / 448, rewarded 42K / 2.6K. Each wasted request
  spends a player's data and battery. Fixes: interstitial only as a fallback,
  one rewarded ad kept warm, and expired App Open ads replaced.
- **Consent:** `canRequestAds()` failures now fail closed (they used to allow ads).
- The loading screen held players up to 8 s waiting for a rewarded fill; now 2 s.

Console-side (no code): the GDPR message is published for 6 apps with a 60%
consent rate, but only in **English** while the app ships 9 locales. Add those
languages in *Privacy & messaging → European regulations*. app-ads.txt was 99%
authorized. The app has no location permission, so the GMA SDK's upcoming
coarse-location collection does not apply.

## Mediation  (IN PROGRESS — AppLovin applied for, awaiting approval)

AdMob **mediation** runs a unified auction across multiple ad networks for the
same ad unit, which can lift eCPM ~20–40%. **It is intentionally NOT wired up
yet.** At low traffic the cross-network auction has too little volume to bid
meaningfully, while each adapter adds app size + a third-party SDK that
initializes at startup (data-collection surface) for ~zero return. Turn it on
once you have real scale (roughly **1,000+ DAU**, or when AdMob fill is solid
but you want price competition).

When it's time (Android — the GMA SDK auto-discovers adapters, no Dart changes):

1. Add the adapters to `android/app/build.gradle.kts` `dependencies {}` (check
   each adapter's latest version at
   `dl.google.com/dl/android/maven2/com/google/ads/mediation/<network>`):
   ```
   implementation("com.google.ads.mediation:applovin:13.6.2.0")
   implementation("com.google.ads.mediation:vungle:7.7.4.0")   // Liftoff Monetize
   implementation("com.google.ads.mediation:unity:4.18.0.0")
   // Pangle + Mintegral also need their own Maven repos in android/build.gradle.kts:
   //   maven { url = uri("https://artifact.bytedance.com/repository/pangle") }
   //   maven { url = uri("https://dl-maven-android.mintegral.com/repository/mbridge_android_sdk_oversea") }
   // implementation("com.google.ads.mediation:pangle:8.0.0.5.0")
   // implementation("com.google.ads.mediation:mintegral:17.1.61.0")
   ```
2. In the AdMob console: **Mediation** → **Create mediation group** (per format)
   → add your ad unit(s) → **Add ad source** per network → enter that network's
   credentials (you create an app + placements in *their* dashboard first).
   **A partnership showing "Active" is not enough** — check
   *Bidding sources → <network> → Ad unit mapping* actually lists Snake Classic
   with a non-zero mapping count. An active partnership with zero mappings
   contributes no demand at all, which is what a 34% match rate looks like.
3. **AppLovin only:** add its **SDK key** as `<meta-data android:name="applovin.sdk.key" …>`
   in `AndroidManifest.xml`. Other adapters need no manifest key.
4. **iOS:** not wired (iOS uses Swift Package Manager, and the app is
   Android-first). Add iOS mediation later only if iOS ad revenue justifies it.

## Notes
- **Pro users never see any ads** — these IDs are only used for free users.
- Debug builds always use Google's test IDs (`kDebugMode` switch in `ad_config.dart`).
- Unit IDs are hardcoded in `lib/services/ads/ad_config.dart` (they are not
  secret); the App IDs sit in the native manifests.

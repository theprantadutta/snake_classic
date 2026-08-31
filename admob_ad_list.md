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
The GMA SDK renders the mandatory intro screen and its opt-out itself — there
is no UI to build on our side. Console reward is set to **25 Coins**, matching
`AdService.freeCoinsPerAd`.

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
| **Rewarded** | Revive after death, Time-Attack +30s, double game-over coins, "2×" daily bonus / challenge claims, free-coins button in store, free power-up, Battle Pass XP, tournament entry | Opt-in only, uncapped; grants a reward on completion (on dismiss). Buttons are **always tappable** — they load on demand via `showRewardedOrWait` rather than greying out when the pool is empty |
| **Rewarded interstitial** | Game-over → Play Again / Menu, preferred over the plain interstitial | Shares the interstitial's cadence and gaps; pays 25 coins when watched through |
| **Interstitial** | Game-over → Play Again / Menu, fallback when no rewarded interstitial is loaded | Every 2nd game-over, ≥90 s since the last one and ≥2 min since any full-screen ad; the very first game-over ever is exempt |
| **Banner** | Most screens incl. gameplay (top-anchored) | Anchored **adaptive** (full-width, device-optimal height); reserves space up front to avoid layout shift; retries failed loads |
| **App Open** | Genuine return to foreground | Skips cold start, gameplay, and purchase/consent returns; only after ≥45 s away; 4-h ad expiry, 4-min min gap |

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
  15-min / 3-min. It was effectively off. 4-min / 45-s still skips the
  app-switch case that guard exists for.
- **Rewarded buttons must never gate on `isRewardedReady`.** Rewarded is the
  highest-eCPM format in the app by ~48× over banner, and at real fill rates the
  pool is empty a large share of the time — so gating hid the offer exactly when
  it was worth the most, and the tap that would have kicked a load never
  happened. Use `showRewardedOrWait`, which waits out a short load window and
  returns a three-way [RewardedOutcome] so callers can tell "no ad" apart from
  "user skipped it".

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
- **Pro / trial users never see any ads** — these IDs are only used for free users.
- Leave any line blank to keep using the test ID for that slot.
- Don't commit real IDs to a public repo if this project ever goes public — the
  unit IDs live in `.env` (gitignored-friendly); only the App IDs sit in the
  native manifests.

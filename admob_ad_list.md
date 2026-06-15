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

## 3. App Open ad units  (NEW — please create)

App Open ads show on a genuine return to the foreground (not cold start, not
during gameplay, not after a purchase). They're typically one of the highest
earners for casual games. The code is already wired — it just needs two real
ad units. **Until you paste them, release builds serve Google's TEST App Open
ads (no revenue, but safe).**

### How to create them (do this once per platform)
1. Go to https://apps.admob.com → **Apps** → select the **Android** app
   (App ID `ca-app-pub-9242904787767394~9115144122`).
2. **Ad units** → **Add ad unit** → choose **App open**.
3. Name it e.g. `Snake Classic Android — App Open`, **Create**.
4. Copy the unit id (looks like `ca-app-pub-9242904787767394/XXXXXXXXXX`).
5. Repeat for the **iOS** app (App ID `ca-app-pub-9242904787767394~3519202517`).

### Where to paste them
In `lib/services/ads/ad_config.dart`, replace the two placeholder constants
(they currently alias the test ids):
```
static const _appOpenAndroid = 'ca-app-pub-9242904787767394/XXXXXXXXXX'; // your Android App Open unit
static const _appOpenIos     = 'ca-app-pub-9242904787767394/YYYYYYYYYY'; // your iOS App Open unit
```
No manifest change is needed — the App ID already in `AndroidManifest.xml`
covers all formats.

```
ANDROID_APP_OPEN_AD_UNIT_ID = ca-app-pub-9242904787767394/2112367445
IOS_APP_OPEN_AD_UNIT_ID     = ca-app-pub-9242904787767394/9799285770
```

---

## What each ad unit is used for in the game
| Format | Where it shows | Notes |
| --- | --- | --- |
| **Rewarded** | Revive after death, "2×" daily bonus / challenge claims, free-coins button in store, tournament entry, power-up | Opt-in only; grants a reward on completion |
| **Interstitial** | Game-over → Play Again / Menu | Frequency-capped (every 2nd game, 3-min min gap); skipped for the first session |
| **Banner** | Most non-gameplay screens | Anchored **adaptive** (full-width, device-optimal height); reserves space up front to avoid layout shift |
| **App Open** | Genuine return to foreground | Skips cold start, gameplay, and purchase/consent returns; 4-h ad expiry, 4-min min gap |

## Mediation  (DEFERRED — revisit at ~1k DAU)

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

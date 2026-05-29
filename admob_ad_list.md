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

## What each ad unit is used for in the game
| Format | Where it shows | Notes |
| --- | --- | --- |
| **Rewarded** | Revive after death, "2×" daily bonus / challenge claims, free-coins button in store, tournament entry, power-up | Opt-in only; grants a reward on completion |
| **Interstitial** | Game-over → Play Again / Menu | Frequency-capped; skipped for the first session |
| **Banner** | Leaderboard / Replays / Achievements / Statistics screens only | Never during gameplay, home, or game-over |

## Notes
- **Pro / trial users never see any ads** — these IDs are only used for free users.
- Leave any line blank to keep using the test ID for that slot.
- Don't commit real IDs to a public repo if this project ever goes public — the
  unit IDs live in `.env` (gitignored-friendly); only the App IDs sit in the
  native manifests.

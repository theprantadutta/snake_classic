# AdMob mediation partners

Shared by **every app** the owner publishes: they all sit in one AdMob account
(publisher `ca-app-pub-9242904787767394`), so a partner's account, its
`app-ads.txt` lines and its AdMob bidding source are shared too. Each app still
needs its own placements and ad-unit mappings.

Last updated: 2026-11-13. Snake Classic is the first app being wired up.

## Why this exists

The November 2026 monetization audit (`reports/2026-11-12-monetization-audit/`)
found AdMob Network was the **only bidder** in every mediation group. AppLovin,
Unity Ads and Liftoff showed "Active partnership" under AdMob → Mediation →
Bidding sources, but each had **0 ad-unit mappings for all 18 apps**, so none of
them could bid. With one buyer, ~41–44% of requests came back empty (AdMob match
rate 56–59%). More bidders is the standard fix for no-fill and price.

## Status per partner

### AppLovin: blocked (account disabled)
- 2026-11-13: dashboard login says "Your account is currently disabled. We're not
  able to reactivate it at this time." No email had ever said it was approved,
  under review or disabled. Most likely cause: the account sat idle with no
  integration (0 mappings everywhere). The owner did nothing wrong.
- `support@applovin.com` is **unmonitored** (auto-reply). AppLovin support now runs
  under the **Axon** brand: ticket form `https://ads.axon.ai/support/contact-us`
  (redirects to `ads.applovin.com/support/contact-us`), chatbot at
  `https://support.axon.ai`.
- **Ticket filed 2026-11-13: AppLovin Support request #136960** (applovin.zendesk.com, category "Monetization (non-MAX)", signed in as the owner). Replies go to prantadutta1997@gmail.com.
- Do **not** open a new AppLovin account to get around it; networks treat that as
  evasion.
- In the app: `gma_mediation_applovin` was removed. If reinstated, add it back at
  the version built for the app's `google_mobile_ads` (see its CHANGELOG), map the
  units, and add AppLovin to `app-ads.txt`. AppLovin bids on interstitial, rewarded
  and App Open, **not banner**.

### Unity Ads: LIVE for Snake Classic Android (2026-11-13)
- Account: Unity org `prantadutta1997` (cloud.unity.com, org id 18968547514182).
- Snake Classic Android, done 2026-11-13: Unity project "Snake Classic", app
  "Snake Classic: Retro Arcade" (Google Play, not child-directed, matching Play
  Console's 13+ target age). **Game ID `800436806`**. Bidding placements
  `BP_Banner_Android`, `BP_Interstitial_Android`, `BP_Rewarded_Android`, mapped in
  AdMob to `banner_ad`, `interstitial_ad`, `rewarded_ad` and added to the
  `banner_ad`, `interestitial`, `rewarded_ad` mediation groups (all green).
- Snake Classic iOS, done 2026-11-13: app "Snake Classic: Retro Arcade" (App Store
  id 6779621362, not child-directed). **Game ID `800436843`**. Placements
  `BP_Banner_iOS`, `BP_Interstitial_iOS`, `BP_Rewarded_iOS`, mapped to the iOS
  `banner_ad`, `interstitial_ad`, `rewarded_ad` units. The account had no iOS
  mediation groups at all, so three were created: `banner_ad_ios`,
  `interstitial_ios`, `rewarded_ad_ios` (AdMob Network + Unity Ads bidding).
  iOS only starts using them once an iOS build with the adapters ships.
- Unity's "Developer website" (Monetization > Settings > Organization) is
  `https://pranta.dev`; on 2026-11-14 Unity reported the app-ads.txt at
  https://pranta.dev/app-ads.txt as up to date.
- `app-ads.txt`: the full Unity block (unity.com, 162886020, DIRECT plus 162
  resellers, exactly as the dashboard lists them) is in Snake's backend
  `wwwroot/app-ads.txt` (snakeclassic.pranta.dev) and the portfolio
  `static/app-ads.txt` (pranta.dev). Live once both are redeployed.
- Waterfall is retired at Unity (Jan 2026), so bidding only.
- Declined Unity's "Developer Data" sharing on purpose; mediation doesn't need it.
- Formats via bidding: banner, interstitial, rewarded (no App Open, no rewarded
  interstitial).
- App side: `gma_mediation_unity`. No Dart code; consent comes from UMP/TCF.

### Liftoff Monetize (formerly Vungle): LIVE for Snake Classic Android, set up for iOS (2026-11-13)
- `signin.liftoff.io` is **Liftoff Accelerate** (advertisers): "no active user for
  this email". The publisher dashboard is `publisher.vungle.com`, which refuses to
  load while the browser's ad blocker is on. With it off, it redirects to the
  **sign-up** page for prantadutta1997@gmail.com: no Monetize account exists. On
  2026-11-13 the sign-up form was filled in (Android, com.pranta.snakeclassic,
  company Pranta Dutta, pranta.dev, Bangladesh); the owner sets the password and
  submitted it; the account was approved the same day.
- Snake Classic Android: Liftoff **App ID `6af6ab95b828b7d5f62ccd4b`**, In-App
  Bidding placements (reference IDs): banner `SNAKE_BANNER_BIDDING-2700000`,
  interstitial `SNAKE_INTERSTITIAL_BIDDING-9402391`, rewarded
  `SNAKE_REWARDED_BIDDING-7710171`, App Open `SNAKE_APPOPEN_BIDDING-4045837`.
  (Liftoff also auto-created a `default` interstitial, `DEFAULT-2190977`,
  bidding off; it is unused.) All four are mapped in AdMob and added to the
  `banner_ad`, `interestitial`, `rewarded_ad`, `app_open_ad` groups.
- Adding App Open put Snake's App Open unit into the `app_open_ad` group for the
  first time: it had never been in it (the audit's "app_open_ad group shows 0"),
  so App Open had been served by AdMob's default group.
- Rewarded interstitial is not offered for self-serve; ask Liftoff
  (monetize@liftoff.io) to enable it, then map `rewarded_interstitial_ad`.
- app-ads.txt line: `vungle.com, 6af6a1a0efb36623c25ff32e, DIRECT, c107d686becd2d77`
  (Liftoff validates it on pranta.dev before serving). In both app-ads.txt files.
- Snake Classic iOS, done 2026-11-13: "Snake Classic iOS" (App Store id
  6779621362), Liftoff **App ID `6af6bd699b6208a5310feaed`**, In-App Bidding
  placements: banner `SNAKE_BANNER_BIDDING-9645199`, interstitial
  `SNAKE_INTERSTITIAL_BIDDING-9147400`, rewarded `SNAKE_REWARDED_BIDDING-5585743`,
  App Open `SNAKE_APPOPEN_BIDDING-4437907` (plus an unused auto-created `default`,
  `DEFAULT-3584867`, bidding off). All four are mapped to the iOS units and added to
  `banner_ad_ios`, `interstitial_ios`, `rewarded_ad_ios` and a new **`app_open_ios`**
  group (3160260662; AdMob Network + Liftoff). The Snake iOS App Open unit is named
  "Snake Classic Android — App Open" in AdMob even though it belongs to the iOS app;
  rename it in AdMob → Apps if that confuses anyone. Live only once an iOS build
  with the adapter ships (see CLAUDE.md, macOS checklist).
- Adding an app in Liftoff asks for a COPPA (child-directed) declaration; the owner
  answers that one personally.
- Formats via bidding: all, including App Open; rewarded interstitial needs
  Liftoff's account manager to enable it.
- App side: `gma_mediation_liftoffmonetize`.

## iOS verification on macOS (2026-11-13, for 7.6.0+74)

The CLAUDE.md macOS checklist, step by step:

1. **Sync:** both repos pulled; Flutter 3.50.0 (Dart 3.14.0); `flutter clean` +
   `flutter pub get` OK.
2. **Dependencies:** there is no CocoaPods here. The iOS project uses Swift Package
   Manager, and both adapters resolve through it on the first build:
   `googleads-mobile-ios-mediation-unity` (with `unity-ads-swift-package`) and
   `vungleadssdk-swiftpackagemanager`. The release app bundles
   `UnityAdapter`, `UnityAds`, `LiftoffMonetizeAdapter` and `VungleAdsSDK`.
   The two `Package.resolved` files are committed. Deployment target 15.0.
3. **SKAdNetwork IDs:** all 76 of Unity's and all 50 of Google's were already in
   `Info.plist`. Liftoff's list (its official XML,
   `vungle-static-assets.s3.amazonaws.com/dashboard/admin/prod/skadnetworkids.xml`,
   dated 2026-02-02, linked from the iOS integration page) had 15 more; added, now
   171, no duplicates, `plutil -lint` OK. Liftoff's file also lists 2
   AdAttributionKit IDs (`AdNetworkIdentifiers` key); not added, optional.
4. **Build:** `flutter build ios --release` OK, no adapter or version errors.
   On the iOS simulator (debug) Unity logs "Initializing SDK 4.21.0 with game id
   800436843 ... Initialized successfully"; startup, home, a game, game over and
   the menu all ran with no errors. `flutter analyze` clean, 949 tests pass.
5. **Real-device Ad Inspector check:** not done. No iPhone was connected, and the
   owner chose to ship 7.6.0+74 without it. Do it on the next macOS session with a
   device, and meanwhile watch AdMob → Reports → Mediation (iOS) for Unity and
   Liftoff requests once 7.6.0 is live: zero requests after a few days points at
   a mapping or adapter problem.
6. **Consent (UMP) check:** not done, same reason.
7. **Ship:** `./tools/release_ios.sh` built 7.6.0+74 (171 SKAdNetwork IDs and all
   four adapter frameworks in the IPA, Apple Distribution signature valid) and
   uploaded its Dart symbols and dSYMs to Sentry.

## Setting up a partner for an app (checklist)

1. Partner dashboard: add the app (store URL), create one **bidding** placement per
   format the partner supports, note the IDs (Unity: Game ID + placement IDs;
   Liftoff: App ID + placement reference IDs).
2. AdMob → Mediation → Bidding sources → (partner) → **Ad unit mapping**: map every
   ad unit of the app, Android and iOS.
3. AdMob → Mediation → **Mediation groups**: add the partner as a bidding source in
   each group the app's units are in (groups are shared across apps; the mappings
   decide which apps a partner actually bids for).
4. AdMob → Privacy & messaging: make sure the partner is in the GDPR and US-states
   ad-partner lists.
5. Add the partner's lines to the developer website's `app-ads.txt`.
6. App: add the official `gma_mediation_<partner>` package at the version matching
   the app's `google_mobile_ads`; iOS also needs the partner's SKAdNetwork IDs in
   `Info.plist`. The iOS adapters come in through Swift Package Manager on the next
   `flutter build ios` (no `pod install`); commit the updated `Package.resolved`.
7. Verify with AdMob **Ad Inspector** on a registered test device, then watch AdMob
   → Reports → **Mediation** for a week (per-source requests, win rate, eCPM).

## Snake Classic ad units (AdMob)

| Format | Android | iOS |
|---|---|---|
| App ID | `ca-app-pub-9242904787767394~9115144122` | `ca-app-pub-9242904787767394~3519202517` |
| Banner | `/3016639636` | `/3952271184` |
| Interstitial | `/6572741266` | `/9378033857` |
| Rewarded | `/7829982619` | `/3896430862` |
| Rewarded interstitial | `/8753884101` | `/3391193437` |
| App Open | `/2112367445` | `/9799285770` |

(Unit IDs are `ca-app-pub-9242904787767394` + the suffix; source of truth is
`lib/services/ads/ad_config.dart`.)

## Baseline to measure against (AdMob, 7 days to 2026-11-12)

Revenue $20.23 · match rate 56.38% · eCPM $1.09 (peers $2.17) · banner eCPM
$0.20–0.22.

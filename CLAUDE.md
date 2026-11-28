# Snake Classic - Flutter Game Project

## Project Requirements

### Core Objective
Create a classic Snake game in Flutter with premium game-quality UI/UX, running at 60FPS smoothly.

### Technical Requirements
- **Framework**: Flutter
- **Performance**: 60FPS smooth gameplay
- **Platform**: Multi-platform support (Android, iOS, Web, Desktop). **We ship a proper tablet/iPad release too** — the app must look and play correctly on large screens, not just phones.
- **UI Quality**: Professional game-level UI, not placeholder/basic interfaces
- **Assets**: Generate custom images, audio, and visual effects as needed

### Tablet / iPad Responsiveness (LOAD-BEARING)
The app is phone-first but ships a proper tablet/iPad experience. It stays **portrait-only on every device** (portrait lock in `main.dart`); tablets get a scaled-up portrait layout, NOT landscape. All responsiveness flows through **`lib/utils/responsive.dart`** — a `BuildContext` extension. When adding or changing UI, use it instead of new ad-hoc `MediaQuery`/`isSmallScreen` checks:
- `context.isTablet` / `context.deviceSize` — device class via `shortestSide` (≥600 tablet, ≥840 large tablet).
- `context.uiScale` (1.0 phone / 1.2 / 1.35) — multiply fixed pixel sizes (heights, paddings, icon/button sizes). Do NOT scale `fontSize` — the root `MediaQuery.textScaler` in `main.dart` already grows text on tablets; scaling the surrounding heights is what keeps it fitting.
- `context.sideInset()` — add to a scroll body's HORIZONTAL padding to cap menu/list content to a centered column on tablets. Prefer this over centered `ConstrainedBox` (it's safe inside `ListView`/`TabBarView`).
- Card grids use `SliverGridDelegateWithMaxCrossAxisExtent` (not fixed `crossAxisCount`) so columns grow with width.
- **Invariant: every responsive branch must be a no-op on phones** (`uiScale == 1.0`, `sideInset() == 0`) so phone layouts never regress.

### Game Features
- Classic snake gameplay mechanics
- Grid-based movement (20x20 tiles)
- Swipe/tap controls for direction changes
- Snake growth mechanics
- Collision detection (walls & self)
- Score system with high score persistence
- Sound effects and visual feedback
- Particle effects and animations
- Multiple themes/visual styles
- Pause/resume functionality
- Game over screen with animations

### Development Approach
- Complete creative freedom for implementation
- Use modern Flutter best practices
- Choose appropriate libraries for audio, animations, storage
- Focus on smooth performance and responsive controls
- No tests required for this project

### Store Layout
The unified store screen (`lib/screens/store_screen.dart`) has exactly 6 tabs in this order: **Pro / Coins / Themes / Skins / Trails / Power-Ups**. Modes and Boards are NOT sold as standalone products — both modes and board sizes are uniformly free (every `BoardSize` in `GameConstants.availableBoardSizes` is selectable by anyone; the `isPremium` flag on the model is retained for compatibility but is `false` everywhere). See `STORE_SETUP.md` for the full Play Store catalog (37 products). The cosmetic bundles, championship/VIP tournament entries, bronze tournament entry, and the battle-pass IAP were removed from the store (App Store cleanup): the Battle Pass remains a gameplay feature earned via XP, and bronze (daily) tournament entries are still earned via rewarded ad / Pro — they're just no longer sold.

### Offline-First Sync Architecture (LOAD-BEARING)

**Every user-mutable piece of state writes to Drift first, and the SyncEngine pushes it to the backend.** The app must remain fully functional offline — playing a game, earning coins, claiming a challenge, picking a cosmetic, changing settings — and any state that changes during the offline window must converge to the server on the next online tick.

**Single source of truth per piece of data.** Pick exactly ONE storage layer per data point:
- **Drift** — anything the backend cares about, anything that should travel with the user across devices (coin balance, high score, statistics, owned cosmetics, claim history, etc.). Cubits / services hydrate FROM Drift, write THROUGH Drift, and SyncEngine pushes from Drift outbox rows.
- **SharedPreferences** — device-only state that never travels. First-run flags (`hasSeenGameModePicker`, `hasAcceptedPrivacyPolicy`), UI preferences (`lastSelectedTabIndex`), debug toggles, FCM token cache, JWT — things the user re-picks if they switch devices.

The rule is **strictly mutually exclusive**: a given piece of data lives in ONE of those two storage layers, not both. Loading the same value from SharedPreferences in one place and Drift in another guarantees drift, which guarantees mismatched dashboard / device displays, which is the bug class we keep hitting.

The rule, applied to every new code path:

1. **Write through Drift.** No `SharedPreferences`-only writes for state the server cares about. SharedPreferences is fine for ephemeral UI state (toast preferences, last-tab-index), but anything the dashboard or another device should see goes into a Drift table.

2. **Enqueue a sync_outbox row in the same transaction.** Drift DAOs that mutate a synced table must call `attachedDatabase.enqueueSyncOutbox(dataType: ..., entityKey: ...)` inside the same `transaction { ... }` block. If the row write succeeds but the outbox enqueue fails, the sync engine never learns about the change. See `GameDao.upsertWeeklyQuest`, `StoreDao.addCoins`, `GameDao.updateStatisticsFromJson` for the pattern.

3. **SyncEngine is the single pusher.** No service-level direct `api.postX(...)` calls for stateful writes. The SyncEngine drains the outbox, dispatches to the matching `ApiService.syncX(...)` method, and handles retries / failure buckets. A direct `unawaited(api.claim...)` "fast path" is only acceptable as a duplicate signal on top of the sync (the canonical claim still goes through Drift + outbox).

4. **Cubits hydrate from Drift on cold start, then optionally refresh from the server.** `initialize()` should set up usable in-memory state from Drift before any network call. Background refresh from the server is fine but never blocking. See `WeeklyQuestService.initialize`, `DailyChallengeService.refreshChallenges`.

5. **Backend client-mirror tables are what the dashboard reads.** `UserCoinBalance`, `UserBattlePassSnapshot`, `UserDailyChallengeClaim`, `UserWeeklyQuestClaim`, `UserStatistics.ModelJson` — these are the targets of the sync endpoints, and `GetUserDetailQueryHandler` reads from them (NOT the canonical `User.Coins` / `UserBattlePassProgress` / `UserDailyChallenge` gameplay tables). The operator wants to see what the client believes.

6. **Sync handlers must accept the client snapshot as authoritative for client-mirror state.** Reject-on-stale-timestamp is the wrong reconciliation strategy for any field the client owns — the client's local clock is the only place that fully captures offline writes. Per-field absorbing merges (MAX for monotonic counters, OR for absorbing-true flags) are the correct pattern for shared-write fields like achievements; pure last-write-wins is correct for client-owned fields like coin balance, settings, statistics.

### Anti-patterns to refuse
- Adding a service method that writes to a Drift table without enqueueing a sync_outbox row.
- Adding a cubit method that writes to `SharedPreferences` for state the dashboard or another device should see.
- Calling `ApiService.x()` from a service for a stateful mutation when a sync handler exists for that data type.
- A backend sync handler that silently rejects a client push because `server.UpdatedAt > client.UpdatedAt`. Either accept it (last-write-wins) or do a per-field merge — never drop on the floor.
- Storing replays on the backend. Replays are phone-only — they live in the Drift `replays` table and never enter the sync surface (no outbox row, no API endpoint, no DTO). Do not add a `GameReplay` entity or any cloud-side storage for them.

### Development Commands
- **`./tools/release_android.sh`** (Git Bash) / **`.\tools\release_android.ps1`**
  (PowerShell) - Build a Play release AND upload its Sentry debug symbols. Use
  these instead of a bare `flutter build appbundle` for anything that ships: a
  plain build produces an artifact whose crash reports have unreadable frames,
  and nothing warns you until a crash arrives. The two scripts are twins —
  change one, change the other. They refuse to build if the version has
  already been released (`--force` / `-Force` overrides) or if a Sentry token
  is sitting in `.env`, which would ship it inside the app.
- **`./tools/release_ios.sh`** - The App Store equivalent: builds the IPA and
  uploads its Dart symbols and dSYMs to Sentry (token in `.sentry-auth-token`).
  Upload the IPA from that same run with Transporter; symbols only match the
  binary they were built with.
- `flutter pub get` - Install dependencies
- `flutter run` - Run the app (ask user for platform preference first)
- `flutter run -d android` - Run on Android device/emulator
- `flutter run -d chrome` - Run on web browser
- `flutter build` - Build for production
- `flutter analyze` - Static analysis (run regularly during development)
- `flutter clean` - Clean build cache

### Seeding Test Data (store screenshots, empty-screen testing)
A fresh install has empty stats, trophies, Season and ranks. To give a **test account** a believable history, run a DEBUG build with:

```
flutter run -d <device> --dart-define=LB_SEED=true
```

- `lib/debug/dev_data_seeder.dart` (`DevDataSeeder`, hooked from Home) plays synthetic finished runs through `GameEndPipeline`, the same path real games use, so stats, coins, XP, achievements, daily/weekly progress, Season XP and scores all agree and sync to the backend. It sets the high score at the end (never lowers it).
- **Sign in first.** It waits for a signed-in, non-guest account and does nothing for a guest. If it gave up, sign in and relaunch with the define.
- Runs **once per install**. `--dart-define=LB_SEED_FORCE=true` runs it again (adds another batch). `LB_SEED_RUNS` (default 40) and `LB_SEED_BEST` (default 3840) tune it.
- Debug-only by construction (`kDebugMode` + the define), so it is compiled out of release builds; nothing to remove before shipping.
- **Only seed test accounts** — kdstabsystem@gmail.com (tablet) and realjohndoe276@gmail.com (A24) were used for the 7.0.0 store shots. For screenshots without ads, give the account Pro: `dotnet run grant-pro-to-user.cs -- grant <email>` in `snake-classic-backend`.
- Works on any platform the app runs on (Android, iOS, macOS). Replays only come from real games, so play a couple by hand if a shot needs them.
- The Android test devices are shared with other agents: check the foreground app (`adb -s <id> shell dumpsys window | grep mCurrentFocus`) and do not launch over another app.

### Regenerating Icons and Splash (LOAD-BEARING)
- `dart run flutter_native_splash:create` **rewrites `android:windowDrawsSystemBarBackgrounds` to `false`** in all four `values*/styles.xml` variants. It must be `true` (Android 15 edge-to-edge — see the comment in `values/styles.xml`). **Restore it after every run.** The generator also reformats `Info.plist`, `LaunchScreen.storyboard`, `web/index.html` and the imageset manifests without changing their meaning — revert that churn so the diff is only real changes.
- **A splash `background_image` must end up in `drawable-nodpi/` only.** The generator writes it to `drawable/`, `drawable-night/`, `drawable-v21/` and `drawable-night-v21/`, which Android treats as mdpi and prescales by screen density: the 1290×2796 Miami backdrop became ~109 MB on xxhdpi phones, over the 100 MB canvas limit, and crashed the app on launch on every Android 11-and-older xxhdpi+ device (SNAKE-CLASSIC-FLUTTER-23, fixed in 8.0.4). Move one copy to `drawable-nodpi/` and delete the four generated ones. Android 12+ uses the android_12 splash and never shows it, so modern test phones can't reproduce this.
- `@mipmap/launcher_icon` is the app icon; **`@mipmap/ic_launcher` is not an icon at all any more** — the status-bar icon is `drawable/ic_notification`, a white-on-transparent glyph, because Android renders a small icon from its alpha alone and a colour icon arrives as a white blob.
- `dart run flutter_launcher_icons` owns `values/colors.xml`. Hand-written colours go in `values/colors_brand.xml` or they get overwritten.
- `assets/splash/android_12_splash_dark.png` is cropped by the system to a circle 2/3 the canvas wide. Verify `content_radius <= width/3` before shipping one; it is derived from `splash_logo_transparent.png`, not commissioned separately.
- Every splash asset is true alpha over the `#0F380F` window colour. Delivered "transparent" artwork must be checked by compositing over magenta — matte fringing and inverted drop shadows are invisible on dark green.

### Development Workflow
- Run `flutter analyze` regularly to catch issues early
- Always ask user before running the project on specific platforms
- Prefer Android for testing unless user specifies otherwise

### Libraries to Consider
- **Audio**: `audioplayers` or `just_audio` for sound effects
- **Storage**: `shared_preferences` for high scores
- **Animations**: Flutter's built-in animation framework
- **State Management**: `provider` or `riverpod`
- **Particle Effects**: Custom implementation or `flame` particles

### Asset Structure
```
assets/
  audio/
    - background_music.mp3
    - eat_sound.wav
    - game_over.wav
    - click.wav
  images/
    - snake_head.png
    - snake_body.png
    - food_apple.png
    - background_textures/
  fonts/
    - game_font.ttf
```

### Performance Targets
- Maintain consistent 60FPS during gameplay
- Smooth animations and transitions
- Responsive touch controls (<50ms latency)
- Fast game state updates
- Efficient memory usage

### Ad Load Diagnostics (`ad_load_stats`)
`lib/services/ads/ad_load_stats.dart` (`AdLoadStats`, held as `AdService.loadStats`) counts every ad request and its outcome for the session, per format, and sends ONE Firebase Analytics event per format, `ad_load_stats`, when the app is backgrounded (`AdService.markBackgrounded`). It exists because AdMob reports only a match rate, never the reason (banners filled ~21% of requests in Oct 2026), and the app's logs do not reach Sentry.
- Params: `format`, `requests`, `filled`, `failed`, `refresh_ok`, `refresh_failed` (auto-refreshes of a banner already on screen, which keeps its old creative when one fails), `codes` (`code:count`, most frequent first: `3` no fill = demand, `2` network, `1` invalid request / `0` internal = our request), `last_error`.
- Every new ad load path must report `requested` / `filled` / `failed` to it, or the numbers stop adding up to AdMob's request count.
- Aggregated on purpose: an event per failure would be ~200K events a month from banners alone.
- Registered 2026-10-14 as GA4 custom definitions (property `snake-classic-2a376`, Admin → Data display → Custom definitions; Firebase's own page no longer hosts them). Dimensions: `app_ad_format` (param `format`, shared with `ad_revenue`), `ad_failure_codes` (`codes`), `ad_last_error` (`last_error`). Metrics: `ad_requests`, `ad_filled`, `ad_failed`, `ad_refresh_ok`, `ad_refresh_failed`. A new param needs its own definition before it shows in reports, and only from that day on.
- **Why its fill rate is lower than AdMob's match rate** (Nov 2026: ~24% vs 56–59%). `requests` counts every load the app sends: the startup preload, each retry in the backoff (`_loadRetryDelays`, up to 5 per format until a re-arm), the reload after every show, and App Open's one request per session (held up to 4 h, shown rarely). AdMob's match rate also counts banner auto-refreshes, which here sit in `refresh_ok` / `refresh_failed` and not in `requests`. So compare `filled / requests` with itself across releases, not with AdMob. Averages over a window that spans a release mix builds: `failed` per event fell from ~5 to ~2 when 7.4.x shipped (Oct 27, startup stagger and shared banner backoff).

### Ad mediation (Unity Ads, Liftoff Monetize)
Added 2026-11-13 after the November audit found AdMob Network was the only bidder: the three partners were "Active" in AdMob but had 0 ad-unit mappings, so they never bid.
- **App side:** `gma_mediation_unity` and `gma_mediation_liftoffmonetize` in pubspec; from 8.0.0 also `gma_mediation_meta`, `gma_mediation_mintegral` and `gma_mediation_inmobi` (Mintegral's Android SDK comes from its own Maven repo, listed in `android/build.gradle.kts`). Pangle was removed: it only accepts registered companies. **AppLovin is not integrated:** its publisher account showed "disabled, can't be reactivated" on 2026-11-13, most likely because it sat idle (0 mappings on every app). If AppLovin support reinstates it, add `gma_mediation_applovin` back (built against the same google_mobile_ads version) and map its units; it bids on interstitial, rewarded and App Open, not banner. No Dart code: the adapters register themselves, and GDPR consent reaches them through the UMP/TCF signal `AdService` already collects. Each adapter is built against one `google_mobile_ads` version (its CHANGELOG says which); bump them together or the build can break.
- **Formats by network (bidding):** Unity: banner, interstitial, rewarded. Liftoff: all formats, but rewarded interstitial needs Liftoff's account manager to enable.
- **Console side:** each network needs the app and one placement per format in its own dashboard, then AdMob → Mediation → Bidding sources → (network) → Ad unit mapping for every Snake Classic ad unit (Android and iOS), then the network added as a bidding source in each mediation group, and its lines in the website's `app-ads.txt`. Verify with AdMob Ad Inspector on a registered test device; watch AdMob → Reports → Mediation for a week.
- **Current state:** see `docs/AD_MEDIATION_PARTNERS.md` (IDs, what is live, what is pending). It starts with a quick-status table covering every partner: the SDK networks, the no-SDK Open Bidding exchanges (Index Exchange applied and Magnite filled in on 2026-11-16, more queued), the app inventory those sign-up forms need, and the plan for Meta / Mintegral / Pangle. Keep that table current whenever a partner's status changes. Android ships the adapters from 7.6.0+74. iOS was built and checked on macOS on 2026-11-13 (steps 1–4 below); the real-device Ad Inspector and consent checks (steps 5–6) are still open.

#### macOS session: App Store growth (written 2026-11-24) — READ FIRST
**iOS 8.1.0 (87) is live** (approved 2026-11-23), so the 8.0.1 section below is done. Current iOS work is in **`docs/APP_STORE_GROWTH.md`**: iOS numbers (279 downloads / 30 days, +262%, still **0 ratings**); the running **Product Page Optimization test "Painted themes vs classic green"** (submitted 2026-11-24, 50% traffic, iPhone screenshots only), with how to read and apply its result and what to do if App Review rejects it; how to capture real iOS screenshots on the simulator with `LB_ALL_THEMES` / `LB_AUTOPILOT` / `LB_PROFILE_NO_BANNER` and the generator `tools/store_shots/gen_store_shots.py`; the Mac-only **icon test** (alternate icons must ship in the binary); and Apple Ads (scrapped for now by the owner, 2026-11-24). Ask the owner before any App Review submission.

#### macOS session: 8.0.1 for the App Store (written 2026-11-21) — DONE (superseded: iOS 8.1.0 is live)
(Android shipped as **8.0.1+82**: 8.0.0+81 was refused by Play because the InMobi adapter's CHANGE_WIFI_STATE made Wi-Fi a required feature; the manifest now declares `android.hardware.wifi` optional. Build iOS as 8.0.1 too.)
**Done on macOS 2026-11-21:** steps 1, 2, 4 and 5 (results in `docs/AD_MEDIATION_PARTNERS.md`, "iOS verification on macOS (2026-11-21)"); IPA 8.0.1 (82) built with symbols uploaded. Step 3 (real iPhone) is still open. App Store Connect version 8.0.1 holds the trimmed iOS What's New (7.7.0 was already live on iOS).
**NEW, 8.0.3+84 (Android, 2026-11-22):** banners are back to the **classic anchored adaptive size everywhere** (the pre-8.0 behaviour). The large banner of 8.0.0–8.0.2 is gone: real demand filled the large slot with 320×50 creatives almost every time, and 8.0.2's inline-adaptive workaround left banners BLANK on real devices (an inline ad reports 0×0 until rendered; some mediated creatives report pixels; a warm spare could hang forever). Kept from that work: `AdService.warmBannerInFlight` now gives up after 6 s, so a spare that never answers can no longer blank every banner. 8.0.2 (83) must never ship. Plugin bug filed as googleads-mobile-flutter#1555. Shared Dart, so iOS needs it too: if 8.0.1 (82) is not yet submitted, rebuild the IPA from master as **8.0.3 (84)**; otherwise ship it in the next iOS build. **iOS: shipped in 8.1.0 (87), built on macOS 2026-11-23** (8.0.1 was live; simulator smoke test of Home, game, game over + NEXT UP, replay, More games passed).
The owner asked for this on 2026-11-21. Android 8.0.0+81 is built on Windows. It adds **three new mediation adapters**, so iOS must be checked before an IPA ships:
- **New in 8.0.0:** `gma_mediation_meta` (Meta Audience Network), `gma_mediation_mintegral` and `gma_mediation_inmobi`, next to Unity and Liftoff. Pangle was tried and removed (companies only). None of the three new networks has an AdMob mapping yet (Meta: owner's account on hold; Mintegral: account in review; InMobi: waiting for SDK-bidding access), so on iOS they must **initialise without crashing** but will not fill.
- Also in 8.0.0: HCPP is Android-only (no iOS effect). The large anchored adaptive banner and the 11 redesigned themes apply on iOS too: check the banner fits and the game screen still fits on a small iPhone (SE / mini).

Do these, in order, and report to the owner with screenshots:
1. **Sync and build** (steps 1–4 below). The built `Runner.app/Frameworks` must now also contain the Meta (`FBAudienceNetwork`, `MetaAdapter`), Mintegral (`MTGSDK*`, `MintegralAdapter`) and InMobi (`InMobiSDK`, `InMobiAdapter`) frameworks. If any adapter fails to resolve or link, stop and tell the owner; do not drop it silently.
2. **Simulator smoke test (required).** `flutter run --release` can't target the simulator, so use `flutter run -d <iPhone simulator>` (debug, Google test ads) and also `--profile` if your Xcode allows it:
   - The app **launches and reaches Home without crashing**; watch the Xcode/`flutter run` console for adapter init lines and any exception (Meta, Mintegral and InMobi especially).
   - The **banner loads** on Home and in a game (test ad), the banner fits, and the game screen isn't squeezed.
   - Play a game to game over: the game-over screen, continue offer and an interstitial or rewarded test ad all open and close cleanly. Pause → Restart shows the new confirmation dialog.
   - Background the app and come back: no crash, banner still there.
   - Open the **AdMob Ad Inspector** (temporary debug-only `MobileAds.instance.openAdInspector` call, removed afterwards) and list which adapters report **initialized**: Unity and Liftoff should; record what Meta, Mintegral and InMobi report (expected: initialized or "not configured", but never a crash). Mediation adapters often won't *fill* in the simulator; that's fine. The test is that nothing crashes and AdMob's own ads still show.
3. **Real iPhone**, if one is available: steps 5–6 below (Ad Inspector + consent). If not, say so in the report; the simulator pass is the minimum.
4. **Generate the IPA:** `./tools/release_ios.sh` (builds the IPA and uploads Sentry symbols for that exact binary). Give the owner the IPA path. Upload with Transporter only if the owner says so. The App Store "What's New" text for 8.0.0 is in `store_listings/release_notes.md` (all languages).
5. Record results in `docs/AD_MEDIATION_PARTNERS.md`, commit `Package.resolved` changes, push.

#### macOS session: verify iOS mediation before the next App Store build
Nothing below could be checked on Windows. Do every step, in order, and record results in `docs/AD_MEDIATION_PARTNERS.md`. Stop and tell the owner if any step fails instead of shipping around it.
1. **Sync:** `git pull` in both repos; `flutter --version` must match what Android built with (3.50.x); `flutter clean && flutter pub get`.
2. **Dependencies:** the iOS project uses Swift Package Manager, not CocoaPods; `flutter build ios` resolves the adapters itself. The built `Runner.app/Frameworks` must contain `UnityAdapter`, `UnityAds`, `LiftoffMonetizeAdapter` and `VungleAdsSDK` (and, from 8.0.0, the Meta, Mintegral and InMobi frameworks). Commit the updated `Package.resolved` files.
3. **SKAdNetwork IDs:** `Info.plist` holds 171 IDs (Google's + Unity's + Liftoff's + AppLovin's lists, merged 2026-11-13; Liftoff's 15 newest added on macOS the same day). Refresh before release and make sure each list is fully contained (re-download, diff, add missing ones):
   - Unity: https://skan.mz.unity3d.com/v3/partner/skadnetworks.plist.json
   - Liftoff: https://vungle-static-assets.s3.amazonaws.com/dashboard/admin/prod/skadnetworkids.xml (the XML linked from Liftoff's iOS integration docs; curl fetches it fine)
   - Google: https://developers.google.com/admob/ios/3p-skadnetworks
   Check the plist still parses: `plutil -lint ios/Runner/Info.plist`.
4. **Build:** `flutter build ios --release` must succeed with no adapter/version errors. Each adapter is built against one google_mobile_ads version (its CHANGELOG); if the build fails on an adapter, bump the adapters and google_mobile_ads together, never one alone.
5. **Device check (real iPhone, not the simulator):** run a release build on a device registered as an AdMob test device (AdMob → Settings → Test devices), open the AdMob **Ad Inspector** (shake gesture after registering, or a temporary `MobileAds.instance.openAdInspector` call in a debug-only spot; remove it afterwards). Confirm:
   - Unity Ads and Liftoff Monetize both show as **adapter initialized** (green), not "not found".
   - Per ad unit, the mediation group lists Unity Ads (bidding) and Liftoff Monetize (bidding); both were mapped for iOS on 2026-11-13 (groups `banner_ad_ios`, `interstitial_ios`, `rewarded_ad_ios`, and `app_open_ios` for Liftoff only). IDs in `docs/AD_MEDIATION_PARTNERS.md`.
   - Single-source test for Liftoff too: banner/interstitial/rewarded/App Open with "Liftoff Monetize" only (turn on test mode for the iOS app in publisher.vungle.com first, off afterwards).
   - Single-source test: load banner/interstitial/rewarded with "Unity Ads" only; each must fill (enable test mode in the Unity dashboard first and turn it off afterwards).
6. **Consent:** on a fresh install with an EU VPN or the UMP debug geography, accept and decline the consent form; ads must still load after accepting and the app must not crash after declining.
7. **Ship:** `./tools/release_ios.sh` (uploads Sentry symbols), upload that same IPA with Transporter.
8. **After a week:** AdMob → Reports → Mediation, filter iOS: Unity and Liftoff should show requests and some wins. Zero requests means a mapping or adapter problem; recheck step 5.

### Game-over ad decisions (`game_over_ad`)
One Firebase Analytics event per game over that reaches `AdService.maybeShowGameOverAd`, param `outcome`: what the slot did, or the rule that kept it empty. It exists because the slot fires on ~1 game over in 10 (Nov 2026: ~1,080 full-screen ads against ~10,900 game overs a week) against a cadence of every 2nd, and nothing said which rule was holding it back.
- Values (`GameOverAdReason` in `lib/services/ads/game_over_ad_gate.dart`): `ads_off` (Pro / no consent / SDK not ready), `first_game`, `cadence`, `interstitial_gap`, `fullscreen_gap` (any full-screen ad in the last 2 min, e.g. a revive watch), `not_loaded`, `told_none` (the screen promised no ad on build), `cancelled`, `show_failed`, `shown_rewarded_interstitial`, `shown_interstitial`, `short_ad` (SHORT AD on the rewarded intro, plain interstitial played), `short_ad_unavailable`.
- Per game over rather than aggregated: ~45K a month is modest, and one dimension is all a report needs.
- GA4 custom dimension `game_over_ad_outcome` (event scope, param `outcome`) registered 2026-11-14 on property snake-classic-2a376; it only collects from that date on.

### Run, retention and push analytics (added 7.6.2, 2026-11-18)
A Nov 18 GA4 review (Oct 21 – Nov 17) found 94% of new installs start a game, but only 69% of those finish one, about 14% come back the next day, and about 3.4% after a week. These events show where the rest go:
- **`game_over.end_trigger`**: what closed the game-over continue window: `timer`, `again`, `home`, `replay`, `declined`, `background`, `new_run`, `no_offer`, `reset`, `menu`, `close`. `background` counts runs the app saved on its way out; before 7.6.2 those runs were lost (no high score, coins, stats or event). The run finalizes from `GameCubit.finalizeOnAppBackground`, called by the game-over screen's lifecycle observer. It is skipped while a continue is being paid for, because the rewarded ad itself backgrounds the app.
- **`game_abandoned`** (`reason`: `quit` / `restart`, plus `score`, `duration_seconds`, `run_number`, `game_mode`): a run left mid-play. `run_number` is lifetime, so 1 = first game ever.
- **`game_backgrounded`** (`score`, `duration_seconds`, `run_number`): the app left the foreground mid-run, once per run. It is not logged for revive / +30s ads. Started runs = `game_over` + `game_abandoned` + runs killed in the background, which carry this event.
- **`push_opened`** (`push_type` = the payload's `type`, `cold_start`, `age_minutes`): a tapped push, including the local `day_one_reminder`. Per-type open rate = these taps ÷ `success_count` per type in the backend's `notification_histories` table. GA's automatic `notification_open` has no type.
- **`daily_challenge_completed`** / **`daily_challenge_reward_claimed`**: fired from `DailyChallengeService`, so every path counts once. Completed challenges are claimed automatically by `GameEndPipeline`, because 80% of completed rewards were never claimed and expired with the day.
- A new param shows in GA reports only once it is registered as a custom definition, and only from that day on (see the ad sections above). Registered 2026-11-18, event scope: dimensions `game_end_trigger` (`end_trigger`), `run_end_reason` (`reason`), `run_number`, `push_type`, `push_cold_start` (`cold_start`), `game_mode`, `control_scheme`; metrics `push_age_minutes` (`age_minutes`), `run_duration_seconds` (`duration_seconds`, seconds), `run_score` (`score`). `score` and `duration_seconds` were already on `game_over`, so they collect from every build from that date.

### Retention analytics (8.1, November 2026 retention plan)
Plan, data and owner decisions: `docs/RETENTION_PLAN_2026-11.md`. Baseline before 8.1: D1 14.4%, D7 3.5%; day-0 runs predict D1 (1 run 9%, 4–6 runs 28%). Judge 8.1 by **install cohort by first app version** on the dashboard's `/retention` page (backend telemetry, every install including guests) and these GA4 events. New events go through the generic `AnalyticsClient.trackEvent` with typed wrappers in `lib/services/analytics/retention_events.dart`; add new ones there, not as a method per client.
- **`game_over`** gained `run_number` (lifetime), `game_mode`, `onboarding` (1 = one of the first three games).
- **`first_input`** (`run_number`, `seconds_since_run_start`, `control_scheme`): first accepted turn of an onboarding run. Pairs with the "swipe to turn" hint (`ControlsHint`).
- **`revive_offer`** (`outcome`: `ad` / `coins` / `free` / `declined`, `run_number`). `declined` includes the countdown running out. Onboarding runs get no revive and no CONTINUE (Pro excepted).
- **`next_goal_shown`** (`goals`: comma list of `daily`, `season`, `tomorrow`) / **`next_goal_tapped`** (`goal`): the game-over NEXT UP panel, from the second game on.
- **`daily_bonus_claimed`** (`day`, `streak`, `doubled`, `surface`: `popup` / `home`), **`streak_broken`** (`previous_streak`). The old `daily_bonus_collected` still fires, without params.
- **`weekly_quest_completed`** / **`weekly_quest_claimed`** (`quest_id`).
- **`notification_permission`** (`stage`: `soft_shown` / `soft_accepted` / `soft_declined` / `os_granted` / `os_denied`, `placement`: `first_best` for the game-over "Remind me tomorrow" row).
- **`day1_reminder`** (`result`: `scheduled` / `skipped_no_permission` / `skipped_pref` / `failed`). The local day-1 reminder always owns day 1 now; the server's daily reminder skips accounts younger than 48 h (`suppressedNewAccount` in its funnel log).
- **`daily_bonus_item_granted`** (`item`, `day`), **`cosmetic_trial`** (`stage`, `cosmetic_type`, `cosmetic_id`), **`xp_boost`** (`stage`): the granted bonus items and "watch 2 ads, wear it for a day".
- **`play_update`** (Android Play update funnel; named `app_update` in 8.1.0–8.2.0, which Firebase reserves and silently rejected, so those builds logged nothing): `stage` = `offered` (our dialog shown) / `accepted` / `snoozed` / `urgent` / `flexible_fallback` / `immediate_result` (`result`: `success` / `userDeniedUpdate` / `inAppUpdateFailed` / `error`) / `auto_completed` (`result`: `home`). Flow: a routine release gets our "Update now / Later" dialog as step 0 of Home's prompt queue (`showPlayUpdateOfferDialog`); "Update now" runs Play's blocking immediate flow, which restarts the app itself (players accepted flexible downloads and never tapped Restart). Finished downloads install at the next launch on Home, never on background (ads and paused runs background the app too). Policy: `lib/services/update_policy.dart`; cross-app write-up: `D:\Desktop\self-improvements\Recommendations\in-app-update-flow.md`. `stage` = `required` (`result`: `unavailable` / `downloaded` / `error`, or none when Play's flow ran) is the forced update below.
- **Forced update / emergency brake (8.1.1+, both platforms, LOAD-BEARING):** the dashboard's App Releases page sets a **minimum supported version** per platform (`GET /api/v1/app-release/{ios|android}`, anonymous, 5-min cache). A build below it gets a blocking "Update required" dialog on Home (`AppReleaseService` → `showAppUpdateDialog`); the rest of Home's prompt queue waits behind it. On Android its Update button runs Play's immediate flow (`InAppUpdateService.runRequiredUpdate`) and falls back to the Play listing (the row's store URL, else `AppReleaseService.playStoreUrl`); on iOS it opens the App Store. On Android the row's **latest version is ignored** (Play offers routine updates); on iOS it drives the optional notice. Builds before 8.1.1 never read the Android row, so this only protects players on 8.1.1 or later. **Raise the minimum only after the fixed build is 100% rolled out on Play and live on the App Store**, or players who can't get it yet are locked out. Owner asked for it 2026-11-25 so a broken build like 8.0.2 can be pulled from everyone.
- User properties: `install_week` (`2026-W48`), `onboarding_done` (0/1), `notif_permission`.
- **GA4 custom definitions: registered 2026-11-23** (before 8.1.0 went live, so they collect from its first day) on property snake-classic-2a376. Event-scope dimensions (name ← param): `onboarding_run` ← `onboarding`, `next_goals` ← `goals`, `next_goal_tapped` ← `goal`, `bonus_surface` ← `surface`, `funnel_stage` ← `stage` (shared by notification_permission, play_update, more_games, cosmetic_trial, xp_boost), `permission_placement` ← `placement`, `event_result` ← `result`, `bonus_item` ← `item`, `cosmetic_type`, `cosmetic_id`, `quest_id`, `promoted_game` ← `game`, `more_games_source` ← `source`. `outcome` was already registered as `game_over_ad_outcome`, which also covers `revive_offer`. User-scope: `install_week`, `onboarding_done`, `notif_permission`. Metrics: `first_input_seconds` ← `seconds_since_run_start` (seconds), `login_streak` ← `streak`, `previous_streak`, `bonus_day` ← `day`, `cosmetic_coin_price` ← `price`. A new param still needs its own definition.

### Versus analytics (8.2)
Added with the Versus fixes after a two-device test against production on 2026-11-26 (two phones on one Wi-Fi can't tell us how real matches go). Typed wrappers in `lib/services/analytics/versus_events.dart`, fired from `MultiplayerCubit`.
- **`versus_lobby_closed`** (`reason`: `ready_timeout` = somebody never pressed READY / `host_did_not_start` = everyone was ready, the host never pressed START; 40 s host-start deadline). Fired from `_abandonLobby`.
- **`versus_connection`** (`stage`: `reconnecting` = socket dropped mid-match / `recovered` = back in the match / `ended_away` = the match ended while offline / `lost` = gave up reconnecting). Derived from status transitions in `onChange`, so every path counts once. Recovery rate = recovered ÷ reconnecting.
- **`versus_match_quality`**, one per finished match on each device: `rtt_ms` (input round trip), `late_snapshots` (gaps > 400 ms; the server tick is ~300 ms), `max_gap_ms`, `correction_pct` (share of locally predicted steps the server corrected), `result` (`win`/`loss`/`draw`). Baseline from the device test: rtt 220–295 ms, 0–2 late snapshots on good Wi-Fi, corrections ≤ 7%.
- `reason`, `stage` and `result` reuse the registered dimensions `run_end_reason`, `funnel_stage` and `event_result`. **GA4 metrics registered 2026-11-26** (event scope, property snake-classic-2a376): `versus_rtt_ms` ← `rtt_ms` (ms), `versus_late_snapshots` ← `late_snapshots`, `versus_max_gap_ms` ← `max_gap_ms` (ms), `versus_correction_pct` ← `correction_pct`.
- Debug-only profiling (`LB_AUTOPILOT`) also steers Versus and logs `[VS]` lines through `dart:developer` (`lib/debug/versus_autopilot.dart`); print/debugPrint don't reach logcat or the VM service in profile builds, so read them over the VM service Logging stream.

### Controls tuning (8.3, Nov 2026) (LOAD-BEARING)
Controls were the most common complaint in Play reviews (d-pad too small, swipes "laggy"). What changed:
- **Swipe input is a raw `Listener`, not a pan recognizer** (`lib/widgets/swipe_detector.dart`). A GestureDetector pan waits for the 36 px pan slop and swallows it, so a turn needed ~50 px of finger travel. Now distance counts from finger-down and a turn fires mid-drag after `SwipeSensitivity.distance` (14 px on Normal). Latest finger wins. Never move it back to a GestureDetector pan.
- **Two device-local settings** (`device_preferences` v25, never synced, survive logout): `ControlSize` (Small 0.8 / Normal 1.0 / Large 1.25 / Huge 1.5, scales the d-pad's 190 dp and turn buttons' 220 dp caps) and `SwipeSensitivity` (Low 24 / Normal 14 / High 8 px). Both enums are index-stored: never reorder.
- A bigger control raises the control zone's floor (`GameBottomBar.zoneMin`, used by solo and Versus), so on a short phone the board gives up height. Swipe and the stick keep the 150 dp floor.
- `ControlTuning` (`lib/widgets/control_tuning.dart`) is the one tuning panel, used in Settings → Controls, the Pause sheet and the intro: sensitivity for swipe, size + position for the d-pad, size for turn buttons, nothing for the stick.
- **"Pick your controls" intro** (`lib/widgets/dialogs/control_choice_dialog.dart`, `ControlsIntro`): once per install, before the player's SECOND game (never the first: play-first is load-bearing for D1), and once for existing players on their next game. SharedPreferences `controls_intro_seen_v1`.
- Tests: `test/widgets/swipe_detector_test.dart`, `control_size_test.dart`, `control_tuning_test.dart`, `test/control_settings_test.dart`, migration replay to v25.

### Launch splash and event promo (8.3)
The Miami Nights launch splash (Nov 18) and the Home "try the Miami Nights theme" pop-up were removed in 8.3: the owner judged both were hurting players. The native splash is back to the Cell S splash from before 94e0c7f (solid `#0F380F` + logo; `drawable/background.png` is a 69-byte solid image again, so the nodpi rule below only matters if a full-screen `background_image` ever comes back). The Miami Nights theme itself stays in the picker (free until Dec 7, then paid).

The rating prompt (`ReviewService`) uses 5 games / 1 day on both platforms since 8.3 (Android was 8 / 3 days, which almost nobody reached).

### "More games" cross-promotion (8.1) (LOAD-BEARING)
A **MORE GAMES screen** (`lib/screens/more_games_screen.dart`, route `/more-games`) with one card per game in `CrossPromo.games` (`lib/services/cross_promo.dart`), opened from the Home menu (MORE GAMES, above ABOUT) and from one Settings row (MORE GAMES FROM US, between Help and Legal; `lib/widgets/lb_screens/settings/more_games_section.dart`). Owner, 2026-11-23: the owner's other **games** only (not the productivity apps): Cosmo Strike, Sunstone, Pourfect, Screw Out, Gridwell, Jadewell, in that order. A game shows only on the store where it is live: on 2026-11-23 Screw Out was Play-only and Jadewell App Store-only; add the missing URL when either launches on the other store. Cosmo Strike spec: cosmo-strike repo `marketing/cross-promo/MORE_GAMES_SPEC.md`.
- **Store-policy rules (Google Play + App Store):** no reward of any kind for installing or opening a promoted game (Play's incentivized-install ban, App Store 3.2.2); a normal list row opened only by the player's tap, never a pop-up, never at launch, during play or on game over; Android links only to Google Play and iOS only to the App Store (`PromotedGame.urlFor`, hidden on web/desktop); only the owner's own games, with the live listing's name and icon. Snake Classic is outside Designed for Families / the Kids category (Play target audience 13+, App Store 12+), which is what keeps plain store links allowed; the promoted games' own ratings (3+ to 9+) don't change that. If Snake ever targets children, Families/Kids rules need a parental gate before any store link: re-check before shipping.
- **Attribution:** Play link carries `referrer=utm_source=snake_classic&utm_medium=more_games` (Play Console → Statistics/Acquisition by utm_source); App Store link carries `ct=snake_classic_more_games` (App Store Connect → App Analytics → Campaigns).
- **Analytics:** `more_games` (`stage`: `opened` with `source` = `menu` / `settings`; `shown` when a card is built, i.e. scrolled near, once per visit; `tapped`; `open_failed`; `game`: e.g. `cosmo_strike`). Also `screen_view: moreGames`. Tap rate per game = tapped ÷ shown; installs come from the store consoles above.
- Adding a game: a new `PromotedGame` entry, a 192 px icon in `assets/images/cross_promo/` (resized from the game's iOS 1024 AppIcon so it matches the listing), a `moreGames<Name>` description in all 9 arbs, and a case in `moreGameDescription`. Ask the owner first.

### Coin cosmetics, Season cosmetics and temporary unlocks (8.1) (LOAD-BEARING)
- **Coin-priced cosmetics** (`trail_glow` 300, `trail_neon` 500, skin `fire` 800; prices only from the server: premium-content `coin_cosmetics` / `GET /cosmetics/coin-catalog`). Bought via `POST /cosmetics/buy-with-coins` (`CoinCosmeticPurchaser`). The server charges `users.coins`, which `/sync/coin-balance` overwrites last-write-wins, so the purchase runs inside `SyncEngine.runExclusive`: push the local balance, buy, then `StoreDao.adoptServerBalanceAfterCharge`. **Never queue a client `coin_transaction` for a server-charged item** or the charge doubles. Needs the backend from `feature/retention-2026-11` deployed first.
- **Season (battle-pass) cosmetics** are derived on the device (`SeasonCosmetics`) from the claimed free/premium tiers plus the built-in season table, and count as owned in `PremiumState`. The premium sync replaces owned sets with the server's list, and the server doesn't know the app's built-in season, so without this every sync stripped them. Never send the derived set upward.
- **Temporary unlocks** (1-day theme from the day-7 bonus, "watch 2 ads, wear it for a day") live in `TemporaryGrantsService` (SharedPreferences, device-only, never synced) and expire back to the previous selection. The day-5 bonus doubles Season XP for 24 h in `BattlePassCubit.bufferXP`.

### Miami Nights limited theme (added 7.6.2, 2026-11-18) (LOAD-BEARING)
A sunset-neon theme launched for the week of the big Nov 19 2026 game release. **Never name or allude to that game, its studio, its map/city names or its "Vice"/"Grand"/"Wasted" vocabulary anywhere public (store listings, What's New, push copy, product names). It is someone else's trademark and an IP strike lands on the developer account shared by ~20 apps.** The in-app announcement only nods at "the biggest game launch of the year"; keep it that vague.
- **Free window:** free for everyone until `PremiumContent.miamiNightsFreeUntil` (`DateTime(2026, 12, 8)`, local, so Dec 7 is the last free day). Change the end date there; every surface reads it.
- **After Dec 7 it is a paid theme:** sold on its own (store product `com.pranta.snakeclassic.miami_nights_theme`, `ProductIds.miamiNightsTheme`) and included with Pro. It is deliberately NOT in the "All 6 premium themes" bundle (`PremiumContent.nonBundleThemes` on the client, `ProductCatalog.BundleThemes` vs `ProductCatalog.Themes` on the backend). Anyone without it falls back to Classic when the window closes.
- **Price plan (owner, 2026-11-18):** $0.99 launch sale for one month from Dec 8, then $1.99. Play has no scheduled price change for one-time products: raise the `com-pranta-snakeclassic-miami-nights-theme` purchase option to $1.99 by hand on/after **2027-01-08**. In App Store Connect, schedule the $1.99 tier to start 2027-01-08 in the product's price schedule. Do NOT use a Play "offer" for the sale: our checkout buys the default purchase option, so a discounted offer would never apply.
- **Play product: DONE 2026-11-18**, Active, $0.99, backwards-compatible purchase option, 174 countries (same shape as crystal_theme). **App Store Connect product: DONE 2026-11-18** (Apple ID 6836344067, non-consumable, reference name "Miami Nights Theme"), price schedule already set: $0.99 from 2026-12-08, $1.99 from 2027-01-08 (nothing to change by hand on iOS).
- **Store products must exist before Dec 8:** create the non-consumable `miami_nights_theme` in **Play Console** (one-time product, same price tier as the other themes) **and App Store Connect** (non-consumable; a first IAP must be submitted with an app version, so attach it to the build that ships after 7.6.2, with a review screenshot of the theme). Until both exist, the store shows no buy price after Dec 7 on that platform. The backend change (ProductCatalog) must be deployed too, or purchases won't verify. **App Store: done.** All 175 countries, English (U.S.) "Miami Nights Theme" / "Sunset neon game theme", review screenshot from the in-game board plus notes on the free window, submitted together with 7.7.0 (77).
- **Index rule:** `GameTheme.miamiNights` must stay LAST in the enum: the selected theme is stored and synced by index.
- **Look:** `lib/design/miami_nights_scene.dart` paints the scene (cached Picture). The board uses it at full strength (`LegacyBoardComponent`); `LBGridBackground` uses a darker version with a faint grid, a soft sun and a shaded horizon band so text keeps contrast. The game screen passes an explicit colour so the scene isn't doubled behind the board.
- **Announcement:** removed in 8.3 (the Home pop-up and the Miami launch splash; see "Launch splash and event promo"). `theme_promo` analytics no longer fires.
- **Owned-theme sync fix (same change):** the server reports owned themes as product ids (`crystal_theme`), but the client matched them against `GameTheme.name`, which is the display name ("Crystal"). Every individually bought theme dropped from state on each sync. `PremiumContent.themeProductIds` now maps them; every premium theme needs an entry (a test enforces it).

### UI audit fixes and device rules (2026-11-19) (LOAD-BEARING)
- **Landscape is real on tablets.** Android 16 ignores the portrait lock on >=600dp screens for apps targeting SDK 36. Home, game, Versus, game over and the replay viewer have landscape branches (`width > height * 1.25`); any new full-screen layout needs one too. Verify on the Tab A9+ with `settings put system accelerometer_rotation 0; settings put system user_rotation 1` and restore `accelerometer_rotation 1` after.
- **60 Hz by default.** MainActivity sets `window.attributes.preferredRefreshRate = 60` on every onResume (native prefs `snake_display/cap60`); `preferredDisplayModeId` and the refresh_rate plugin's `disable()` do NOT work on Samsung (it lists only the active mode). High refresh is an opt-in in Settings, labelled with the panel's real max rate.
- **Gameplay banner jank is fixed by HCPP (2026-11-21, issue googleads-mobile-flutter#1551).** The cost came from animated/HTML5 ad creatives (e.g. a playable Pokémon GO banner): with them on screen the A24 dropped to ~43 fps with ~30% hitches; static ads, blank fills and Google's test unit ran at 60. `io.flutter.embedding.android.EnableHcpp=true` (APPLICATION-level meta-data in AndroidManifest.xml: the engine reads flags from the application, an activity-level entry is silently ignored) composites the banner in SurfaceFlinger: 58.6–59.9 fps on every window, with the same animated creative, normal and large banners alike. Flutter only enables it on Android 14+ with Impeller Vulkan and falls back to the old mode elsewhere. With HCPP the game draws into an `ImpellerSurface` layer, not the SurfaceView BLAST layer, so SurfaceFlinger `--latency` must target that layer. Profiling flags: `LB_AUTOPILOT=true`, `LB_PROFILE_NO_BANNER=true`, `LB_TEST_BANNER=true` (Google test unit in a profile build), `LB_LARGE_BANNER=true` (large anchored adaptive size). `DisableMergedPlatformUIThread` crashes on Flutter 3.50.
- **Text scale** is clamped to 0.9-1.6 (main.dart). Fixed-height surfaces use `LBFitHeight` or cap their own scale (`hudMaxTextScale` = 1.3 on the game HUD). `test/widgets/text_scale_test.dart` guards overflow at 1.6.
- **Brightness tokens:** boards are 20% toward black (not 35%), `inkMuted` .74, `inkDim` .56 (AA on small text). Don't drop them back.
- **Home gestures:** pans starting in the status-bar / gesture-bar strips are ignored, or pulling the notification shade steers the snake into Setup.
- **Miami Nights** draws a solid dusk base under outlined/muted/gold blocks and an opaque header band (LBScaffold), so the scene never sits behind text.
- **Shared test devices** (A24 RR8W901JDRL, Tab A9+ R83X309RLNR) are used by other Claude sessions (cosmo-strike, jadewell, ...): ask before taking one, check the foreground app before every tap, release with a message. Never restart adb.

### Motion system (feature/motion, 2026-11-19)
- **One rhythm:** every duration/curve comes from `LBMotion` (`lib/design/lb_motion.dart`); the spec and per-interaction table are in `docs/MOTION_SPEC.md`. Never hard-code timings. Reduce motion = `LBMotion.reduced(context)` (OS flag) -> fade or instant.
- **Building blocks:** `LBPressable` (press sink/spring, used by LBBlock), `LBStaggerIn`/`LBStaggerGroup` (screen entrances, once per screen), `LBRollingNumber` (odometer digits, text and cell font), `LBCoinFly` + `LBCoinTarget` (coins fly to a counter), `LBClaimPop`, `LBToggle` cell slide, `LBCellsBar` cell-by-cell fill, idle glow pulse on primary blocks (cached glow, opacity only).
- **Game over** is one beat sheet (`lib/widgets/lb_screens/game_over/game_over_beat_sheet.dart`): beats table at the top; tap skips; returning to the same run shows the end state; the existing TapArmGuard still gates AGAIN.
- **In-game** effects (`board_effects_component.dart`, `effect_curves.dart`) trigger only from tick events, use the game clock (freeze on pause) and a fixed slot pool. Measured on the A24 with autopilot + no banner: 60.0 fps, 0 late frames.
- **Tests:** `test/flutter_test_config.dart` turns the infinite idle glow pulse off (`LBBlock.idleGlowPulse = false`) or `pumpAndSettle` hangs. Keep it if you add your own test config.
- When testing on a release build, never tap blind during game over / ad flows: a live ad can be clicked by accident (AdMob policy risk).

### Theme scenes (feature/theme-scenes, merged 2026-11-21) (LOAD-BEARING)
Every theme has a painted scene behind the menus and the game board, not just a palette.
- **Where:** `lib/design/scenes/`, one file per theme. `theme_scene.dart` holds the `ThemeScene` interface: `paintBackdrop(menu:)`, an optional cheap `paintMotion`, `cardBase`, `headerBand`, `primaryGradient`, `SnakeStyle` and `busyBoard`. `scenes.dart` registers them (`registerThemeScenes()` in main.dart). LBGridBackground, LBScaffold (header band), LBBlock (card base, primary gradient), LegacyBoardComponent (board backdrop + motion) and the board painter (snake style) read the registry. Never add `theme == GameTheme.x` checks for scene looks.
- **Performance:** `ThemeScenes.paint` bakes each backdrop ONCE into a GPU image (`Picture.toImageSync` at device pixel ratio) and blits it every frame. Replaying the recorded Picture per frame cost Space 38 ms of raster (26 fps) on the A24. After the change all 11 themes measure raster p50 ~5 ms and 0–1.3% late frames. Keep `paintMotion` to a few dozen primitives: no blur, no saveLayer, no allocations.
- **Phone menus:** the Home score band (roughly 14–29% of the height) and the coin counter must stay clear of scene art. Put art at the edges or beside the PLAY block (see the `h > w * 1.3` branches).
- **No ring around food**, on any theme (the owner rejected it twice).
- The image cache survives hot reload: use hot restart (R) after editing a scene.
- **Debug only:** `--dart-define=LB_ALL_THEMES=true` unlocks every theme for tuning (compiled out of release builds). Preview renders: `flutter test tools/render_scenes_{a,b,c}_test.dart` (PNGs in `build/`).
- **Turn feedback:** two faint chevrons (`EffectCurves.turnDuration`, 360 ms). The board re-syncs on `lastAcceptedInputAt` (FlameGameBoard buildWhen), and the cubit keeps the stamp 400 ms. **No head stretch:** it jerked sideways mid-glide. **Rounded elbows only with snap movement:** with the glide they hopped a segment every move and flickered.
- **Smooth-glide snake (owner: it "flickers a lot", eyes watering):** bend cells get a fixed square so corners stay solid, and segment colours are pre-blended to opaque so overlaps at bends don't double up. Never flash the body: no white eat flash, brighten or wash.
- **Eating:** the game removes the food one glide before the drawn head reaches it, so the painter keeps it (`_drawEatenFood`) until the head covers it. The mouth stays wide open for the whole glide and closes only after (`EffectCurves.mouthAfterBite`). The swallow (`growRippleT`, 600 ms) starts when the glide ends: the food slips about two segments into the neck inside a small bulge and fades out. The owner wants "it went in", **not** a trip down the whole body.
- **Head eyes and mouth face the glide direction** (`_glideDirection`, previous head cell to current), never `currentDirection`. That one already holds a queued turn, so the open mouth faced the side and looked shut from the food's side.
- **`GameCubitState.copyWith` keeps `tickEvents` when the game state is unchanged.** Dropping them lost every bite whose tick shared a frame with an input emit, because the board only builds the latest state.

## In-App Purchase Setup (RTDN)

### Google Play RTDN Setup
1. Create a Google Cloud service account with Android Publisher API access
2. Download the service account JSON and place it at `snake-classic-backend/google-play-service-account.json`
3. In Google Cloud Console:
   - Enable Cloud Pub/Sub API
   - Create a Pub/Sub topic (e.g., `snake-classic-rtdn`)
   - Create a push subscription pointing to: `https://snakeclassic.pranta.dev/api/v1/purchases/webhook/google-play?token=YOUR_TOKEN`
4. In Google Play Console:
   - Go to Monetization setup > Real-time developer notifications
   - Set the topic to the Pub/Sub topic created above
5. Set environment variables in backend `.env`:
   - `GOOGLE_PLAY_SERVICE_ACCOUNT_PATH`
   - `GOOGLE_PLAY_PACKAGE_NAME=com.pranta.snakeclassic`
   - `GOOGLE_PLAY_PUBSUB_VERIFICATION_TOKEN`

### Apple App Store Server Notifications V2
1. In App Store Connect:
   - Go to App > App Information > App Store Server Notifications
   - Set Production URL: `https://snakeclassic.pranta.dev/api/v1/purchases/webhook/app-store`
   - Set Sandbox URL: same but with sandbox backend
2. Generate App Store Connect API key and set in backend `.env`:
   - `APPLE_KEY_ID`, `APPLE_ISSUER_ID`, `APPLE_PRIVATE_KEY`, `APPLE_BUNDLE_ID`

### Testing
- Use Google Play Console test tracks for subscription testing
- Use sandbox Apple ID for iOS testing
- Monitor Hangfire dashboard at `/hangfire` for background job status
- Check subscription events via `GET /api/v1/subscription/history`
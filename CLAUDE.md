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
- **App side:** `gma_mediation_unity` and `gma_mediation_liftoffmonetize` in pubspec. **AppLovin is not integrated:** its publisher account showed "disabled, can't be reactivated" on 2026-11-13, most likely because it sat idle (0 mappings on every app). If AppLovin support reinstates it, add `gma_mediation_applovin` back (built against the same google_mobile_ads version) and map its units; it bids on interstitial, rewarded and App Open, not banner. No Dart code: the adapters register themselves, and GDPR consent reaches them through the UMP/TCF signal `AdService` already collects. Each adapter is built against one `google_mobile_ads` version (its CHANGELOG says which); bump them together or the build can break.
- **Formats by network (bidding):** Unity: banner, interstitial, rewarded. Liftoff: all formats, but rewarded interstitial needs Liftoff's account manager to enable.
- **Console side:** each network needs the app and one placement per format in its own dashboard, then AdMob → Mediation → Bidding sources → (network) → Ad unit mapping for every Snake Classic ad unit (Android and iOS), then the network added as a bidding source in each mediation group, and its lines in the website's `app-ads.txt`. Verify with AdMob Ad Inspector on a registered test device; watch AdMob → Reports → Mediation for a week.
- **Current state:** see `docs/AD_MEDIATION_PARTNERS.md` (IDs, what is live, what is pending). It starts with a quick-status table covering every partner: the SDK networks, the no-SDK Open Bidding exchanges (Index Exchange applied and Magnite filled in on 2026-11-16, more queued), the app inventory those sign-up forms need, and the plan for Meta / Mintegral / Pangle. Keep that table current whenever a partner's status changes. Android ships the adapters from 7.6.0+74. iOS was built and checked on macOS on 2026-11-13 (steps 1–4 below); the real-device Ad Inspector and consent checks (steps 5–6) are still open.

#### macOS session: verify iOS mediation before the next App Store build
Nothing below could be checked on Windows. Do every step, in order, and record results in `docs/AD_MEDIATION_PARTNERS.md`. Stop and tell the owner if any step fails instead of shipping around it.
1. **Sync:** `git pull` in both repos; `flutter --version` must match what Android built with (3.50.x); `flutter clean && flutter pub get`.
2. **Dependencies:** the iOS project uses Swift Package Manager, not CocoaPods; `flutter build ios` resolves the adapters itself. The built `Runner.app/Frameworks` must contain `UnityAdapter`, `UnityAds`, `LiftoffMonetizeAdapter` and `VungleAdsSDK`. Commit the updated `Package.resolved` files.
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

### Miami Nights limited theme (added 7.6.2, 2026-11-18) (LOAD-BEARING)
A sunset-neon theme launched for the week of the big Nov 19 2026 game release. **Never name or allude to that game, its studio, its map/city names or its "Vice"/"Grand"/"Wasted" vocabulary anywhere public (store listings, What's New, push copy, product names). It is someone else's trademark and an IP strike lands on the developer account shared by ~20 apps.** The in-app announcement only nods at "the biggest game launch of the year"; keep it that vague.
- **Free window:** free for everyone until `PremiumContent.miamiNightsFreeUntil` (`DateTime(2026, 12, 8)`, local, so Dec 7 is the last free day). Change the end date there; every surface reads it.
- **After Dec 7 it is a paid theme:** sold on its own (store product `com.pranta.snakeclassic.miami_nights_theme`, `ProductIds.miamiNightsTheme`) and included with Pro. It is deliberately NOT in the "All 6 premium themes" bundle (`PremiumContent.nonBundleThemes` on the client, `ProductCatalog.BundleThemes` vs `ProductCatalog.Themes` on the backend). Anyone without it falls back to Classic when the window closes.
- **Price plan (owner, 2026-11-18):** $0.99 launch sale for one month from Dec 8, then $1.99. Play has no scheduled price change for one-time products: raise the `com-pranta-snakeclassic-miami-nights-theme` purchase option to $1.99 by hand on/after **2027-01-08**. In App Store Connect, schedule the $1.99 tier to start 2027-01-08 in the product's price schedule. Do NOT use a Play "offer" for the sale: our checkout buys the default purchase option, so a discounted offer would never apply.
- **Play product: DONE 2026-11-18**, Active, $0.99, backwards-compatible purchase option, 174 countries (same shape as crystal_theme). **App Store Connect product: DONE 2026-11-18** (Apple ID 6836344067, non-consumable, reference name "Miami Nights Theme"), price schedule already set: $0.99 from 2026-12-08, $1.99 from 2027-01-08 (nothing to change by hand on iOS).
- **Store products must exist before Dec 8:** create the non-consumable `miami_nights_theme` in **Play Console** (one-time product, same price tier as the other themes) **and App Store Connect** (non-consumable; a first IAP must be submitted with an app version, so attach it to the build that ships after 7.6.2, with a review screenshot of the theme). Until both exist, the store shows no buy price after Dec 7 on that platform. The backend change (ProductCatalog) must be deployed too, or purchases won't verify. **App Store: done.** All 175 countries, English (U.S.) "Miami Nights Theme" / "Sunset neon game theme", review screenshot from the in-game board plus notes on the free window, submitted together with 7.7.0 (77).
- **Index rule:** `GameTheme.miamiNights` must stay LAST in the enum: the selected theme is stored and synced by index.
- **Look:** `lib/design/miami_nights_scene.dart` paints the scene (cached Picture). The board uses it at full strength (`LegacyBoardComponent`); `LBGridBackground` uses a darker version with a faint grid, a soft sun and a shaded horizon band so text keeps contrast. The game screen passes an explicit colour so the scene isn't doubled behind the board.
- **Announcement:** `lib/widgets/event_theme_promo.dart`, step 2 of the Home prompt queue (after the walkthrough, so players need 3 started games first). Shown once per install (SharedPreferences `event_promo_miami_nights_seen`), only in the window and only if the player isn't on the theme. The first NOT NOW asks once more before closing. Analytics `theme_promo` (`promo_action`: `shown` / `second_ask` / `accepted` / `dismissed`); picks show in `theme_selected` as "Miami Nights".
- **Owned-theme sync fix (same change):** the server reports owned themes as product ids (`crystal_theme`), but the client matched them against `GameTheme.name`, which is the display name ("Crystal"). Every individually bought theme dropped from state on each sync. `PremiumContent.themeProductIds` now maps them; every premium theme needs an entry (a test enforces it).

### UI audit fixes and device rules (2026-11-19) (LOAD-BEARING)
- **Landscape is real on tablets.** Android 16 ignores the portrait lock on >=600dp screens for apps targeting SDK 36. Home, game, Versus, game over and the replay viewer have landscape branches (`width > height * 1.25`); any new full-screen layout needs one too. Verify on the Tab A9+ with `settings put system accelerometer_rotation 0; settings put system user_rotation 1` and restore `accelerometer_rotation 1` after.
- **60 Hz by default.** MainActivity sets `window.attributes.preferredRefreshRate = 60` on every onResume (native prefs `snake_display/cap60`); `preferredDisplayModeId` and the refresh_rate plugin's `disable()` do NOT work on Samsung (it lists only the active mode). High refresh is an opt-in in Settings, labelled with the panel's real max rate.
- **Gameplay banner costs frames** (60 -> ~39 fps on the A24, issue googleads-mobile-flutter#1551, watched by a cloud routine). The owner chose to keep it. Do not re-investigate game rendering for that jank. `--dart-define=LB_AUTOPILOT=true` (self-playing snake + frame logs) and `LB_PROFILE_NO_BANNER=true` exist for profiling. `DisableMergedPlatformUIThread` crashes on Flutter 3.50.
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
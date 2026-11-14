# Progress log — 2026-11-12 monetization audit

## 2026-11-13 — verification pass, then the code tasks that need no approval

### Claims checked

Console numbers were checked against the report's own screenshots (`admob-02`, `admob-07`,
`ga-11`). Code claims were checked against master `b22d056`.

| Claim | Verdict |
|---|---|
| AppLovin / Liftoff / Unity are Active partners with **0 ad-unit mappings**; AdMob Network is the only bidder | **True** (`admob-07..09`) |
| 7-day match rate 56.38%, eCPM $1.09, App Open 44 impressions | **True** (`admob-02`) |
| Ad cadence: every 2nd game over, 90 s interstitial gap, 2 min shared gap, App Open 30 min / 30 min / 4 h | **True** (`ad_service.dart:45-76`) |
| App Open preloaded "on startup at `main.dart:665`" | **Partly.** `main.dart:665` preloads on *background*; the startup request is `_preloadAll` (`ad_service.dart:314`). Either way it is ~1 request per session, held up to 4 h and rarely shown. |
| "Retry storms": failing units retried 10–30+ times per session | **Overstated.** Each format retries at most 5 times (`_loadRetryDelays`, 2 s → 10 min), reset only by a re-arm (network back, consent, Pro lapse). High per-session counts also include the reload after every show and, for banners, the shared backoff. |
| "Unable to obtain a JavascriptEngine" is a broken device WebView; stop retrying | **Mostly wrong cause.** It was largely self-inflicted: requesting all formats at once exhausted WebView JS engines. 7.4.0 (Oct 27) staggers startup requests 1.5 s apart (`_preloadStagger`). The report's 28-day window is mostly 7.3.0 traffic; `ga-11` shows `ad_failed` per event falling ~5 → ~2 when 7.4.x shipped. |
| Banner "Ad size will not fit on screen, a_w=800 s_w=360" | **True, real bug.** The adaptive size was cached once per process; a window that changed width (foldable, split screen) kept the wider size. |
| `multiplayer_game_started` under-fires | **True.** It fired only from the host's `startGame()`; matchmade games never logged it. |
| GA shows $0 IAP revenue; no purchase event with value | **True.** `item_purchased` carried only the display price string. Real revenue in GA needs Google Play linked to Firebase (owner); the app should not log a manual `purchase` event, which would double-count once linked. |
| Game tutorial "essentially unseen" (76 users) | **By design.** The game tutorial is opt-in: pause menu or Settings → replay. It never auto-starts, so 76 is the number who asked for it, not a broken first-run. |
| Open branches overlap ad work | **Stale.** `feature/game-over-ad-notice`, `feature/dpad-feel`, `feature/floating-joystick` are fully merged; `classic` is the pre-redesign UI from Oct 3. |
| Firebase "crash-free 100%" is meaningless (Crashlytics replaced by Sentry) | **True.** Stability lives in Sentry and Play vitals. |
| README house rule "commit only when the owner asks; branch first" | Owner's standing rule is small fixes straight to master. |

### Done (app, analyze clean, 948 + 1 tests pass)

- **Task 3 (instrument the game-over decision):** new `game_over_ad` event, param `outcome`, one per
  game over (`GameOverAdGate.evaluate` + `GameOverAdReason`; logged in `maybeShowGameOverAd`).
  Documented in CLAUDE.md. **Needs a GA4 custom dimension on `outcome`.**
- **Task 2.3 (banner size bug):** adaptive size now cached per window width (`banner_ad_widget.dart`).
- **Task 2.4 (reconcile `ad_load_stats` with AdMob):** written up in CLAUDE.md, Ad Load Diagnostics.
- **Task 11 (`multiplayer_game_started`):** now fires once per match for every player, on the
  first `playing` update (`multiplayer_cubit.dart`).
- **Task 10.2 (purchase value):** `item_purchased` now also carries numeric `value` + `currency`.

### Not done, on purpose

- **Task 2.1 (session circuit breaker on JavascriptEngine / DNS errors):** JavascriptEngine was mostly
  our own concurrency (fixed in 7.4.0), so breaking on it would kill ads for players who would
  recover. The existing 5-attempt cap already bounds DNS-blocked retries. Re-check with post-7.4
  data before adding a breaker.

### Waiting on the owner

- Task 1 mediation (console checklist + adapter SDKs), Task 2.2 App Open, Task 4 rewarded placements,
  Task 9 push diet, Tasks 0.2 / 5 / 6 / 10.1 / 12 / 13 data and console items.

## 2026-11-13 (later): owner decisions acted on

- **Task 1 mediation (approved):** `gma_mediation_unity` and `gma_mediation_liftoffmonetize` added
  (google_mobile_ads 9.1.0 -> 9.2.0); iOS `Info.plist` SKAdNetwork IDs merged to 156 from the
  networks' published lists. AppLovin left out: its publisher account is disabled (ticket
  #136960 filed). Unity: project "Snake Classic" created, app + placements in progress. Liftoff:
  account status unknown. Full state: `docs/AD_MEDIATION_PARTNERS.md`.
- **Task 2.2 App Open (approved "request only when showable"):** no request at cold start or on
  network re-arm; one request when the app returns to the foreground, held for the next return
  after 30+ min away. A request sent from the background never reported back on the A24, so it
  is made in the foreground, and a load silent for a minute no longer blocks later ones.
  Verified on the A24: cold start sent no App Open request; after a return, `app_open req=1 filled=1`.
- **Task 4 rewarded (approved):** double run coins, daily bonus 2x and the store free item
  already existed (the audit missed them, along with challenge 2x, free coins, Season XP and
  tournament entry). Added a **weekly quest 2x** on the claim toast (`weekly_quest_2x`).
- **Task 9 push (approved "just cap it"):** backend `b16f18d`: at most 3 scheduled pushes per
  player per rolling 7 days (`user_push_sends`, migration applied to production). Topic
  broadcasts (weekly leaderboard, tournament started) can't be capped per player.
- Verified on the A24 release build: `game_over_ad` fires (`outcome=cadence`), 2x coins rewarded
  completes (`placement=double_coins`), no Flutter errors.

## 2026-11-14: 7.6.0 live on both stores, first checks

- Dashboard App Releases: latest version 7.6.0 on Android and iOS (minimum left at 7.3.0).
- Sentry, release 7.6.0+74: one new issue (SNAKE-CLASSIC-FLUTTER-1P, ConcurrentModificationError
  inside Flutter's LicenseRegistry, 1 user, app in background); the two native `abort` issues and
  the SIGSEGV predate 7.6.0. Play vitals had no 7.6.0 data yet; the last 7 days show four
  one-user issues, all on 7.4.4.
- AdMob mediation, 2026-11-13 (first day): Android Unity 908 requests / 25 impressions /
  $6.41 eCPM, Liftoff 992 / 44 / $0.19; iOS Unity 26 and Liftoff 27 requests, no fills yet.
  The iOS adapters are reaching both networks, which covers the real-device check that was skipped.
- GA4: custom dimension `game_over_ad_outcome` (param `outcome`) registered.
- Still to do: the one-week comparison against the baseline (around 2026-11-20).
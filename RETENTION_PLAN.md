# D1 Retention — Findings & Fix Plan

**Problem:** Day-1 retention is stuck at 11–12%, never exceeding ~15%.
**Benchmark:** Casual/arcade D1 averages **25–32%**; all-genre mobile average is **27%**. A D1 below ~20% is normally read as "weak appeal" — but the data below shows that is *not* what is happening here.

**Analysis date:** 2026-08-06
**Data source:** GA4 property `a167242807p503220063`, window Jul 9 – Aug 5 2026 (28 days)

---

## 1. Executive summary

The game is not the problem. The traffic is not the problem. **The onboarding wall is the problem.**

- **97% of installs are Organic Play Store Search** — the highest-intent traffic that exists. These people typed "snake", scrolled past competitors, and chose this app.
- **31.0% never start a single game** (measured, closed cohort funnel — see §2.2).
- Only **41.7% ever reach a second game.**
- The ones who *do* get in engage for **9m 09s** across **1.8 sessions** — that is a healthy game.

There are **eleven gates** between tapping the app icon and the snake moving. Industry expectation is that players are *playing* within 60 seconds of install. We are asking users to read a legal document and create an account first.

---

## 2. The data

### 2.1 Acquisition — traffic quality is excellent

| Channel | New users |
|---|---|
| Organic Search | 4,500 |
| Direct | 136 |
| **Total new users** | **4,641** |

No paid UA. This rules out "low-intent / incentivised traffic" as an explanation entirely.

### 2.2 The funnel — proper cohort measurement

Built as a **closed** GA4 funnel exploration (each step must follow the previous one), so these are true cohort numbers, not mixed-cohort event totals.

> Saved in GA4 as **"D1 Onboarding Funnel — install to hooked"** (Explore → owned by Pranta Dutta). Two tabs: *Install to hooked funnel* and *D1-D7 retention by daily cohort*.

| Step | Users | % of installs | Abandoned here |
|---|---|---|---|
| 1. Installed (`first_open`) | 4,641 | 100% | **1,438 (31.0%)** |
| 2. Started a game (`game_started`) | 3,203 | 69.0% | 704 (22.0%) |
| 3. Finished a game (`game_over`) | 2,499 | 53.8% | 564 (22.6%) |
| 4. Played again (`game_started` ×2) | 1,935 | 41.7% | — |

**31% of installs never start a single game.** Then 22% of those who start never finish one, and 23% of those who finish never play a second. Only **41.7% of installs ever reach a second game**.

By country, step 1 → 2 (worst leak first):

| Country | Installs | Reached first game | Abandoned |
|---|---|---|---|
| **India** | 995 | 64.3% | **35.7%** |
| Mexico | 142 | 69.7% | 30.3% |
| Brazil | 503 | 72.2% | 27.8% |
| Poland | 120 | 75.0% | 25.0% |
| Russia | 264 | 78.4% | 21.6% |

India is both the largest market and the worst leak — consistent with low-end devices and slow networks, which is exactly what T2.9 targets.

### 2.2a Supporting event totals (28-day, mixed cohorts)

| Event | Users | Read |
|---|---|---|
| `login` | 3,557 | ~23% of installs never completed the auth wall |
| `tutorial_begin` | 3,559 | walkthrough started |
| `tutorial_complete` | **0** | **never fired — instrumentation bug, see §4** |
| `level_up` | 2,262 | |
| `app_remove` | 3,626 | uninstalled |

### 2.2b D1 retention, confirmed

The daily-cohort tab measures **D0 4,652 → D1 555 = 11.9%**, matching the reported 11–12% exactly. Against a casual/arcade benchmark of 25–32%.

### 2.3 Engagement — healthy for those who get in

| Metric | Value | Read |
|---|---|---|
| Avg engagement time / active user | **9m 09s** | at/above casual-games peer median |
| Engaged sessions / user | **1.8** | |
| DAU/MAU stickiness | **6.0%** | low (healthy casual is 15–25%) — a *consequence* of the funnel, not a separate problem |
| DAU/WAU | 19.2% | |
| Crash-free users (Android) | **99.5%** | **not** a D1 driver |
| `app_exception` | 32 users (0.51%) | confirms crashes are not the cause |

### 2.4 Notifications — delivery works, content does not

| Event | Users | |
|---|---|---|
| `notification_receive` | 2,703 (43.3%) | **delivery is fine** |
| `notification_dismiss` | 514 (8.2%) | |
| `notification_open` | **75 (1.2%)** | **~2.8% open rate** |

> Corrects an earlier assumption in project memory that only ~11 FCM tokens existed. Push *reach* is fine. Push *content and timing* are the problem — and there is no Day-1-specific notification at all (see §3, T3.10).

### 2.5 Monetization (context only — not this document's scope)

| Metric | Value |
|---|---|
| Total ad revenue (28d) | **$14.23** |
| `store_tab_viewed` | 326 users (5.2%) |
| `item_purchased` | 2 users |
| `premium_subscription_started` | 1 user |

Both follow from the same root cause: too few people ever reach the product.

---

## 3. Root cause — the eleven gates

Traced from `main.dart` through the router. What a brand-new user must survive before the snake moves:

| # | Gate | File | Cost |
|---|---|---|---|
| 1 | Native splash | `flutter_native_splash` | |
| 2 | `LoadingScreen` — 9 progress steps, blocks on leaderboard/tournament/social network preloads with **4s timeouts each** | `screens/loading_screen.dart`, `services/app_data_cache.dart:125` | seconds on slow networks |
| 3 | Privacy Policy + Terms in a **tabbed markdown reader**, mandatory checkbox, "Continue to Sign In" | `screens/first_time_auth_screen.dart:473` | high abandon |
| 4 | Auth choice — Google / Email / Guest | `first_time_auth_screen.dart:341` | **~23% loss** |
| 5 | Guest → warning modal: *"deleted in 90 days"*, *"no cloud sync"*, *"can't buy anything"* → **"Proceed Anyway"** | `first_time_auth_screen.dart:871` | actively sells against the product |
| 6 | `UsernameSetupScreen` | `screens/username_setup_screen.dart` | |
| 7 | **7-step coach-mark walkthrough** (Play, Coins, Daily, Store, Cosmetics, Profile, Settings) | `widgets/walkthrough/home_walkthrough.dart` | metagame tour before any gameplay |
| 8 | Daily bonus popup | `home_screen.dart:271` | |
| 9 | Notification permission soft-ask → OS dialog | `home_screen.dart:167` | permission asked before any value delivered |
| 10 | **Non-dismissible** game-mode bottom sheet on first Play tap (`isDismissible: false, enableDrag: false`) | `home_screen.dart:216` | |
| 11 | `PreGameLoadingScreen` — 3s timer, docstring admits *"the remaining seconds are pure theater"* | `screens/pre_game_loading_screen.dart:49` | 3s × every play |

**The architectural mismatch:** the app is built as a live-service metagame hub (battle pass, tournaments, friends, cosmetics, quests). The users arriving from Play Store search want to play snake on a bus for three minutes. The front door is built for the wrong person.

### 3.1 Key enabling discovery

`UnifiedUserService.initialize()` (`services/unified_user_service.dart:283-309`) **already creates a purely-local offline guest** when there is no Firebase user and no cached session. The entire Drift-first offline architecture already supports playing with no account.

**The play-first capability is already shipped.** Only the router gate in `loading_screen.dart:216-227` stands in the way. This makes T1.1 far cheaper than it looks.

---

## 4. Instrumentation gaps

These blind us and must be fixed alongside the changes so before/after is measurable.

- **`trackWalkthroughCompleted()` is defined but never called anywhere** (`analytics_facade.dart:305`, `firebase_analytics_client.dart:344`). `tutorial_complete` has never fired. **Its absence in GA4 is NOT evidence of 100% abandonment** — it is a wiring bug.
- No onboarding-step funnel events (privacy shown/accepted, auth shown/method chosen, username shown/completed).
- No `time_to_first_game_ms` — the single most important metric to optimize.
- No first-cohort funnel exploration built in GA4.

---

## 5. The plan

Ordered by impact. Tier 1 is where the 11% lives.

**Status: all implemented 2026-08-06.** `flutter analyze` clean, 122 tests passing (117 existing + 5 new), backend solution builds clean.

### T0 — Instrumentation (done first, so everything else is measurable)

- [x] **T0.1** Wired `trackWalkthroughCompleted()` into the walkthrough `onComplete` — `tutorial_complete` now actually fires
- [x] **T0.2** Added `onboarding_step_shown` / `onboarding_step_completed` / `first_game_started` (with `seconds_since_install`) across the analytics interface, facade, Firebase client and logger client. New `FirstRunService` owns the install stamp and the games-started counter
- [x] **T0.3** Built the GA4 exploration **"D1 Onboarding Funnel — install to hooked"** — a closed 4-step funnel with a Country breakdown, plus a daily-cohort retention tab. Numbers in §2.2. This is what turned the earlier "40–48% never play" estimate into the exact 31.0%

### T1 — Remove the wall (highest impact)

- [x] **T1.1** **Play-first.** `loading_screen.dart` routes a first launch straight to `/home`. Worked out cheaply because `UnifiedUserService.initialize()` *already* creates a local offline guest — the capability was shipped, only the router gate stood in the way. Sign-in moved to `DeferredSignInPrompt`, fired from the game-over screen when a guest sets a new personal best (max 3 asks, ≥3 days apart)
- [x] **T1.2** **Non-blocking legal consent.** New `FirstRunLegalNotice` strip on Home with tappable Terms / Privacy links; acceptance recorded on the first Play tap. Existing users still get the blocking re-consent screen on a legal-version bump
- [x] **T1.3** **Deleted the guest warning modal** and its now-dead `_GuestWarningBullet` widget
- [x] **T1.4** **First game skips the 3s pre-game loader** entirely
- [x] **T1.5** **Prompt queue deferred** until after the first game, with a build-side re-entry hook so the Android-back path can't strand it. ⚠️ *Caused a regression, caught on device:* `NotificationService.initialize()` was step 3 of that queue, and it is what registers the `onMessageOpenedApp` listener — so deferring the queue silently killed notification taps for anyone who had not yet played a game. Handler registration now happens unconditionally in `main()`'s bootstrap with `requestPermission: false`; only the permission soft-ask stays deferred. **Registering handlers and asking for permission are different concerns and must never share a gate.**
- [x] **T1.6** **Game-mode sheet is dismissible** and skipped on the first play

### T2 — First-session quality

- [x] **T2.7** **Gentler opening games.** New `GameState.startingSpeedMs` applies Easy's 380ms start for the first 3 games. Deliberately *not* `Difficulty.easy` — that flag drives `countsForHighScore`, so the shortcut would have stopped a new player's first runs counting as their own personal best. Covered by `test/game/onboarding_pace_test.dart`
- [x] **T2.8** **Progressive disclosure on Home.** During onboarding only Daily Challenges + Leaderboard show (`_NavItem.showDuringOnboarding`); the walkthrough now also waits for the full grid, since 4 of its 7 steps point at tiles that would otherwise be unmounted
- [x] **T2.9** **Loading screen no longer blocks on the network** for a first run — `preloadAll(skipNetwork:)` drops up to three 4s timeouts

### T3 — The Day-1 return trigger

- [x] **T3.10** **Day-1 comeback reminder**, implemented as a *local* one-shot rather than a server push. The backend job requires `FcmTokens.Any()`, which requires a JWT — and play-first makes the typical new player an accountless offline guest the server cannot address at all. Fires ~20h out, clamped out of quiet hours, personalised with their score, cancelled when they return on their own, and skipped entirely for users with a backend session so it never double-notifies alongside the server job
- [x] **T3.11** **Notification cadence, not copy.** ⚠️ *The original premise was wrong* — the copy is already personalised (streak / high score / challenge) in nine languages. The real number is **46,291 notifications to 2,703 users (~17 each/month) against 125 opens and 5,919 dismissals** — roughly a 0.3% open rate. Cause: the activity gate admitted anyone active within 30 days, so someone who installed, played once and left got a reminder *every day for a month*. Cadence now degrades with absence (daily → ~2-daily → ~weekly) via graduated `LastDailyReminderAt` gaps. No migration needed
- [x] **T3.12** **`TomorrowRewardCard`** on the game-over screen announces the next daily-bonus rung, directly above the Play Again / Menu decision

---

## 5a. What to watch after release

The point of doing T0 first is that these are now answerable. In rough order of importance:

1. **`first_game_started` → `seconds_since_install`.** The headline number. Was effectively unbounded (11 gates); should now be seconds.
2. **`first_open` → `game_started` conversion.** Was ~52–60% of new installs. If play-first works, this is the metric that moves first, and D1 follows it.
3. **`login` volume will DROP — that is expected, not a regression.** Sign-in is no longer compulsory. Watch `onboarding_step_completed(deferred_sign_in)` for the replacement conversion, and judge the two together.
4. **`notification_receive` per user should fall** from ~17/month, while `notification_open` **rate** should rise. Total opens falling slightly while the rate improves is a win, not a loss.
5. **`app_remove`** — the honest scoreboard.

Give it a full 7–14 days before drawing conclusions; D1 is a cohort metric and the first days after a release are contaminated by the update population.

## 6. Expected outcome

No promises on an exact number. But the arithmetic is favourable: **1,438 of 4,641 installs never start a game**, and those who do play engage 9 minutes across 1.8 sessions. Moving users from the "never played" bucket into the "played" bucket is close to pure D1 upside.

Given 97% organic-search intent, **25–30% D1 is a realistic target, not an optimistic one.**

---

## 7. References

- [Business of Apps — Mobile Game Retention Rates](https://www.businessofapps.com/data/mobile-game-retention-rates/)
- [Segwise — Mobile Game Retention Benchmarks 2026](https://segwise.ai/blog/mobile-gaming-app-user-retention-strategies)
- [Playio — Onboarding Decides Your D1](https://blog.playio.co/mobile-game-onboarding-retention)
- [AppAgent — Mobile Game Retention Benchmarks](https://appagent.com/blog/mobile-game-retention-benchmarks/)

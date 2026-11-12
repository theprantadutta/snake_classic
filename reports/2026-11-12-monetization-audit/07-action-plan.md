# 07 — Action Plan (for the Claude Code agent)

**How to use this file**

- Work top to bottom. Each task has **Owner**, **Why**, **Steps**, **Files**, **Done when**.
  - **OWNER** = needs the human (a console click, a partner account, a store listing, a decision).
    Prepare everything, then hand over a short checklist; don't try to do console actions yourself
    unless the owner explicitly asks and Claude-in-Chrome is available.
  - **AGENT** = code you can write in `snake_classic/` or `snake-classic-backend/`.
- Before writing code for a task, **re-verify the evidence** (numbers are from 2026-11-12; code
  references are from master `b22d056`). If something no longer holds, say so and skip it.
- Follow the house rules in `README.md` (analyze/build clean, no stubs, latest packages, no AI
  attribution in commits, ads inside `AdService` gates, analytics via the 4-file facade).
- **Ask the owner before:** adding a new ad network SDK, changing ad frequency, changing push
  schedules, or anything user-visible in monetization. Present the plan, wait for a yes.
- Keep a running log of what you did in `reports/2026-11-12-monetization-audit/PROGRESS.md`.

---

## Phase 0 — Verify and fill data gaps (½ day, do first)

### Task 0.1 — Read the code paths this plan touches · AGENT
Read, don't change: `lib/services/ads/ad_service.dart` (whole file, ~1,600 lines),
`lib/services/ads/game_over_ad_gate.dart`, `lib/services/ads/ad_load_stats.dart`,
`lib/services/ads/ad_config.dart`, `lib/widgets/ads/banner_ad_widget.dart`,
`lib/widgets/lb/lb_banner_slot.dart`, `lib/main.dart` (around line 665 and the lifecycle handling),
`lib/widgets/revive_overlay.dart`, `lib/widgets/game_over_continue_sheet.dart`,
`lib/services/analytics/*`, `lib/services/purchase_service.dart`.
Check remote branches `feature/game-over-ad-notice`, `feature/dpad-feel`, `feature/floating-joystick`,
`classic` for overlapping work (`git log origin/<branch> --oneline -20`, `git diff master...origin/<branch> --stat`).
**Done when:** you can explain the full ad lifecycle per format and you know what those branches change.

### Task 0.2 — Pull the numbers this audit couldn't · OWNER (agent prepares the list)
Ask the owner to grab (or, if they allow, read them via Claude in Chrome):
1. **AdMob → Privacy & messaging → report**: consent rate by country (EU). Confirms the FR/IT/DE ad-viewer gap.
2. **AdMob → Apps → app-ads.txt**: status for Snake Classic (verified / not found / issues).
3. **AdMob → Reports → Ads Activity** with dimensions *Format* + metrics *Clicks, CTR*: CTR per format (rule out accidental banner clicks).
4. **Google Play Console**: installs/uninstalls by acquisition source & country (last 30 d), Android Vitals (crash + ANR rate), store listing conversion by country, ratings trend.
5. **Sentry**: crash-free sessions/users for 7.4.4 and 7.5.0, top issues.
6. **GA4 Explore** (property `p503220063`): free-form on event `ad_load_stats` with rows `app_ad_format`, columns none, values `ad_requests`, `ad_filled`, `ad_failed` → per-format fill rate. Second tab: rows `ad_last_error` × `Country` (confirm the DNS-failure ↔ Russia overlap).
7. **GA4 Explore → Cohort exploration**: D1/D7 by first-touch date, split by country and app version, for Oct 15 – Nov 11 (explain the Nov 8–10 drop).
**Done when:** answers are pasted into `PROGRESS.md`.

---

## Phase 1 — Revenue (ads)

### Task 1 — Turn on mediation bidding (AppLovin, Unity, Liftoff) · OWNER + AGENT · **highest impact**
**Why:** the three partners are connected ("Active partnership") but have **0 ad-unit mappings**, and every
mediation group's only bidder is AdMob Network; waterfall is empty. "No fill." is the #1 named failure
(17K events / 3.9K users). Evidence: `03-mediation.md`, screenshots `admob-04..09`, `ga-12`.

**OWNER steps (agent writes them up as a checklist with the exact ad-unit IDs from `lib/services/ads/ad_config.dart`):**
1. In each partner dashboard (AppLovin MAX/SDK key, Unity Grow/Ads Game ID, Liftoff Monetize app),
   make sure Snake Classic Android + iOS exist with one placement per format: banner, interstitial,
   rewarded, rewarded interstitial (and app open only if keeping it — see Task 2.2).
2. AdMob → Mediation → **Bidding sources** → each partner → **Ad unit mapping** → add mappings for every
   Snake Classic ad unit (Android + iOS).
3. AdMob → **Mediation groups** → each group (`rewarded_ad`, `banner_ad`, `interestitial`, `app_open_ad`,
   and the fifth) → *Bidding* → **Add ad source** → the three partners. Note the groups are shared with
   other apps (AI Persona, Odyssey…) — that's fine; mappings decide per-app eligibility.
4. Update the website **`app-ads.txt`** with each partner's lines (from each partner's dashboard).
5. Optional later: add Pangle / Mintegral / Meta Audience Network / InMobi (strong in India/Brazil).

**AGENT steps (after the owner says yes):**
1. Look up the current official Flutter adapter packages on pub.dev (expected names
   `gma_mediation_applovin`, `gma_mediation_unity`, `gma_mediation_liftoffmonetize`). Use the **latest**
   versions compatible with `google_mobile_ads` (`pubspec.yaml:97`, currently `^9.0.0`); read each
   changelog for breaking changes and minimum Android/iOS SDK requirements.
2. Add them to `pubspec.yaml`; apply each package's documented native setup (iOS `Info.plist`
   `SKAdNetworkItems` for each network; Android repos/gradle if the docs require; ProGuard/R8 rules if any).
3. Consent: confirm the UMP/TCF signal reaches each adapter (most read TCF automatically; some need
   explicit GDPR/CCPA calls — follow each package's README). Keep it inside the existing consent flow in
   `AdService` (`canRequestAds`).
4. Do **not** change ad unit IDs or AdService gating. Debug builds keep using Google test IDs.
5. Make sure `ad_load_stats` still counts every request (new paths must report requested/filled/failed).
6. `flutter pub get`, `flutter analyze` clean; build an Android release locally via
   `tools/release_android.ps1` only if the owner asks.
7. Tell the owner how to verify with **Ad Inspector** (AdMob test device + shake / `MobileAds.instance.openAdInspector`) — check whether a debug-only hook exists before adding one.

**Done when:** adapters are in the build, `flutter analyze` is clean, the owner has completed the console
checklist, and AdMob → Reports → *Mediation* shows requests for each partner within ~48 h of rollout.
**Measure after 7 days:** match rate (was 56–59%), banner eCPM (was $0.20–0.22), total 7-day revenue
(was $20.23), per-source win rate.

### Task 2 — Stop wasted and doomed ad requests · AGENT
**Why:** SDK-level fill ≈ 24%; App Open is loaded in ~17K sessions but shown ~44×/week; repeated
retries trigger "Too many recently failed requests" (205 events / 162 users); unfixable device errors
(WebView "JavascriptEngine" 6.2K / 818 users; DNS-blocked 4.6K / 1.1K users) are retried anyway.
Evidence: `04-ad-delivery-diagnostics.md`, `ga-11/12/13`.

**2.1 Session-level circuit breaker for unrecoverable errors.** In `AdService`'s load-failure handling
(see `_loadRetryDelays` at `ad_service.dart:83` and banner `_bannerBackoff` near `:1394`): when a load
fails with an error whose message matches *JavascriptEngine* or *Unable to resolve host*
(googleads.g.doubleclick.net / mediation.goog), stop retrying **all formats** for the rest of the
session (or until connectivity changes), and record it in `ad_load_stats` (e.g. a `suppressed`
count — needs a new GA custom definition, note that in CLAUDE.md's Ad Load Diagnostics section).
Keep the existing backoff for no-fill/network errors — the code comment explains why the long tail exists.

**2.2 App Open: only request when a show is possible.** Read the history comment at
`ad_service.dart:61-76` first — the strict show rule is deliberate; don't loosen it. Options to
present to the owner: (a) preload App Open only when the app is backgrounded/resumed in a way that
could qualify (≥30 min away, ≥30 min since last), or on cold start when the last session ended ≥30 min
ago; (b) remove the format entirely (it earned ≈ $0.21/week). Recommend (a) if feasible, else (b).
Done when: App Open `ad_load_stats` events per session drop sharply without losing App Open impressions.

**2.3 Banner "Ad size will not fit on screen" bug.** Error shows `a_w=800/780, s_w=360`. In
`lib/widgets/ads/banner_ad_widget.dart:105-180`, check how the adaptive width is computed (logical vs
physical pixels, cached size from a different orientation/window, tablet vs phone, `sideInset`).
Clamp the requested width to the current logical screen width. Small volume, real bug.

**2.4 Reconcile `ad_load_stats` with AdMob.** Write down (in CLAUDE.md's Ad Load Diagnostics section)
how app-side requests map to AdMob requests (banner refreshes, retries, preloads), so future audits can
compare 24% vs 56% meaningfully.

**Done when:** analyze clean; owner approves; after a release, `ad_failed` per event and
"Too many recently failed requests" both drop, and AdMob match rate rises.

### Task 3 — Instrument the game-over ad decision, then (maybe) tune · AGENT
**Why:** ~1 full-screen ad per 10 game-overs vs a coded cadence of every 2nd. The likely main cause is
revive watches starting the 2-min shared gap (`ad_service.dart:53-59`), but nothing measures it.
Evidence: `04 §4.5`.

Steps:
1. Add an aggregated per-session counter (same pattern as `ad_load_stats` — one event on background,
   not one per game-over) of `GameOverAdGate.decide` outcomes with a reason:
   `first_game`, `cadence`, `interstitial_gap`, `fullscreen_gap`, `not_loaded`, `pro`, `shown_ri`,
   `shown_interstitial`, `ri_intro_skipped`. Route via the analytics facade (4 files), register GA custom
   definitions, document in CLAUDE.md.
2. Ship, wait 7 days, read the distribution.
3. Only then propose a change to the owner, e.g. "revive watch doesn't block the next game-over slot if
   ≥ N seconds of play happened in between". **Do not change frequency without owner approval** —
   retention is already weak. There is no Remote Config in the app (`lib/config/feature_flags.dart`
   is compile-time only), so any A/B test needs a mechanism; propose one (backend-served config or
   `firebase_remote_config` at the latest version) rather than hard-coding.

**Done when:** the decision-reason event is live and documented; a written recommendation exists.

### Task 4 — More reasons to watch a rewarded ad (outside the run) · AGENT (owner approves design)
**Why:** rewarded is the best format ($8–10 eCPM, above peers) but only ~13% of users earn a reward in
28 days; revive and time-bonus already exist in-run. 29% of started rewarded ads are abandoned.
Ideas to propose (pick 1–2, owner decides): "Double this run's coins" on the game-over screen (must not
collide with the rewarded-interstitial slot — coordinate with `GameOverAdGate`), daily bonus ×2,
"free item of the day" in the store, battle-pass XP boost (exists as `bp_xp` — check where it's surfaced).
Every placement goes through `showRewardedOrWait` with its own `placement`/`capKey` for analytics.
**Done when:** approved placements ship, each logs its own placement id, analyze clean.

### Task 5 — EU consent check · OWNER (+ AGENT if a fix is needed)
**Why:** ad-viewer rate FR 36%, IT 42%, DE 44% vs BR 84%, US 78%.
Owner pulls the Privacy & messaging report (Task 0.2 #1). If consent is the cause, review the UMP
message design in AdMob (wording, "Manage options" vs "Consent" prominence — stay policy-compliant).
Agent checks the app requests consent before the first ad and handles "consent required but not
obtained" without hammering requests.

### Task 6 — Banner policy-risk check · OWNER + AGENT
Check per-format CTR (Task 0.2 #3). If banner CTR is high (> ~2%), look at banner placements
(`home_screen.dart:525`, `game_screen.dart:715` top-of-game, `game_over_screen.dart:332`,
`multiplayer_lobby_screen.dart:244`, `lb_scaffold.dart:64`) for spacing to tappable controls.

---

## Phase 2 — Retention (the multiplier)

### Task 7 — Explain the Nov 8–10 D1 drop · AGENT (with Task 0.2 #4/#7 data)
D1 per cohort was 13–20% through October and fell to ~11% for the newest cohorts (Firebase: −30.6% WoW).
Check, in order: acquisition source / country mix change (Play Console), store-listing changes,
the 7.4.4 rollout, any first-session change in commits since Nov 1
(`git log --since=2026-11-01 --oneline` on master). Write findings to `PROGRESS.md` before proposing fixes.

### Task 8 — First-session experience audit · AGENT (owner approves changes)
Facts: 95% of installs start a first game (good), but `game_tutorial_started` reached **76 users**
in 28 days, `home_tour_started` 29% of new users, ~22% of players ever reach a 5th game
(`ad_service.dart:40-42` comment), DAU/MAU 6.7%, D7 ≈ 3–6%.
Steps: map the first 3 sessions in code (onboarding → first game → first game-over → home);
find why the tutorial almost never starts; check that the first game-over has no ad (it doesn't —
`GameOverAdGate` exempts it) and that the second session isn't ad-heavy; propose 3 concrete changes
(e.g. contextual tutorial in the first run, a day-2 reason to return such as a streak or daily
challenge surfaced at first game-over). Use existing events to measure.

### Task 9 — Push notification diet · AGENT (backend) — owner approves the new schedule
**Why:** 88,219 pushes received by 6,754 users in 28 d (~1/day each), **224 opens (0.25%)**.
Steps: inventory every push the backend sends (`HangfireJobScheduler.cs` + the job services listed in
`06 §6.1`), count sends per user per day from `NotificationHistoryRecorder` data if available, then
propose: a per-user cap (e.g. ≤ 3/week), quiet hours in the user's timezone, only-if-relevant rules
(e.g. no "daily challenge" push to users inactive > 14 days), and drop the lowest-value types.
`dotnet build` clean. **Done when:** owner approves and the cap is enforced server-side.

---

## Phase 3 — IAP, data quality, growth

### Task 10 — IAP visibility and failures · OWNER + AGENT
1. OWNER: link Google Play (and App Store) to Firebase so `in_app_purchase` revenue appears in GA.
2. AGENT: confirm a successful Pro subscription / coin pack logs an event with value + currency
   (GA shows no `purchase` event at all; `item_purchased` = 3). If missing, add it through the facade.
3. AGENT: pull `purchase_failed` error codes from GA (param `error`); 17 failures of 44 initiated.
   Map codes to causes (billing unavailable, declined, item already owned, app error) and fix any app-side ones.
4. Store discovery: only 183 users opened the store in 28 d — propose one contextual entry point.

### Task 11 — Analytics hygiene · AGENT
- `multiplayer_game_started` fires for 71 users vs `multiplayer_game_ended` 407 — find the missing call
  site(s) (`firebase_analytics_client.dart:161`, `logger_analytics_client.dart:122`).
- Update `CLAUDE.md` / owner memory notes where this audit found drift (ads caps — see README correction #3).

### Task 12 — Growth in high-value countries · OWNER (agent can draft)
US + UK + DE ≈ 9.7% of users but ≈ 33% of revenue. Agent drafts store-listing improvements
(title/subtitle/short description/screenshots captions) for en-US, en-GB, de-DE using
`store_listings/` and `play_store_screenshots/`; owner reviews and publishes.

### Task 13 — Account housekeeping (other apps) · OWNER
AI Persona (Android) restricted for "Ads in private communications"; several iOS apps "Requires
review — add store"; "Apps to confirm: 1". Not Snake Classic, but same AdMob account.

---

## Suggested order for day 1 at the office

1. Task 0.1 (read code) → 0.2 (send the owner the data checklist).
2. Task 1 agent part on a branch `feature/mediation-bidding` (after owner OK) — while the owner does the console checklist.
3. Task 2.1 + 2.3 on a branch `fix/ad-request-hygiene`.
4. Task 3 instrumentation on the same or a separate branch.
5. Write `PROGRESS.md`, summarize for the owner, ask which Phase 2 items to start.

## Success metrics to track weekly (baseline = this audit)

| Metric | Baseline (2026-11-12) | Where |
|---|---|---|
| 7-day AdMob revenue | $20.23 | AdMob home |
| Match rate | 56.38% | AdMob home |
| Overall eCPM vs peers | $1.26 vs $2.17 | AdMob eCPM Trends |
| Banner eCPM | $0.20–0.22 | AdMob |
| `ad_filled` / `ad_requests` per event | 0.92 / 3.9 | GA `ad_load_stats` |
| Full-screen ads per 100 game-overs | ≈ 10 | AdMob imps ÷ GA `game_over` |
| Users earning a rewarded reward (28 d) | 1,630 (≈13%) | GA `ad_reward` |
| D1 retention | 11.2% (latest week) | Firebase / GA cohorts |
| DAU | 675 | Firebase |
| Push open rate | 0.25% | GA `notification_open` ÷ `notification_receive` |

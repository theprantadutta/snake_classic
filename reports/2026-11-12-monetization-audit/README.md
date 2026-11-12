# Snake Classic — Monetization & Health Audit (2026-11-12)

> **For the Claude Code agent picking this up:** this folder is a complete, self-contained
> audit of Snake Classic's AdMob, Firebase and Google Analytics data, captured on
> **2026-11-12** by reading the live dashboards (read-only — nothing was changed in any
> console or in the code). Every claim links to a verbatim number in
> [`evidence/raw-data.md`](evidence/raw-data.md) and/or a screenshot in
> [`evidence/screenshots/`](evidence/screenshots/). **Your job is the action plan in
> [`07-action-plan.md`](07-action-plan.md).** Read the files in order before touching code.

## Read in this order

| # | File | What it answers |
|---|------|-----------------|
| 1 | [`01-executive-summary.md`](01-executive-summary.md) | One page: how the app is doing, the 5 biggest problems, the verdict on revenue |
| 2 | [`02-admob-revenue.md`](02-admob-revenue.md) | Where every ad dollar comes from (format, country, peers) |
| 3 | [`03-mediation.md`](03-mediation.md) | Why the auction has one buyer — bidding sources, waterfall, groups (plain-English explainer included) |
| 4 | [`04-ad-delivery-diagnostics.md`](04-ad-delivery-diagnostics.md) | Why ~3 of 4 ad requests fail, from the app's own `ad_load_stats` telemetry |
| 5 | [`05-users-retention-engagement.md`](05-users-retention-engagement.md) | Users, retention, lifetime value, funnels, versions |
| 6 | [`06-other-findings.md`](06-other-findings.md) | Push notifications, IAP, multiplayer, Crashlytics vs Sentry, tracking bugs, other apps in the account |
| 7 | [`07-action-plan.md`](07-action-plan.md) | **Prioritized tasks** with steps, files, acceptance criteria, and who does what |
| — | [`evidence/raw-data.md`](evidence/raw-data.md) | Every number, verbatim, with source URL — the proof |
| — | [`evidence/screenshots/`](evidence/screenshots/) | 32 screenshots of the dashboards (index at the bottom of raw-data.md) |

## Data provenance

- **Captured:** 2026-11-12 (Asia/Dhaka, UTC+6), from the account owner's logged-in Chrome.
- **Sources:**
  - AdMob — `https://admob.google.com/v2/...` (publisher `ca-app-pub-9242904787767394`)
  - Firebase console — project `snake-classic-2a376`
  - Google Analytics 4 — property `p503220063` (account `a167242807`), linked to that Firebase project
- **Windows used:** AdMob home = last 7 days vs previous 7; AdMob User Activity = last 30 days;
  AdMob eCPM Trends = last 14 days; GA reports = last 28 days (Oct 15 – Nov 11, 2026) unless stated.
- **Code state at time of audit:** `snake_classic` master @ `b22d056` (pubspec `7.5.0+73`),
  `snake-classic-backend` up to date with origin. Only read-only `git log` / grep was used.
- **Not looked at:** Google Play Console (installs/uninstalls by source, ANR, ratings), Sentry,
  App Store Connect, the backend database. Several action items ask you to pull these.

## Corrections vs. the first verbal summary (so you don't repeat them)

1. **Oct 14 D1-retention drop is NOT linked to 7.3.0.** GA's insight compares the Oct 12 vs Oct 13
   install cohorts (both before 7.3.0 shipped on Oct 14). D1 per cohort swings 13–20% all October;
   the *real* recent decline is the **Nov 8–10 cohorts (~19% → ~11%)**. See `05-…md`.
2. **Interstitial cadence:** plain interstitials are ~1 per 51 game-overs, but the game-over slot
   prefers **rewarded interstitials**; counting both, it is **~1 full-screen ad per 10 game-overs**,
   against a code cadence of "every 2nd game-over". See `04-…md`.
3. **Memory note `project_ads_stack.md` was stale**: it said "every 4th game-over + 5-min gap".
   Current code (`lib/services/ads/ad_service.dart:45-76`) is every **2nd** game-over, **90 s**
   interstitial gap, **2 min** shared full-screen gap, App Open **30 min** gap / **30 min** away.

## House rules that apply to every task (from CLAUDE.md + the owner's memory)

- Run **`flutter analyze`** (Flutter) / **`dotnet build`** (backend) clean before every commit. No tests required.
- **No stubs / placeholders / TODOs.** If something can't be done, stop and ask.
- **Always use the latest published package versions** (check pub.dev / NuGet and read changelogs).
- Commit only when the owner asks; branch first if on the default branch; **never add Claude/AI
  attribution to commit messages.**
- **Ads:** every change stays inside `AdService`'s gates (`adsEnabled = sdkReady && mobile && !Pro && canRequestAds`).
  The deprecated anchored-adaptive banner API and the banner retry/backoff + `adsEnabledListenable`
  are **deliberate and load-bearing** — don't "clean them up".
- **Analytics:** new events go through the 4-file facade (client interface, facade, firebase client,
  logger client). Production telemetry never fires in debug (gated at DI registration).
- **Offline-first:** Drift first, SyncEngine pushes; no SharedPreferences-only writes for synced state.
- Ask before running the app on a device; prefer Android. Test devices are shared — check the foreground app first.
- Release builds go through `tools/release_android.(sh|ps1)` (uploads Sentry symbols).
- There are open remote branches that may overlap ad/controls work: `feature/game-over-ad-notice`,
  `feature/dpad-feel`, `feature/floating-joystick`, `classic`. **Check them before starting ad work.**

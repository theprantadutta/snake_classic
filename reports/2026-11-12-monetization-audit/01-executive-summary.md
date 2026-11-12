# 01 — Executive Summary

## Verdict

**Revenue is not maximized.** Each ad *format* already earns at or above peer apps, so prices are
not the problem. Money is lost in four places:

1. **One buyer in the auction.** AppLovin, Liftoff and Unity are connected as bidding partners
   (partnership "Active") but have **0 ad units mapped** for any app, so only AdMob Network bids. → `03`
2. **~3 of 4 ad requests fail** at the SDK level (avg 3.9 requests → 0.92 filled per session per format).
   The biggest causes are *no fill* (demand → fixed by #1), a broken device WebView, blocked DNS, and
   requests that are loaded but never shown (App Open). → `04`
3. **Format mix is banner-heavy.** Banners are 87% of impressions but 16% of revenue. Full-screen
   formats earn 84% of revenue but are shown rarely. → `02`
4. **Retention is very weak.** D1 retention is 11–20% per daily cohort (most recent ~11%), D7 is
   ~3–6%, and the **average 120-day value per user is about $0.01**. Every ad fix multiplies by DAU,
   so retention is the ceiling on everything. → `05`

## Health dashboard (as of 2026-11-12)

| Metric | Value | Read |
|---|---|---|
| AdMob earnings (all apps) | Oct **$73.68**; Nov so far **$37.11** (on pace ≈ $90–100) | Growing |
| Snake Classic share | ~99% of account earnings (Android $19.98 of $20.23 last 7 d) | Single-app business |
| MAU / WAU / DAU | **10K / 3.4K / 675** (DAU/MAU ≈ 6.7%) | Low stickiness |
| New users (28 d) | **8.2K** (`first_open` 8,231 ≈ 294/day), above the casual-games peer median | Acquisition is fine |
| D1 retention | Firebase: **11.2%, −30.6% WoW**; GA cohorts 13–20%, latest ≈ 11% | **Main problem** (casual norm 25–35%) |
| D7 retention | ≈ 3–6% per cohort | Very weak |
| Avg 120-day value / user | ≈ **$0.01** | Can't afford paid UA |
| 7-day ad revenue | **$20.23**, eCPM $1.09, match rate 56–59% | |
| eCPM vs peers (14 d) | **You $1.26 vs peers $2.17** (Android Action Games, 12,286 apps) | Lower because of mix |
| Revenue per DAU | ≈ $0.0044/day | Very low |
| Crash-free | Firebase says 100%, **but Crashlytics was replaced by Sentry** — figure is meaningless | Check Sentry |
| Policy | Snake Classic clean (only AI Persona has an issue) | OK |

## Top 10 actions (detail + acceptance criteria in `07-action-plan.md`)

| # | Action | Who | Expected impact |
|---|---|---|---|
| 1 | Turn on mediation: map AppLovin / Unity / Liftoff ad units, add them to every mediation group, ship adapters, update app-ads.txt | Owner (console) + agent (code) | Biggest single ad lever (industry typical +10–30%, plus better fill) |
| 2 | Stop wasted / doomed ad requests (App Open preloaded every session but ~44 impressions/week; retry storms on DNS / WebView failures; banner size bug) | Agent | Cleaner fill metrics, less battery/data, fewer SDK throttles |
| 3 | Find why game-over full-screen ads run at ~1 per 10 game-overs vs the coded "every 2nd" — add decision telemetry first | Agent | Unlocks safe frequency tuning |
| 4 | Investigate the Nov 8–10 cohort D1 drop and the first-session experience (tutorial reached by 76 users) | Agent + owner | Retention multiplies all revenue |
| 5 | Add more opt-in rewarded reasons *outside* the run (double run coins, daily-bonus ×2, store freebie) — revive already exists; only 13% of users earn a reward in 28 days | Agent | Rewarded = $8–10 eCPM |
| 6 | Cut push volume (≈1/day/user, 0.25% open rate) | Agent (backend) | Fewer uninstalls / opt-outs |
| 7 | Link Google Play to Firebase; fix purchase tracking; investigate 17 failed of 44 initiated purchases | Owner + agent | IAP visibility |
| 8 | Check consent (Privacy & messaging report) — ad-viewer rate is 36–44% in FR/IT/DE | Owner | EU fill |
| 9 | Store-listing work for US/UK/DE (≈9% of users, ≈⅓ of revenue) | Owner | Higher-value installs |
| 10 | Fix analytics gaps (`multiplayer_game_started` under-fires; Crashlytics card is stale) | Agent | Trustworthy data |

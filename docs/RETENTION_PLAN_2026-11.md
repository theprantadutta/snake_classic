# Retention plan, November 2026

Written 2026-11-22 from the six reports in `D:\Desktop\self-improvements\addictive-games`,
a read of the code, GA4 (Oct 25 to Nov 21), and the backend telemetry tables. Nothing here is
built yet. It follows `RETENTION_PLAN.md` (August), which fixed the onboarding wall.

## 1. Where we are

| Metric | Now | Reports' "healthy" | Source |
|---|---|---|---|
| New players a day | ~300 (Android, organic Play search) | | GA4 cohorts |
| D1 retention | **14.4%** (no change since Nov 18) | 35–45% | GA4 cohorts |
| D7 / D14 | **3.5% / 2.2%** | 10–15% / | GA4 cohorts |
| First session, median | **1.3 min** (mean 3.1) | | telemetry_sessions |
| Runs finished / started, first session | **60%** | | telemetry_sessions |
| First session with exactly 1 run | 34% | | telemetry_sessions |
| Push received → opened | 7,329 → 154 players (2%) | | GA4 |
| `app_remove` in 28 days | 6,234 players (vs 8,442 `first_open`) | | GA4 |

### The one chart that matters

How many runs a player starts on day 0, against whether they come back
(installs Oct 20 to Nov 14, telemetry):

| Day-0 runs | Players | Avg minutes | Back on D1 | Back within 7 days |
|---|---|---|---|---|
| 0 | 2,187 | 0.7 | 1.6% | 4.2% |
| 1 | 2,266 | 2.2 | 9.0% | 18.8% |
| 2–3 | 2,276 | 4.2 | 15.0% | 27.0% |
| 4–6 | 743 | 8.8 | 27.6% | 41.3% |
| 7–12 | 367 | 17.0 | 42.2% | 58.9% |
| 13+ | 242 | 42.2 | 57.4% | 75.6% |

This is correlation, not proof: players who enjoy the game play more and return more. But it
says where to look. **Two thirds of new players stop after 0–3 runs.** Moving a player from one
run to four is worth about 3× the D1 return. The reports agree: the first minutes and the loop
come before monetization.

(The "0 runs" row doesn't match GA4, where 94% of installs fire `first_game_started`. Either
telemetry misses some runs or those players' first game lands on a later day. Phase A's analytics
work checks this before we trust that row.)

## 2. What the code does to a new player today

All verified in code on 2026-11-22.

1. **Two paid "second chances" before the score.** On the first death of game 1: a 1.8 s death
   animation, then a revive overlay (watch an ad or pay 1,500 coins, which a new player doesn't
   have) with a 10 s countdown. Then the game-over screen opens with an 8 s CONTINUE offer.
   Doing nothing costs about 12 s before the score even shows. `game_over` only fires after the
   window closes, which fits the 60% finish rate. A player who leaves during the revive overlay
   isn't even logged as backgrounded.
2. **The first game-over gets buried.** Full-screen trophy reveals (4.2 s each, blocking, usually
   `first_game` and `first_bite`) play over the CONTINUE countdown, then a mode-picker sheet sits
   between AGAIN and game 2. Three interruptions between death 1 and game 2.
3. **No controls hint.** Swipe is the default; the only cue is a small compass under the board.
4. **Nothing on game over gives a reason to come back.** It shows only this run (score, best,
   coins). No daily-challenge progress, no Season XP, no tomorrow's reward. The tomorrow card
   from August was removed.
5. **The Day-1 reminder rarely reaches anyone.** It is scheduled after game 1 without checking
   notification permission, but permission is only asked after 3 games and about 3 Home visits.
   Android 13+ drops it silently. It is also skipped whenever a backend session exists, and most
   online new players get a silent anonymous account within seconds.
6. **The daily login bonus is hidden.** It's only a popup, shown on roughly the third Home visit
   after onboarding. No Home tile, no streak on Home. The items it advertises (Speed Boost, 2× XP,
   1-day theme) are never granted; only the coins are.
7. **Coins buy almost nothing.** 1–10 coins a run (150/day cap). Skins, trails and themes are
   real money only, the cheapest power-up costs 500, and the Store tile still says "Skins,
   themes, trails". The coin loop has no visible goal.
8. **Progress is invisible.** Season XP is earned silently (no "+XP"), the Season tile has no
   bar, weekly quests live only inside the Daily screen, tournaments only in the menu.
9. **Small bugs.** The Home "resets in" countdown counts to local midnight, while challenges
   reset at 00:00 UTC. The `win_back` push promises a 100-coin bonus that the client never grants.

## 3. What the reports say, applied here

Used: the "never end on a dead screen" game-over, three goal horizons (this run / today / this
week), a calm first session, measuring the funnel step by step, the GMTK "no-regret purchase"
standard.

Not used, on purpose: random loot chests and mystery multipliers (gambling-adjacent, wrong for
an all-ages snake game), skip-ad tickets, card or base-building metas (a different genre),
soft launch and paid UA (only pays once D1 is healthy).

Treat the reports' numbers ("revive conversion 40–60%" and so on) as rules of thumb, not
benchmarks. Our own telemetry is the yardstick.

## 4. The plan

Ordered by expected retention impact per unit of effort. Each item names how we'll measure it.

### Phase A: measure first (1–2 days, ships with Phase B)

Without these we can't tell whether anything below works. Details in section 5.

### Phase B: the first three minutes (biggest lever, ~3–4 days)

Goal: more players reach runs 2, 3 and 4 on day 0.

| # | Change | Why | Measure |
|---|---|---|---|
| B1 | **No revive overlay and no CONTINUE in a player's first 3 games** (`isInOnboarding`). Death goes straight to game over in about 2 s, AGAIN usable at once. | Removes ~12 s of paid offers from the moment a new player decides whether to try again. A new player can't afford the coin path anyway. | day-0 runs, `game_over.run_number` 1→2 rate, time from death to next run |
| B2 | **Trophy reveals during onboarding become a small inline row** on the game-over card instead of full-screen 4.2 s takeovers. | Stops the first game-over being buried. | same, plus taps on AGAIN |
| B3 | **Drop the mode-picker sheet from the game 1 → game 2 path.** Offer modes later (Home, or after game 3). | One less decision before game 2. | 1→2 rate |
| B4 | **First-game controls hint**: "Swipe to turn" (or the active scheme) over the board until the first input, then gone. | No-hint deaths look like "this game is broken". | new `first_input` event, time to first input, game-1 score |
| B5 | Decide: **no banner during the first game** (Home banner stays). | The first impression is an ad plus a game. Revenue cost is tiny: one banner session per install. | day-0 runs vs revenue per install |

### Phase C: a reason to come back (game over + Home, ~4–5 days)

Goal: every session ends with something unfinished, and tomorrow has a visible reward.

| # | Change | Measure |
|---|---|---|
| C1 | **"Next goals" panel on game over** (from game 2 on): today's daily challenges as bars (x/3, closest one highlighted), "+N Season XP" with a bar to the next tier, and **tomorrow's login reward** ("Come back tomorrow: day 2, +3 coins"). Replaces the dead end. | `next_goal_shown/tapped`, D1 |
| C2 | **Daily bonus on Home**: a tile or badge with the streak, claimable in one tap, available from the first session after game 1 (not only via the queued popup on visit ~3). | `daily_bonus_collected` share of DAU, D1/D2 |
| C3 | **Fix the bonus promises**: actually grant Speed Boost / 2× XP / 1-day theme, or remove them from the popup. | — |
| C4 | **Season tile shows an XP bar**; show "+XP" when it's earned. Weekly quest progress on Home (a line on the Daily tile). | season tier reach, weekly quest completion (new events) |
| C5 | Fix the "resets in" countdown to UTC, and grant (or drop) the `win_back` bonus. | — |

### Phase D: reminders that actually arrive (~2–3 days, needs backend)

| # | Change | Measure |
|---|---|---|
| D1 | **Ask notification permission in session 1** at a meaningful moment: after the first game-over that sets a best score, "Want a reminder tomorrow to beat 340?", then the system prompt. Today it waits for 3 games plus ~3 Home visits, after most churners have left. | `notification_permission` (shown/granted/denied, placement), permission rate |
| D2 | **Make the Day-1 reminder reach people**: schedule it only when permission is granted, and stop skipping it just because a silent anonymous session exists. To avoid a double ping, the server's daily reminder skips installs younger than 2 days, so day 1 is always the local one. | `push_opened` with `push_type=day1`, D1 among permission-granted players |
| D3 | Server reminder copy keeps using the player's real goal (best score, streak, unfinished dailies); check that the 3-per-week cap still holds. | `push_opened` rate by type |

### Phase E: make coins mean something (needs your decision, ~3 days)

| # | Change |
|---|---|
| E1 | A few **coin-priced cosmetics** (for example 2 trails and 1 skin at 300–800 coins) so a free player has a visible goal within about a week. Real-money items stay. |
| E2 | Store tile copy matches reality, or points at the new coin items. |

This is the "positive feedback loop" and "fantasizing about the future" pillar: a free player
needs something to save for. It also helps D7 more than D1.

### Later, not now

ASO and store screenshots, iOS ratings, Pro trial framing, Remote Config A/B tests. They pay off
once D1 is higher.

## 5. Analytics to add (so we can check all of this later)

### GA4 events

| Event | Params | Why |
|---|---|---|
| `game_over` (extend) | add `run_number`, `game_mode`, `onboarding` (0/1) | first-run funnel, per-mode counts; today only `game_abandoned` has them |
| `game_backgrounded` (extend) | add `game_mode`, and log it during the revive overlay too | it currently skips that state |
| `first_input` | `seconds_since_run_start`, `control_scheme` | does the hint help? |
| `revive_offer` | `outcome` (ad / coins / declined / timeout / backgrounded), `run_number` | the cost of the overlay |
| `next_goal_shown` / `next_goal_tapped` | `goal` (daily / season / tomorrow / quest) | does C1 work? |
| `daily_bonus_collected` (extend) | add `day`, `streak`, `doubled` (0/1), `surface` (popup / home) | today the two claim paths look identical |
| `streak_broken` | `previous_streak` | streak health |
| `weekly_quest_completed` / `weekly_quest_claimed` | `quest_id` | weekly quests have no events at all |
| `notification_permission` | `stage` (soft_shown / soft_accepted / soft_declined / os_granted / os_denied), `placement` | does D1 work? |
| `day1_reminder` | `result` (scheduled / skipped_no_permission / skipped_pref) | does D2 work? |

User properties: `onboarding_done` (0/1), `notif_permission` (granted/denied/undecided),
`install_week` (ISO week), so every GA4 report can be split by them.

Remove or wire the three dead methods (`username_set`, `unlock_achievement`, `replay_shared`).

### Server telemetry

- Telemetry should also count `game_abandoned`, `revive_offer` outcomes and per-mode runs, so the
  server tables (which cover every install, guests included) can answer these questions too.
- **Retention page in the admin dashboard**, reading `telemetry_installs`,
  `telemetry_activity_days` and `telemetry_sessions`:
  - D1 / D7 / D30 by install week and by first app version (the before/after view for every
    release)
  - the day-0 runs table above, per week
  - first-session minutes, runs started/finished, "played again within 60 s" rate
- Commit the read-only query script used for this plan
  (`snake-classic-backend/tools/retention-query.cs`) so anyone can rerun the numbers.

### How we judge it

There's no A/B framework, so we compare **install cohorts by first app version** in telemetry:
the release with Phases A+B against the cohorts before it, read at 2 and 4 weeks.

Targets for the first release with A + B + C:

| Metric | Now | Target |
|---|---|---|
| D1 | 14.4% | 20% |
| D7 | 3.5% | 6% |
| Installs with 4+ day-0 runs | 17% | 30% |
| First-session finish rate | 60% | 80% |
| Notification permission granted, first 2 days | unknown | measure, then set |

## 6. Decisions (owner, 2026-11-22)

All approved: B1 yes, B5 yes, C3 grant the items properly, D1 yes, E1 yes (Claude picks the items; also "watch two rewarded ads to wear it for a day"), and everything ships together in one release, measured afterwards and rolled back item by item if something is off.

### Original questions

1. **B1**: skip revive and CONTINUE in the first 3 games? It costs a few rewarded-ad views from
   new players and is the biggest single first-session fix.
2. **B5**: hide the gameplay banner during a player's very first game?
3. **C3**: grant the daily-bonus items, or remove them from the popup?
4. **D1**: ask for notification permission after the first new best in session 1?
5. **E1**: add a few coin-priced cosmetics? Which ones and at what prices?
6. Release grouping: A+B+C in one release (my suggestion), D next (it touches the backend), E
   after that.

## 7. Housekeeping found on the way

- **8.0.2+83 is live on about 200 Android devices** (its banner bug can blank banners). Ship
  8.0.3+84 to the same track soon.
- **7.7.0 and 7.7.3 were released** (about 920 active installs). `store_listings/release_notes.md`
  says the 7.7.x builds were never uploaded; that line needs correcting.

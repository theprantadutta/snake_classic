# 05 — Users, Retention, Engagement

## 5.1 Activity

| Window | Active users | Source |
|---|---:|---|
| 30 days | 10K (+5.4%) | GA home / Firebase dashboard |
| 7 days | 3.4K (+4.7%) | same |
| 1 day | 675 (+10.8%) | same |
| 28 days new users | **8.2K** | GA Games → Retention (`ga-08-…`) |
| 28 days returning users | 4.2K | same |

- **DAU/MAU ≈ 6.7%** — low stickiness (casual games usually 10–20%).
- **New users run above the "Casual Games" peer-median band** on GA's chart (`ga-08-…`):
  acquisition is healthy; keeping players is the problem.
- `first_open` 8,231 vs DAU 675 → most daily users are recent installs.
- Platforms (Firebase overview, `firebase-02-…`): Android DAU 672, iOS 3, web 0.
- Devices: mostly Samsung A-series / mid-range (SM-A566B, SM-A175F, SM-A065F, SM-A165F, SM-A556E,
  plus S24/S25 Ultra) — performance on mid-range Android matters.
- Last 7 days by country: India 772, Brazil 402, US 152, Russia 101, Türkiye 100, Mexico 99, UK 95.

## 5.2 Retention

| Measure | Value | Source |
|---|---|---|
| Firebase D1 retention (last week) | **11.2%, −30.6% WoW** (Android 11.3%) | `firebase-01-…` |
| GA D1 retention per daily cohort, Oct 15 – Nov 10 | **~13–20%**, dropping to **~11%** for the latest cohorts (≈ Nov 8–10) | `ga-09-retention-by-cohort.jpg` (blue line) |
| Second cohort line (GA default = D7) | **~3–6%** (latest points are 0 because those cohorts are incomplete) | same (green line) |
| 42-day retention curve | falls steeply after Day 1 to a low single-digit floor by Day 10 | `ga-10…`/home card |
| **Average 120-day value per user** | **≈ $0.01** | `ga-10-average-120d-value.jpg` |

Benchmarks (casual mobile games, typical): D1 25–35%, D7 8–15%, D30 3–6%.

**Correction to the earlier verbal summary:** GA's insight "Day 1 retention of new users decreased by
6.59 pps on Oct 14" compares the **Oct 12 vs Oct 13** cohorts (`ga-15-insights-b.jpg`), both before
7.3.0 shipped on Oct 14 — it's ordinary day-to-day noise, **not** a 7.3.0 regression. The decline that
needs explaining is the **most recent cohorts (≈ Nov 8–10)**, also visible as Firebase's −30.6% WoW.
Possible drivers to check: traffic-source/country mix change, a store-listing change, the 7.4.4 rollout,
or a first-session change. Use GA Explore → Cohort exploration split by country, app version and
first-user source.

## 5.3 What a typical player does (28 days, `ga-01..06-…`, raw-data §C2)

| Signal | Value | Read |
|---|---|---|
| `onboarding_step_completed` | 8,170 users (≈ every new user) | Onboarding completes |
| `first_game_started` | 7,821 users (**95% of installs**) | Funnel into the first game is good |
| `game_started` | 61,694 events / 9,011 users = **6.85 games per user in 28 days** | Low |
| `game_over` | 43,442 / 6,326 users | |
| Avg engagement time per active user | **11 m 58 s over 28 days** (GA app-version report total) | ≈ 1.7 min per game incl. menus — short sessions |
| `home_tour_started` | 2,356 users (29% of new users) → finished 1,297, skipped 869 | Most never see the tour |
| **`game_tutorial_started`** | **76 users** (finished 10, skipped 49) | **Tutorial is essentially unseen** |
| `level_up` | 70,280 / 5,425 users | XP system is used |
| `power_up_used` | 50,397 / 5,139 users | |
| `battle_pass_tier_reached` | 5,543 / 3,052 users | |
| `daily_bonus_collected` | 3,347 / 1,395 users (11%) | Daily habit loop reaches few |
| `daily_challenge_reward_claimed` | 324 / 120 users | Very low |
| `leaderboard_viewed` | 465 / 220 users | Very low |
| `review_requested` | 427 / 411 users | |
| `app_remove` | 5,980 / 5,971 users | ≈ 73% of the 8.2K installs in the same window (not a strict cohort) |

## 5.4 App versions (28 days, `ga-07-app-versions.jpg`)

| Version | Active users | New users | Engaged sessions | Engagement rate | Eng. sessions / user | Avg engagement / user | Revenue |
|---|---:|---:|---:|---:|---:|---:|---:|
| 7.3.0 | 4,195 | 3,296 | 8,991 | 87.48% | 2.14 | 11m 15s | $34.39 |
| 7.4.4 | 4,154 | 3,425 | 7,866 | 90.18% | 1.89 | 10m 24s | $28.55 |
| 7.4.3 | 1,909 | 1,413 | 3,552 | 88.23% | 1.86 | 10m 45s | $14.09 |
| 7.2.2 | 287 | 20 | 527 | 81.33% | 1.84 | 8m 33s | $0.96 |
| 6.7.0 | 78 | 2 | 185 | 75.2% | 2.37 | 10m 31s | $0.07 |
| 7.2.1 | 64 | 10 | 117 | 73.58% | 1.83 | 8m 19s | $0.09 |
| 7.3.1 | 47 | 41 | 95 | 91.35% | 2.02 | 10m 07s | $0.91 |

Release dates (from pubspec bumps): 7.3.0 Oct 14, 7.3.1 Oct 22, 7.4.0–7.4.3 Oct 27, 7.4.4 Nov 1, 7.5.0 Nov 12.
7.4.3 → 7.4.4 changed only: music loops held in memory, Zen/Speed games counting toward daily
challenges, release notes (`git log cbf60d8..fecead4`).

GA's insights flagged "46% more engagement time on 7.4.3 than 7.4.4 (Oct 28 – Nov 3)" and "15% fewer
engaged sessions on 7.4.4". Over the full 28 days the gap is small (10m45s vs 10m24s), and early
adopters of a new version skew the 7-day comparison. **Treat as a watch item, not a regression** —
re-check once 7.4.4 / 7.5.0 have a full week of mixed users.

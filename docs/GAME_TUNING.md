# Game tuning and adaptive assist (Nov 2026)

Server-driven tuning (no Firebase Remote Config, which is now paid) plus an
adaptive assist for players who keep dying early, shipped behind an A/B
experiment. Owner asked for it on 2026-11-28 after reading how Candy Crush
tunes difficulty.

## Why: the day-0 data

Backend telemetry, Android installs first seen Oct 15 – Nov 24 2026
(`telemetry_sessions` + `telemetry_activity_days`, every install including
guests). "Day 0" = the install's first local day; D1 = active the next day.

| Day-0 average run length | Installs | D1 | D7 |
|---|---|---|---|
| < 15 s | 482 | 8.3% | 4.4% |
| 15–30 s | 1,215 | 13.7% | 6.3% |
| 30–60 s | 1,171 | 21.9% | 10.9% |
| 60–120 s | 1,362 | 30.2% | 13.8% |
| 120 s+ | 1,318 | 33.4% | 17.1% |

The same gap holds at equal run counts (1–3 runs: <30 s → 10.8% D1,
60 s+ → 24.3%; 7+ runs: 36.7% → 61.6%). Day-0 best score shows the same
shape (<50 → 14.6% D1, 1000+ → 47.5%).

Skill drives both survival and return, so this cannot prove that slowing the
game helps. That is why assist ships as an experiment, not for everyone.

Other findings from the same pull:
- **Interstitials:** at equal day-0 run counts, players who saw one had no
  lower D1 (small samples). Cadence stays at every 2nd game; it is tunable.
- **Unfinished first runs:** before 8.1, ~27% of installs that started a run
  on day 0 never finished one. In 8.1.0 that is 6.3% (the finalize-on-
  background fix). Installs with no run at all have a median 1.4 s
  foreground: not real sessions.
- **GA4 can't answer this yet:** `game_over.run_number` only arrived in
  8.2.0 (Nov 26). Telemetry is the source until GA4 has a few weeks.

## How tuning works

```
dashboard /game-tuning ──PUT──▶ API ──▶ game_tuning_configs (one row, jsonb)
                                         │
app launch ──GET /api/v1/game-tuning ◀───┘  (anonymous, 30 s server cache,
     │                                       60 s Cache-Control, ETag)
     ▼
TuningService: cached doc (SharedPreferences) → built-in defaults → clamp
     │  resolves experiments per install (sticky)
     ▼
GameCubit.startGame reads TuningService.current once per run
AdService reads interstitial cadence; revive price reads revive_coin_cost
```

- **Defaults = pre-tuning behaviour.** An unreachable server, a 404 (backend
  not deployed yet) or an empty document all play exactly like 8.3.
- **Every value is clamped** in `GameTuning.fromValues`
  (`lib/services/tuning/game_tuning.dart`); unknown keys are ignored, so a
  newer dashboard never breaks an older app.
- **Applies from the next run**, never mid-game.
- **Backend:** `GameTuningConfig` entity, migration
  `20261128092917_AddGameTuningConfig` (seeds an empty document),
  `GameTuningDocument` validates shape (snake_case keys, number/bool
  values, 2–6 variants, weights 0–1000, ≤ 16 KB), version check on save
  (409 if someone saved in between).
- **Dashboard:** Live ops → Game tuning. JSON editor, a reference table of
  every key, and an "Insert assist A/B template" button.

### Knobs (keep in sync with the dashboard table)

| Key | Default | Range |
|---|---|---|
| `assist_enabled` | false | bool |
| `assist_max_level` | 3 | 0–3 |
| `assist_window_runs` | 5 | 2–10 |
| `assist_early_death_s` | 15 | 5–60 |
| `assist_speed_step_ms` | 25 | 0–40 |
| `assist_ramp_step` | 0.15 | 0–0.3 |
| `assist_best_score_cap` | 500 | 0–100000 |
| `onboarding_start_speed_ms` | 380 | 300–450 |
| `interstitial_every_n_games` | 2 | 1–10 |
| `interstitial_min_gap_s` | 90 | 30–600 |
| `revive_coin_cost` | 1500 | 100–10000 |

### Experiments

```json
{
  "values": {},
  "experiments": [
    { "key": "assist_v1", "audience": "new", "enabled": true,
      "variants": [
        { "name": "control", "weight": 50, "values": {} },
        { "name": "assist",  "weight": 50, "values": { "assist_enabled": true } } ] } ]
}
```

- **Assignment:** FNV-1a 32 of `"{key}:{installId}"` mod total weight, on
  the cumulative weights. Same function in Dart (`fnv1a32`) and C#
  (`GameTuningBuckets`), pinned by the same test vectors, so the server can
  recompute any install's group from telemetry.
- **Sticky:** the first variant an install gets is stored on the device
  (`tuning_exp_<key>`); re-weighting or editing never moves a player.
- **`audience: "new"`:** only installs that had not started a game when they
  first received the experiment. Others are stored as excluded and keep the
  base values. Use this for anything judged by D1.
- `enabled: false` pauses an experiment (nobody gets variant values; stored
  enrolments are kept for when it is re-enabled).

## Adaptive assist

`lib/game/assist/adaptive_assist.dart`.

- **Level 0–3** from the share of early deaths (runs < 15 s) in the last 5
  runs: <20% → 0, 20–49% → 1, 50–74% → 2, 75%+ → 3. Needs 2 runs.
- **Effect per level:** +25 ms starting tick (Normal 300 → 325/350/375) and
  the level and length speed-ups scaled by `1 − 0.15 × level` (min 0.4), via
  `GameState.rampScale`. A rampScale of 1.0 is the old curve exactly (test).
- **Scope:** Normal difficulty only; classic, multi-food, power-up madness
  and survival; never tournaments, speed challenge, time attack, perfect
  game or zen; never once the best score reaches 500.
- **Onboarding** (first three games, 380 ms start) is unchanged for everyone.
  Assist can only make a start slower than that, never faster.
- **Run history:** last 10 run lengths on the device
  (`assist_recent_runs_v1`), Normal non-tournament runs, recorded at
  finalization (a continued run counts once).

### What assist deliberately does not do

The reverse-engineering write-up about Candy Crush (Nov 2026) describes a
system that tracks how close each player is to winning, makes the game
harder for players doing well, and prices boosters per player by how
desperate they look. We are not doing any of that:
- Assist only ever makes the game **easier**. Nothing makes it harder for a
  player who is doing well.
- Difficulty is **never tied to monetization**: prices, rewards and ads are
  the same for every player (the A/B knobs change them for a whole group,
  never per player based on how they play).
- It is scoped so it can't affect anyone near a leaderboard.

Per-player price discrimination on desperation is also a store-policy and
consumer-protection risk (EU unfair-practices rules), on a developer account
shared by ~20 apps.

## Measuring it

- **`game_over`** gained `difficulty`, `start_speed_ms`, `assist_level`,
  `tuning_version`, `exp_variant` (e.g. `assist_v1:assist`).
- **User property `exp_variant`** (or `none`), set after each tuning refresh.
- **GA4 custom definitions for these still need registering** (property
  snake-classic-2a376): dimensions `exp_variant` (user scope),
  `exp_variant_run` ← `exp_variant` (event), `difficulty`, metrics
  `assist_level`, `start_speed_ms`, `tuning_version`. They only collect from
  the day they are registered.
- **Primary read: D1 and D7 by variant** from backend telemetry: recompute
  each install's group with `GameTuningBuckets.VariantFor` for installs
  first seen after the experiment started (≈ new installs on a build with
  tuning). Secondary: day-0 runs and average run length per install.
- **Sample size:** ~200 new Android installs/day, ~14% D1. Detecting a
  3-point D1 lift (14% → 17%) at 80% power needs ~2,300 installs per group,
  about 3–4 weeks at 50/50.

## Rollout

1. Owner deploys the backend and runs the migration (seeds an empty
   document: no behaviour change).
2. Ship the app build with tuning (next version after 8.3.0).
3. When most new installs are on that build, insert the assist template on
   the dashboard and save.
4. Read results after 3–4 weeks. Ship assist to everyone (move
   `assist_enabled: true` to base values, drop the experiment) or turn it
   off.

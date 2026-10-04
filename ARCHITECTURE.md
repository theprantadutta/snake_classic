# Snake Classic — Gameplay Architecture

How a game of snake actually runs, where each concern lives, and where new
code should go. (Offline-first sync rules, store layout and tablet
responsiveness live in `CLAUDE.md` — this file covers the gameplay engine.)

## The big picture

```
                 ┌────────────────────────────────────────────┐
 input           │                GameCubit                    │   emits GameCubitState
 (swipe/dpad/key)│  owns: tick Timer, input queue, pause      │──────────────────────────┐
 ───────────────▶│  accounting, revive/time-attack flows,     │                          │
                 │  per-run trackers                           │                          ▼
                 │                                             │        ┌──────────────────────────────┐
                 │  SnakeSimulation.step(state) ── pure ──▶    │        │ Consumers (per-tick)         │
                 │      TickResult { nextState, events }       │        │  • FlameGameBoard→SnakeFlame │
                 │                                             │        │    Game (render+interpolate, │
                 │  events → GameFeedback (audio+haptics)      │        │    particles from tickEvents)│
                 │  events → trackers/analytics/XP buffers     │        │  • game_screen juice (shake, │
                 │  events → emitted as state.tickEvents       │        │    popups from tickEvents)   │
                 └──────────────┬──────────────────────────────┘        │  • GameHUD / bottom bar      │
                                │ game over                             │    (scoped BlocBuilders)     │
                                ▼                                       └──────────────────────────────┘
                 ┌────────────────────────────────────────────┐
                 │ GameEndPipeline (shared with multiplayer)   │
                 │  coins → XP → stats → achievements → cache  │
                 │  → challenge/quest batches → backend syncs  │
                 └────────────────────────────────────────────┘
```

## The layers

### 1. Pure engine — `lib/game/engine/`
- **`snake_simulation.dart`** — ALL game mechanics: movement, wall/self
  collision, food eating/expiry/regeneration, power-up collection/expiry,
  combo streaks and decay, level math, mode rules (zen wrap, multi-food,
  no-revisit). Zero side effects, zero service imports. `step(state)` returns
  a `TickResult`.
- **`tick_result.dart`** — the sealed `TickEvent` hierarchy
  (`FoodEatenEvent`, `LeveledUpEvent`, `PowerUpCollectedEvent`,
  `ComboBrokenEvent`, `CrashEvent`). Events carry everything a consumer
  needs (eaten food + position, awarded points, combo multiplier…) so nobody
  re-derives gameplay facts.
- **Tested** in `test/game/engine/` (~84 tests). If you change mechanics,
  change/extend these tests first.

### 2. Orchestration — `lib/presentation/bloc/game/game_cubit.dart`
Owns the run lifecycle, NOT the mechanics and NOT the rendering:
- **Tick loop**: a self-rescheduling one-shot `Timer`. Each tick calls
  `_simulation.step()`, translates events into bookkeeping, and emits.
- **Two-clock invariant (load-bearing)**: Flame's `update(dt)` only
  interpolates between the last two emitted states. The interpolation window
  is `GameCubitState.tickDurationMs`, snapshotted once per tick by
  `_computeNextTickDurationMs` and used for BOTH the armed Timer and the
  renderer. Never interpolate against the live `gameState.gameSpeed` getter —
  it jumps when speed power-ups collect/expire and the snake visibly slides
  backward/forward (that was a real bug).
- **Mid-tick emits must not restart interpolation**: some emits swap the
  `gameState` object without a tick having happened (the periodic power-up
  spawn timer, armed power-up activation). The renderer restarts its
  interpolation clock only when `previousGameState` identity changes —
  which tick emits always do and mid-tick emits never do. Keying the reset
  on `gameState` identity made the snake visibly snap back and re-run its
  move every time a power-up appeared (that was also a real bug). If you
  add a new mid-tick emit, do NOT touch `previousGameState`.
- **`GameCubitState.tickEvents`**: the emitted per-tick events — the single
  source of truth for "what happened". Consumers key off
  `identical(gameState)` changes and read these. Do not add state-diffing
  event detection anywhere; there used to be three parallel copies.
- **Flows kept in the cubit** (deliberately — they are woven into state
  emission and pause wall-clock accounting): pause/resume time-shifting,
  crash → revive offer, Time-Attack countdown/+30s offer, tournament score
  submission, replay recording.
- Heavy work never rides a tick: level-up coin grants are buffered in
  `_pendingLevelUpCoinLevels` and flushed at game end / reset / backToMenu.

### 3. Feel — `lib/game/session/game_feedback.dart`
`GameFeedback` is the ONE audio+haptic mapping for in-play tick events
(eat, combo tiers, level-up, power-up pickup, expiry countdown buzzes).
Adding a new pickup type? Its sound/vibration goes here, its particles go in
`SnakeFlameGame._emitEventParticles`, its screen juice in
`game_screen._checkForGameEvents` — each keyed on the same `TickEvent`.

### 4. Game end — `lib/services/game_end_pipeline.dart`
`GameEndPipeline` is the single rewards/stats choreography, shared by
single-player AND multiplayer:
- input: `lib/game/session/game_run_summary.dart` (`GameRunSummary`) — the
  cubit packages its per-run trackers into this value object.
- `evaluateLocalUnlocks` (sync, before the game-over screen shows) →
  `runPostGame` (async fire-and-forget: coins → XP → Drift stats →
  lifetime/general achievements → cache refresh → challenge/quest batches +
  XP flush → backend re-sync).
- Multiplayer entry points: `recordMultiplayerMatch`,
  `creditMultiplayerRewards`.
- **Change reward rules here and only here.** Coin grants return the amount
  actually credited (post-cap/multiplier) so callers keep accurate per-game
  totals.

### 5. Rendering — `lib/game/flame/`
Flame drives the loop/camera/components; pixels are drawn by the shared
`CustomPainter`s in `lib/game/flame/rendering/` (see the Flame-migration
notes in git history). `SnakeFlameGame`:
- interpolates snake position over `tickDurationMs` (see invariant above),
- emits particles from `tickEvents`,
- runs the crash sequence (lunge → camera shake → white blink →
  disintegration) on its own render clock,
- loads the generated sprite art (`BoardSprites`, nullable per-image with
  procedural fallback — rendering never depends on assets existing).

### 6. Screen chrome — `lib/screens/game_screen.dart` + `lib/widgets/`
The screen wires input (swipe/keyboard/d-pad), overlays (pause, crash,
revive, time-bonus, tutorial), navigation, and event-driven juice. Rebuild
discipline: the outer `BlocBuilder` rebuilds on STRUCTURAL changes only
(status/crash modal/overlays/tournament); score/level/combo/power-up changes
rebuild just the scoped HUD and bottom-bar builders. Don't add per-tick
fields to the outer `buildWhen`.

### 7. Multiplayer — server-authoritative, local snake predicted
Online Versus runs on the server (`MatchRoom` in the backend); the phone
sends direction tokens and renders `Tick` snapshots. The rival is drawn a
tick behind, exactly as the server says. Your own snake is predicted one
step ahead so a turn does not wait out the ~190ms round trip:
- **`lib/game/multiplayer/local_snake_predictor.dart`** — pure. Replays the
  inputs not yet seen applied through a transcription of `MatchRoom`'s rules
  (one commit per tick, reversals skipped, repeat stops the drain, 2-deep
  buffer dropping the oldest; growth on food). Applied inputs are inferred
  from each snapshot's committed direction — exact because the client only
  sends real turns relative to the newest pending input. An input is
  predicted only for the tick it can reach (`etaFor`: send time vs. snapshot
  arrival + measured round trip). Never predicts death, the rival, score or
  food; never more than one step ahead. Tested in `test/game/multiplayer/`.
- **`MultiplayerCubit`** feeds it (accepted inputs, every snapshot) and emits
  `MultiplayerState.localPrediction`. The repeat/reversal reference for a new
  input is the predictor's newest pending input (what the server will
  validate against), not the last snapshot's direction. `SendInput` is an
  invocation so its completion times the round trip.
- **`MultiplayerFlameGame`** glides the local snake from the snapshot to the
  predicted step on the shared interpolation clock and eases any change of
  path through `CorrectionBlend` (`snake_glide.dart`) instead of snapping.

## Where does my new feature go?

| You're adding…                       | It goes in…                                                |
|--------------------------------------|------------------------------------------------------------|
| A new game rule / collision / mode   | `SnakeSimulation` (+ a `TickEvent` if hosts must react) + tests |
| A new pickup's sound/vibration       | `GameFeedback.onTickEvents`                                |
| A new pickup's particles / popup     | `SnakeFlameGame._emitEventParticles` / `game_screen._checkForGameEvents` |
| A new end-of-game reward or stat     | `GameEndPipeline` (both game types get it automatically)   |
| A new HUD element                    | `GameHUD` (its own scoped BlocBuilder)                     |
| A multiplayer rule change            | Backend `MatchRoom` AND `LocalSnakePredictor` (+ its tests) |
| A new overlay                        | `game_screen` overlay stack (outside SwipeDetector if it has buttons) |
| A new cubit dependency               | Constructor-injected + registered in `core/di/injection.dart` — no `getIt` inside methods |

## Testing

`flutter test` — the simulation suite in `test/game/engine/` is the
regression net for all mechanics. It manipulates state timestamps instead of
sleeping, so it's fast and deterministic. There are no widget/cubit tests
yet; if you refactor the cubit's flows (pause accounting, revive,
time-attack), add tests there first.

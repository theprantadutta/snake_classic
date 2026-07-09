# Snake Classic — Full Gameplay / UI/UX / Systems Analysis

> Deep-dive review of the engine, cubits, UI/UX, audio, haptics, assets, and meta-systems
> (achievements, battle pass, tournaments, economy). Generated 2026-07-07.
> Use the checkboxes to track fixes gradually. Line numbers are approximate anchors —
> they will drift as the code changes.

---

## TL;DR

Engineering fundamentals are genuinely good. The product problem: a live-service shell was
built around the snake game, and a chunk of that shell is quietly broken or fake —
tournament scores are never submitted (while the UI says "SUBMITTED!"), ~26 of 100
achievements can never unlock, the "combo" never breaks so it's not a combo, and a new
player faces 5+ blocking popups before their first snake move.

---

## What's genuinely good (keep doing this)

- **`SnakeSimulation` is the best code in the repo** — pure, side-effect-free mechanics core;
  `step()` returns `(nextState, events, crashed)`; `GameCubit` translates events into
  audio/haptic/coin/XP side effects (`lib/game/engine/snake_simulation.dart`).
- **Classic snake bugs solved correctly:**
  - 180° reversal validates against `_lastCommittedDirection`, not the pending direction
    (`snake.dart:95-110`).
  - Tail-vacate collision is classic-correct: chasing your tail into a vacating cell is
    legal, but that cell kills you if you just ate (`snake.dart:47-88`).
- **Flame is renderer-only** — logic stays step-based, Flame interpolates visually with `dt`
  (`snake_flame_game.dart:199-231`). Correct model for snake.
- **Ad engineering is the most mature part of the app** — interstitial only on game-over exit,
  skips first-ever game over, min-gap + every-N + no back-to-back full-screen; app-open ads
  suppressed while game screen mounted; all rewarded ads opt-in.
- **HUD anti-reflow discipline** — fixed row heights, `_PowerUpRing` runs its own ticker,
  bottom bar reserves identical height in every state so the board never shifts.
- **Exploits already closed:** pause-abuse (timers freeze via `pausedAt` stamping),
  TimeAttack revive disabled (would refill the clock), +30s ad extension capped at 2/run.
- Exit protection (`PopScope` + confirmation), full keyboard support (WASD/arrows/space),
  spawn generators that can't deadlock, achievement checks on game-over instead of per-tick,
  speed re-read fresh each tick so level/power-up speed changes apply immediately.

---

## P0 — Actual bugs users can see

- [x] **Time Attack countdown freezes between bites.** *(fixed: self-ticking `_TimeAttackChip`)* `timeAttackSecondsRemaining` is a
  wall-clock getter but the HUD `buildWhen` (`game_screen.dart:999-1013`) doesn't include
  time remaining — HUD only rebuilds on score/level/status/combo changes. Go 4s without
  eating and the clock sticks then jumps; the <10s red pulse is stale too.
  **Fix:** give the time chip its own ticker (like `_PowerUpRing`) or add time to `buildWhen`.

- [x] **"TOURNAMENT SCORE SUBMITTED!" is a lie.** *(fixed: submitScore wired into game over, ribbon reflects real submitting/submitted/failed state; bonus: TimeAttack tournaments now get their end-of-time timer)* `TournamentService.submitScore`
  (`tournament_service.dart:266`) and `TournamentsProvider.submitScore` have **zero call
  sites**. The game-over ribbon (`game_over_screen.dart:427-446`) claims submission that
  never happens. The whole tournament competitive loop is non-functional from the client.
  **Fix:** wire up submitScore on tournament game-over, or hide the ribbon/tournaments.

- [x] **~26 of 100 achievements are unreachable.** *(fixed: local evaluators for general-type + per-mode rows via new gameModeCount stat; difficulty rows removed client+backend; all_mode_player → 8 modes)*
  - `_updateAchievementsFromBackend` is dead code (`achievement_service.dart:313`,
    annotated `// ignore: unused_element`); no local evaluator covers `general`-type.
  - Dead: 5 player-level (`level_5..level_100`), 5 playtime (`quick_player..touch_grass`),
    3 exploration (`mode_explorer`, `all_mode_player`, `difficulty_explorer`),
    6 hard-difficulty (game hardcodes `difficulty: 'normal'` at `game_cubit.dart:1339`;
    **no difficulty selector exists in the game**), 7 per-mode games-count achievements
    (`checkGamePlayedAchievements` skips rows with a `gameModeFilter`).
  - `all_mode_player` targets 6 modes; there are 8 (`achievement.dart:592`).
  **Fix:** add local evaluators for general-type + per-mode counts, drop or rework
  hard-difficulty rows, fix the mode count.

- [x] **Diamond achievements grant 0 XP.** *(fixed client + backend validator, 100 XP)* `BattlePassXpSource.xpAmounts` has
  common/rare/epic/legendary but no `achievement_unlocked_diamond`
  (`battle_pass.dart:628-631`). The buffering keys on
  `'achievement_unlocked_${rarity.name}'` (`game_cubit.dart:1377`).

- [x] **Armed power-up leaks into the next game.** *(fixed: run-id guard)* `_activateArmedPowerUpIfAny` uses an
  uncancellable `Future.delayed(5s)` that only checks `status == playing`
  (`game_cubit.dart:340-373`). End game A and start game B within 5s → A's power-up
  injects into B. **Fix:** key the callback to a run id, or store a cancellable Timer
  cancelled in `startGame`/`_gameOver`.

- [x] **Coin rewards are silent everywhere.** *(fixed: coin_collect aliased to power_up chime)* `playSound('coin_collect')` called in 5 places
  (`game_over_screen.dart:264,298`, `daily_challenges_screen.dart:56,91`,
  `weekly_quests_screen.dart:55`) but no `coin_collect.wav` exists and the system-sound
  fallback switch has no case for it → plays nothing. **Fix:** ship the asset or remap.

- [x] **`high_score` plays as an OS click.** *(fixed: added to preload list)* Asset ships (36 KB) but isn't in
  `AudioService._soundsToPreload` (`audio_service.dart:25-32`), so the SoLoud path falls
  through to `SystemSound.click`. Hits `achievement_reveal_overlay.dart:144` and all
  multiplayer high-score moments. **Fix:** add to preload list.

- [x] **Paid power-up inventory lives in SharedPreferences** *(fixed: Drift singleton + sync outbox + backend mirror + restore-on-sign-in; one-shot prefs migration)* (`power_up_cubit.dart:60`,
  `power_up_inventory_v1`), not Drift — players spend synced cross-device coins on
  device-only inventory that's lost on reinstall. Violates the offline-first doctrine.
  **Fix:** move inventory to Drift + sync outbox.

- [x] **Battle pass label/quantity mismatch** *(fixed: coin labels derive from actual quantity)* — free coin reward names say
  '50/75/100 Coins' (`battle_pass.dart:463`) but `_getQuantityForLevel` grants 50
  (`battle_pass.dart:457`). Also `BattlePassCubit.refresh()` (`:205-207`) only reloads
  local — everyone may grind the hardcoded "Cosmic Serpent" sample season forever.

- [x] **Replays always say "Player".** *(fixed: uses UnifiedUserService.displayName)* `playerName: 'Player'` hardcoded at
  `game_cubit.dart:1402`.

---

## P1 — Game-feel (the biggest fun upgrades)

- [x] **Single-depth input buffer drops legit rapid inputs.** *(fixed: 2-deep queue)* Only one direction change per
  tick; the second is *rejected* with a red flash instead of queued (`snake.dart:95-110`).
  At 150–300ms tick periods, a fast corner (down-then-right) eats the second input.
  **Fix:** 2-deep direction queue. Biggest feel win available.

- [x] **Swipe layer: one turn per drag gesture.** *(fixed: multi-turn drags)* `_hasTriggeredThisGesture`
  (`swipe_detector.dart:165-171`) means the player must lift their finger to turn twice in
  one continuous drag. Diagonal flicks are dropped as "ambiguous" (`:147-148`).
  **Fix:** allow a second turn per drag / buffer 2 turns.

- [x] **D-pad targets ~39px on small screens** *(fixed: 0.38 ratio + 120px small-screen dpad → ~46px)* (`dpad_controls.dart:30`, `buttonSize =
  size * 0.34` with `dpadSize = 115` at `game_screen.dart:776`) — below the 48px Material
  minimum. Misfires on a fast game.

- [x] **D-pad double haptic per press** *(fixed: cubit owns input haptics; swipe path had same bug)* — fires on both `onTapDown`
  (`dpad_controls.dart:141-143`) and the `onPressed` wrapper (`:106-109`).

- [x] **Level-up fires 3 simultaneous animations** *(fixed: consolidated to HUD badge burst + light shake)* (corner popup `game_screen.dart:625-750`
  + HUD badge burst/scale `game_hud.dart:1030-1058` + glow) right when the player needs to
  read the board. Consolidate to one cue.

- [x] **Screen shake transforms the entire Scaffold including the banner ad** *(fixed: scoped to play area)*
  (`game_screen.dart:1047-1051`). Scope shake to the board.

- [x] **Juice loops are hand-rolled `Future.delayed(16ms)` recursion, not vsync Tickers** *(fixed: Ticker-driven shake; scale-punch system deleted — it rendered nothing)*
  (`screen_shake.dart:42-68, 186-207`) — not vsync-aligned, rebuild via setState. The
  scale-punch loop runs on every food eaten even though `applyScale: false`
  (`game_screen.dart:1050`) means nothing renders it. Wasted frames on the hottest event.

- [x] **Mandatory 3s fake pre-game loader on every play** *(fixed: tap-anywhere-to-skip)* (`pre_game_loading_screen.dart:40`,
  doc comment says 4.5s, code says 3s). No skip affordance. **Fix:** "tap to start" skip;
  keep the full wait for first launch only if desired.

- [x] **No distinct wall-hit vs self-collision sound** *(fixed: self-collision plays game_over at 0.85× rate — duller thud, no new asset)* — haptics distinguish them
  (`game_cubit.dart:1012/1016`), audio plays the same `game_over` for both.

- [x] **Theme contrast issues:** *(fixed: Crystal food → saturated magenta quartz, Desert snake → golden sand; `primaryColor == snakeColor` smell remains — larger palette refactor)* Crystal (powder-blue snake vs rose-pink food on amethyst)
  and Desert (sandy-brown snake on terracotta bg) have poor figure/ground separation.
  `primaryColor == snakeColor` for **all 10 themes** (`constants.dart:435-458`) — score
  text is snake-colored, rescued only by a drop shadow. No contrast validation exists.

---

## P2 — Design decisions to revisit

- [x] **The "combo" never breaks.** *(fixed: 6s game-time decay, pause-safe, zen exempt, ComboBrokenEvent haptic)* `currentCombo` increments on eat, is never reset except
  at game start (`snake_simulation.dart:177,185-187`, `game_cubit.dart:224`), survives
  Survival respawns (`game_cubit.dart:981`). No decay timer anywhere. Once you've eaten 20
  foods the 3.0× multiplier (`game_state.dart:132-137`) is permanent for the run. It's a
  food odometer, not a combo. **Decide:** add decay window (risk/reward) or rename it.

- [ ] **Home screen has ~20 tappable destinations** (top nav 5, hero PLAY + loadout,
  stats row 3, PRO/STORE/FREE 2-3, bottom grid 8: DAILY/BATTLE/EVENTS/BOARD/FRIENDS/
  COSMETICS/AWARDS/VERSUS). Store reachable 3 ways. The arcade identity is buried under
  live-service chrome, half of which (tournaments, versus) is broken or stubbed.
  **Fix:** cut/merge destinations; hide broken features.

- [x] **First-launch prompt pile-up.** *(fixed: sequential onboarding queue — walkthrough → daily bonus → notifications, real dismissal signals)* From `home_screen.initState`: daily bonus at +800ms,
  walkthrough at +1200ms, notification init at +1500ms → soft-ask +800ms → primer +2s —
  **racing timers, no sequencing state machine; they can stack**. Then PLAY → mode picker →
  3s loader → control-choice modal → gameplay tutorial. 5+ blocking interactions before
  first input. **Fix:** one onboarding state machine, sequenced by completion.

- [ ] **Game-over screen is a popup gauntlet** — particle explosion, score animation,
  achievement cinematic (+1200ms), level-up dialog (+1400ms, can visually collide with the
  cinematic), unlock toasts, double-coins button, daily rewards card, interstitial on exit.
  5-6 reward surfaces on one screen. **Fix:** cut to ~2, sequence the rest.

- [ ] **Game modes are mostly one-flag knockoffs** (`constants.dart:527-684`).
  speedChallenge vs timeAttack differ ONLY by `speedIncreaseRate` 15 vs 20 (`:640-649`).
  zen = one bool (no walls), multiFood = one bool. Only perfectGame (no-revisit) and
  survival (3 lives) are genuinely different. **Fix:** give shallow modes a unique hook or
  merge them.

- [x] **Player level rewards nothing.** *(fixed: 50 coins/level, 200 every 10th, shown in popup)* `ProgressionService` tracks XP and fires a popup —
  no reward table, no unlocks; the level achievements that would give it meaning are in
  the unreachable pile. **Fix:** attach a reward table (coins/cosmetics per level).

- [ ] **Coin economy is punishing to the point of irrelevance.** Earning: ≤10 coins per
  game (`1 + score/200` capped, `game_cubit.dart:1804`), daily cap 150 free / 250 Pro
  (`coins_state.dart:100`). Prices: Speed Boost 500, Score Multiplier 750, Invincibility
  1000 (single-use, `store_screen.dart:2614-2635`), revive 1500 (`game_cubit.dart:191`).
  That's 7-10 days of maxed grind for one consumable. If it's a deliberate ad/Pro funnel,
  fine — but rebalance or stop surfacing items free players can never afford.

- [ ] **Daily challenges / weekly quests hard-require auth** — no client-side generation
  fallback (`daily_challenge_service.dart:81`, `weekly_quest_service.dart:83`). Guest and
  offline users see empty screens in an offline-first app. Challenge variety is also
  narrow: 5 types, all "hit N of metric X" — no creative constraints (no-walls run,
  combo ≥ X, perfect game).

- [x] **Anti-cheat is absent.** *(first pass done: tournament submissions were already validated; added 1M plausibility ceilings on synced high score + coin balance. Finer per-day reconciliation / replay validation = future work)* High score and coins are client-authoritative, pushed via
  last-write-wins settings sync (`sync_engine.dart:960,1102-1139`); daily coin cap is
  client-side. Global leaderboard is trivially spoofable by a modified client.
  **Fix (server-side):** sanity bounds (score vs game duration, coins vs games played),
  eventually replay-based or re-simulation validation.

- [ ] **Timing is wall-clock (`DateTime.now()`) everywhere** — power-up expiry, food
  expiry, TimeAttack, gameSpeed. Pause/resume compensates by re-stamping every live object
  and shifting `activatedAt`/`createdAt`/`gameStartTime` (`game_cubit.dart:404-448,
  462-536`), plus two separate start-time anchors that must shift in lockstep
  (`game_cubit.dart:80` vs `game_state.dart:70`). Any new time-based field silently breaks
  unless added to both loops. **Fix (larger refactor):** accumulated game-clock / tick
  counter — eliminates the whole class of bug.

- [ ] **Latent trap: premium power-ups default-map to speedBoost.**
  `PremiumActivePowerUp._mapToBasicType` returns `speedBoost` as `default` for ghostMode,
  teleport, timeWarp, etc. (`premium_power_up.dart:400-412`) — if ever instantiated
  in-game, all of them would trigger 2× speed as a side effect. Currently unreachable.
  **Fix:** wire premium effects properly or delete the premium-active machinery.

---

## P3 — Dead weight to delete

- [x] **Entire multiplayer stack is a dead stub.** *(REBUILT server-authoritative, July 2026: in-memory MatchEngine on the backend runs the simulation (clients send only direction inputs), 1v1 classic with matchmaking + friend room codes, winner gets 25 server-declared coins + BP XP, VERSUS restored. Needs a live 2-device test against a deployed backend.)* `MultiplayerService` returns
  null/false/no-op for everything (`multiplayer_service.dart:39-143`); unreachable:
  `multiplayer_game_screen.dart`, `multiplayer_flame_game.dart`,
  `multiplayer_flame_board.dart`, `multiplayer_board_painter.dart`,
  `multiplayer_cubit.dart`, `models/multiplayer_game.dart`. The stubbed design is also
  fully client-authoritative (client computes own collisions, self-awards score,
  `multiplayer_game_screen.dart:147-219`) — redesign server-authoritative if ever revived.
  **Decide: delete or feature-flag.**

- [x] **Dead animation plumbing in `GameCubit`:** *(fixed: all removed, incl. moveProgress)* `_animationTimer` (`game_cubit.dart:65`)
  cancelled in 6 places, never assigned; `_startSmoothAnimation()` (`:649-654`) is a no-op
  called 3×; `moveProgress` only ever set to 0.0. Remove all three.

- [x] **~Half of `HapticService` (355 lines) is uncalled:** *(fixed: pruned to called API only)* `customHaptic` +
  `HapticIntensity`, `snakeMove`, `bonusFoodEaten`, `specialFoodEaten`,
  `achievementUnlocked`, `buttonPress`, `menuNavigation`, `pauseToggle`, `chainEffect`,
  `crescendo`, `pulse`, 5 theme effects (cyberpunk/ocean/crystal/forest/desert),
  `testHaptics`, `isAvailable` (hardcoded `true`). Prune or wire up.

- [x] **Dead swipe-feedback path still costs rebuilds.** *(fixed: deleted)* `SwipeDetector` full animated
  feedback (`swipe_detector.dart:200-255`) is dead (`showFeedback: false` at the only call
  site) yet `_processSwipe` still `setState`s the board-wrapping widget on every accepted
  swipe (`:82-86`) to update variables nothing renders. Also duplicates the direction
  color map in `game_screen.dart:1437-1448`.

- [x] **Two SFX engines for the same sounds.** *(fixed: EnhancedAudioService deleted, all SFX through SoLoud with per-call volume)* `AudioService` (SoLoud, preloaded) +
  `EnhancedAudioService` (audioplayers pool, preloads NOTHING — decodes from bundle every
  play, `enhanced_audio_service.dart:74`). Same `level_up.wav` routed through both engines
  in different `game_cubit` branches; comments at `game_cubit` 312/952/1047/1615 document
  past double-play bugs from this. `EnhancedAudioService.dispose()` is never called.
  **Fix:** collapse to SoLoud only; delete `EnhancedAudioService` + DI wiring.

- [x] **~3.4 MB of dead images shipped to every user** *(fixed: moved to marketing/; OFL txts now registered in LicenseRegistry)* (`assets/images/` is globbed
  wholesale, pubspec:146): `new_snake_classic.png` (1.94 MB, unused),
  `snake_classic_with_bg.png` (928 KB, unused), `feature_graphic.png` (346 KB) and
  `play_store_icon.png` (218 KB) — Play Store LISTING assets inside the app bundle.
  Also two OFL license .txt files bundled as assets.

- [x] **`game_start.wav` is 624 KB uncompressed** *(fixed: 22.05kHz mono, 153KB — verify on device)* — second-largest audio file, for a
  one-shot sting. Trim/re-encode. (`background_music.mp3` at 3.28 MB dominates but is
  already compressed.)

- [x] **`removeExpiredPowerUps()`** *(removed; `_isPremium*` helpers kept — they ARE referenced by the hasX getters)* (`game_state.dart:361-366`) superseded by the inline
  filter in `snake_simulation.dart:240-241`; `_isPremium*` OR-branches
  (`game_state.dart:264-278`) are dead.

- [x] **Misc:** *(all fixed)* dead `battle_pass_cosmic_banner.png` reference (`battle_pass.dart:424`,
  file doesn't exist); stale "legacy board" comments (`legacy_board_component.dart:7-15`,
  `flame_game_board.dart:166-170`) describing an already-deleted `game_board.dart`;
  `debugLogDiagnostics: true` left on (`app_router.dart:91`).

---

## P4 — Smaller code-quality notes

- [ ] `changeDirection` mutates the live `GameState`'s snake in place then re-emits the
  same object (`game_cubit.dart:566, 572-575`) — works, but breaks state-immutability
  assumptions for anything that captured the previous state.
- [ ] PerfectGame copies the entire visited-cell set every tick
  (`snake_simulation.dart:253-257`) — O(n) copy with unbounded n on long runs; pass by
  reference or diff incrementally.
- [ ] `Random()` re-allocated per call in hot paths (`snake_simulation.dart:338`,
  `food.dart:38,69`, `power_up.dart:116,146`) — share one instance. Note: no seed
  injection anywhere, so the simulation is not deterministically replayable (replays are
  fat per-frame snapshots, not input+seed).
- [ ] Replay frames store the full snake body every tick (`game_replay.dart:221-256`) —
  hundreds of KB per blob; consider delta-encoding (only the head moves). Retention is
  bounded (~20 rows) so not urgent.
- [ ] Responsive system (`responsive.dart`) is bypassed by the two heaviest screens —
  `home_screen.dart` uses hand-rolled `screenHeight < 650/750` breakpoints and manual
  width caps; `game_screen.dart` mixes `uiScale` with raw `screenHeight < 700` checks.
  Fixed-position overlays (level-up popup `top:120,right:16`; crash overlay 80px emoji /
  40px margin) don't scale for tablets.
- [ ] Home screen ignores the design system — `GameButton`/`GradientButton` exist but the
  home screen is entirely bespoke `GestureDetector`+`Container` buttons with inconsistent
  press feedback; `GradientButton` also duplicates `GameButton`'s scale/glow/haptic logic.
- [ ] Music doesn't auto-resume on app `resumed` (only via manual resume path) —
  acceptable by design, just noting.
- [ ] 5 Rajdhani weights ship at ~215 KB each (~1.08 MB) — verify all weights are used.

---

## Suggested order of attack

1. **This week (visible bugs):** Time Attack timer, tournament ribbon (wire or hide),
   `high_score` preload, `coin_collect` sound, armed power-up leak, inventory → Drift.
2. **Feel pass:** 2-deep input queue (tick + swipe), d-pad size + haptic de-dupe,
   pre-game loader skip, consolidate level-up animation, scope shake to board,
   Ticker-based juice loops.
3. **Honesty pass:** fix/cull 26 dead achievements, diamond XP, player-level rewards,
   combo decay-or-rename, delete multiplayer stub + dead code.
4. **Ship-weight pass:** remove dead images (~3.4 MB), re-encode `game_start.wav`,
   collapse to one audio engine.
5. **Longer-term:** server-side score sanity checks, onboarding state machine,
   differentiate or merge speedChallenge/timeAttack, tick-based game clock.

## Open questions (decide before fixing)

1. **Tournaments** — wire up submitScore, or hide tournaments until the loop works?
2. **Difficulty** — was a selector planned? If not, kill the 6 hard-difficulty achievements.
3. **Combo** — intentional permanent multiplier, or missing decay? (Decides rename vs timer.)
4. **Multiplayer** — someday-placeholder or abandoned? (Decides flag vs delete.)
5. **Pre-game 3s loader** — pure warmup as claimed? Then it can be skippable today.

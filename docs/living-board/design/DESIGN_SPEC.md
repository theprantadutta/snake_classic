# Snake Classic: Living Board design spec

Direction **2a "Living board"** + logo **3a "Cell S"**. The reference renders are in `../screens/` (1080×2340, 3× of a 360×780 design frame).

## 1. Principles
1. **The app is one grid.** Every screen sits on a 20 dp grid (`LB.cell`). Blocks, buttons, rows and HUD snap to whole cells and are inset by 1 dp, so two neighbours always show the same 2 dp gap as snake segments.
2. **Numbers and titles are drawn in snake cells.** Screen titles, scores, tier numbers and countdowns use the 3×5 cell font (`cell_font_3x5.json`). Everything else is JetBrains Mono.
3. **One loud thing per screen.** Each screen gets one lime-filled block (PLAY, AGAIN, RESUME, FIND MATCH, READY, GO PRO). Everything else is an outline block.
4. **Gold means reward, red means danger, lime means go.** These meanings hold across all 10 themes.
5. **Plain first, funny second.** See `COPY.md`.

## 2. Grid and layout (phone, 360×780 dp reference)
- 18 columns × 39 rows of 20 dp. Content uses columns 1–16 (20 dp side margins). The board in gameplay uses all 18.
- Status bar: rows 0–2. Header: rows 3–4 (back block 2×2 at col 1, cell-font title at x=70 dp with cell 6 dp). Subtitle at y=112. Content starts at row 7 (y=140).
- Bottom: adaptive banner (free players), with a 12 dp gap in gameplay and 20 dp on game over. Home indicator safe area below.
- **Tablets:** keep `lib/utils/responsive.dart`. Scale `LB.cell` by `context.uiScale` and center the 18-column grid with `context.sideInset()`. Text is not scaled by hand. Phones must stay a no-op.

## 3. Components (build these once, in `lib/widgets/lb/`)
| Component | Spec |
|---|---|
| `LBGridBackground` | `#08160B` + 1 dp lines every 20 dp at `gridLine`. CustomPainter, cached in a `RepaintBoundary`. |
| `LBBlock` | Rect snapped to cells, inset 1 dp, radius 6. Kinds: `outline` (fill 6% lime, inner stroke 32% lime), `fill` (lime + 13% dark grid lines + 30 dp lime glow, dark text), `gold`, `goldFill`, `danger`, `muted`, `dashed`, `sheet` (`#0C1F0F` + stroke + shadow). Press: scale 0.97 for 90 ms + haptic light. |
| `LBCellText` | Paints a string with the cell font. Props: `cell` (dp), `color`, `glow`. Gap 12% of cell, radius 22%. Used for titles (cell 6), hero numbers (cell 20), PLAY/AGAIN (cell 7). |
| `LBPixelIcon` | 5×5 icon from `pixel_icons_5x5.json`. Cell 3 dp inline, 4–6 dp in buttons. Replaces Material icons app-wide. |
| `LBCellsBar` | Progress drawn as a row of N cells (lit = color, off = `cellOff`). Used for level, XP, loading, countdowns, the momentum bar and sliders. |
| `LBToggle` | 2 cells: off = `[lit grey][off]`, on = `[off][lit lime]`. |
| `LBChip` | 22 dp tall, radius 5. Gold or outline kind. |
| `LBHeader` | Back block + cell title + optional right action + subtitle. |
| `LBBannerSlot` | Wraps the existing adaptive banner widget. Reserves 50 dp, renders nothing for Pro users. |

## 4. Screens → existing routes
| # | Screen | Route / file to rework |
|---|---|---|
| 01 | Splash | `loading_screen.dart` (`/`) |
| 02 | Home | `home_screen.dart`: the snake idles on a loop around PLAY. A swipe steers it into blocks, and a tap also works. Remove the duplicated coins/Versus entries. |
| 03 | Run setup | New sheet or route opened from PLAY long-press / mode row: mode, board size, difficulty and loadout (replaces the loadout dropdown and the Settings mode picker; Settings keeps a shortcut row) |
| 04–05 | Gameplay | `game_screen.dart` + `lib/game/flame/`. Ghost score digits under the board, the level-progress cell row as the top wall, combo chip, and power-up chip. Turn buttons / d-pad / joystick keep their current logic. |
| 06 | Pause | Pause overlay in `game_screen.dart` |
| 07 | Crash → revive | Existing crash-feedback + revive flow (rewarded / 50 coins / Pro free). Keep `TapArmGuard`. |
| 08 | Game over | `game_over_screen.dart`. The "uncoiled" chart comes from the run's per-food points (see §7). |
| 09 | Daily | `daily_challenges_screen.dart` (+ weekly teaser → `weekly_quests_screen.dart`) |
| 10 | Trophies | `achievements_screen.dart` (rarity stripe, 5 rarities incl. diamond) |
| 11 | Season | `battle_pass_screen.dart` |
| 12 | Ranks | `leaderboard_screen.dart` + `friends_leaderboard_screen.dart` (FRIENDS tab) |
| 13 | Profile | `profile_screen.dart` (+ links to statistics, replays, friends, achievements) |
| 14–15 | Store | `store_screen.dart`: same 6 tabs in the same order, same product IDs |
| 16 | Settings | `settings_screen.dart` |
| 17–20 | Versus | `multiplayer_lobby_screen.dart`, `multiplayer_game_screen.dart` |
| 21 | Ad break | `lib/widgets/ads/rewarded_interstitial_intro.dart`: restyle only, same behavior |
Not drawn but must follow the system: first-time auth, email auth, username setup, privacy consent, premium benefits, cosmetics, statistics, replays + viewer, tournaments + detail, friends, instructions, legal, route error. Use the same header, blocks and copy rules.

## 5. Gameplay rendering (Flame)
- Snake cell = rounded square `cell − 2`, radius 3 (head radius 5). Body opacity ramps from 100% at the head to 45% at the tail. Head is `head` color with a 12 dp glow and two eyes offset toward the direction of travel.
- Food: apple sprite kept; add a 10 dp gold glow. Bonus and special food keep their sprites and get a `gold` glow.
- Skins and trails: keep every existing skin/trail renderer. The Living Board only changes the board background, grid and HUD around them.
- Invincibility tints the body gold (`#F5C518`, head `#FFE27A`). Walls within `wallWarningThreshold` cells get a red edge gradient (exists as safe-zone warning; restyle it).
- Score ghost digits: cell font at 20 dp per cell, 12% lime, behind the snake. They update on eat with a 220 ms cell-by-cell reveal.

## 6. Motion and haptics
| Moment | Motion | Haptic | Sound (`../sounds/sfx`) |
|---|---|---|---|
| Eat | head flashes 80 ms, ghost digit cells re-light | selection | `eat` / `eat_bonus` / `eat_special` |
| Turn | none | none (or light, if the setting is on) | `turn` (very quiet, optional) |
| Combo up / break | chip pops 1.08× / shakes 2 dp | light / none | `combo_up` / `combo_break` |
| Level up | top cell row sweeps left→right | medium | `level_up` |
| Power-up on / off | snake tint crossfade 150 ms | medium / none | `power_up` / `power_down` |
| Crash | board shakes 4 dp × 3, head turns red with × | heavy | `crash_wall` / `crash_self` |
| Revive | cells re-light from the tail up | medium | `revive` |
| Game over | uncoil chart columns grow left→right, 40 ms stagger | none | `game_over` (or `new_best`) |
| Coin / claim | coin icon bounces, count ticks up | light | `coin` / `claim` / `ad_reward` |
| UI tap / back | block scale 0.97 | light | `ui_tap` / `ui_back` |
| Countdown | big cell digit swaps | light per tick | `countdown_tick` / `countdown_go` |
| Versus | `match_found`, `victory`, `defeat` | medium | as named |
| Music | `menu_loop_118bpm` on menus, `run_loop_140bpm` in runs (both loop seamlessly) | none | none |

## 7. Data the new UI reads
| UI | Source | Notes |
|---|---|---|
| Uncoiled chart | Per-food points during the run (`GameState` / replay frames) | Local only. Replays never leave the phone (CLAUDE.md). Store `List<int> foodPoints` on the run result. |
| Crash reason line | Existing crash feedback / `end_reason` | wall, self, timeout, perfect-game revisit, quit |
| Global rank on Home and Ranks | Leaderboard API | Needs the player's own rank. Add `GET /api/v1/leaderboard/me` only if the current endpoint doesn't return it. |
| Daily streak | Daily bonus / challenge claim history | Add a `currentStreak` field only if it's missing. Derive it client-side from Drift if possible. |
| Run number | `GameStatistics.totalGamesPlayed` | Local |
| Fun facts | Local statistics | Local |
| Season days left | Battle pass season end | Existing |
| Friends online count | Friends provider | Existing |

## 8. Ads: unchanged behavior, new skin
Banner, interstitial, rewarded, rewarded interstitial (with intro) and app-open keep their unit IDs, cadence, gaps, caps, `TapArmGuard`, `AdBreakCurtain`, `showRewardedOrWait` and Pro suppression exactly as in `admob_ad_list.md`. The redesign only restyles the surfaces around them.

## 9. Store: unchanged catalog
Six tabs in order: Pro · Coins · Themes · Skins · Trails · Power-Ups. Product IDs (`com.pranta.snakeclassic.*`): `pro_monthly`, `pro_yearly`, `coin_pack_small|medium|large|mega`, 6 themes + `premium_themes_bundle`, 11 `skin_*`, 11 `trail_*`, `tournament_silver`, `tournament_gold`. Coin-priced power-up bundles: `mega_pack`, `tactical_pack`, `ultimate_pack`. Prices always come from the store. The prices in the mocks are placeholders.

## 10. Assets in this kit
- `logo/`: iOS 1024 icon (no alpha, full bleed), Play 512, rounded preview, adaptive foreground + monochrome (1024, 66% safe zone), notification glyph (white), web favicons, Android 12 splash logo (content radius well under width/3), dark splash, wordmarks, Play feature graphic 1024×500.
- `fonts/`: JetBrains Mono 400–800 (OFL, licence included).
- `sounds/`: 24 SFX + 2 music loops, 16-bit PCM WAV. These are synthesized placeholders in the right style; replace them with final mixes later if you want.
- `design/`: `palette.json`, `lb_tokens.dart`, `cell_font_3x5.json`, `pixel_icons_5x5.json`, `COPY.md`, this spec.

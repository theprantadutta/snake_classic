# Claude Code prompt: Snake Classic "Living Board" redesign

> Paste everything below into Claude Code from a workspace that has both repos checked out side by side:
> `snake_classic/` (Flutter) and `snake-classic-backend/` (.NET).
> Unzip this kit first and put it at `snake_classic/design_kit/` (or tell Claude where it is).

---

You are implementing a full visual redesign of **Snake Classic**, a live Flutter + Flame game with real revenue (AdMob + IAP). The design is final and lives in `design_kit/`. Read all of it before you write any code:

- `design_kit/screens/*.png`: 21 reference screens (1080×2340, 3× of a 360×780 dp frame). These are the source of truth for layout and copy.
- `design_kit/design/DESIGN_SPEC.md`: grid, components, the screen → route map, motion/haptics/sound table, data needs, and the ad and store rules.
- `design_kit/design/COPY.md`: every string, the voice rules, and suggested ARB keys.
- `design_kit/design/lb_tokens.dart`, `palette.json`, `cell_font_3x5.json`, `pixel_icons_5x5.json`
- `design_kit/logo/`, `design_kit/fonts/`, `design_kit/sounds/`, `design_kit/brand/`

Also read `snake_classic/CLAUDE.md`, `ARCHITECTURE.md`, `admob_ad_list.md`, `STORE_SETUP.md` and the backend `README.md` before you change anything. Their rules are load-bearing and override any assumption you make.

## 0. Ask me first

**Before writing any code, ask me every question you have, in one batch, and wait for my answers.** Also ask again any time you hit something ambiguous during the work. Do not guess on anything involving money, ads, store products, accounts or data migrations. At minimum, confirm these:
1. Which backend repo is live: `snake-classic-backend` or `snake_classic_backend`? (I believe `snake-classic-backend`.)
2. Branch name. Proposal: `redesign/living-board` in both repos, cut from each repo's default branch.
3. Translations: should the new English strings be machine-translated into the 8 other ARB locales now, or added as English placeholders for me to send out?
4. Should the old themes' visuals (the decoration layers in `AppBackground`) stay as they are, or be re-skinned onto the Living Board grid using `LBThemeTokens`?
5. The open issues listed at the top of `CLAUDE.md` (inert premium power-ups that are still sold, the Pro screen listing free boards, the Android guest note mentioning Apple). The redesign's Pro screen already avoids promising them. Do you also want the underlying code, ARB strings and backend catalog fixed in this branch?
6. Run setup (screen 03): should it be a new route, or a bottom sheet opened from Home?
7. Is it OK to replace Orbitron/Rajdhani with JetBrains Mono app-wide, keeping Noto as the fallback for Arabic, Devanagari and Cyrillic?

## 1. Non-negotiables

- **Ads stay exactly as they are.** Same ad unit IDs, App IDs, formats, placements, cadence, caps, gaps (`_fullScreenAdMinGap`, interstitial every 2nd game over with the first exempt), the rewarded-interstitial intro (5 s countdown, equally prominent NO THANKS, back = skip, 25 coins), `TapArmGuard`, `AdBreakCurtain`, `showRewardedOrWait` (never gate on `isRewardedReady`), banner gap rules (12 dp in gameplay and only for swipe players, hidden with on-screen controls; 20 dp on game over), App Open rules, UMP/ATT consent, and Pro = no ads. You are only restyling the surfaces around ads. If a layout change would move a banner nearer a control than today, stop and ask.
- **Store products stay exactly as they are.** Do not add, rename, remove or re-price any product, and nothing may require a Play Console or App Store Connect change. Same 6 tabs in the same order (Pro · Coins · Themes · Skins · Trails · Power-Ups) and the same IDs (`pro_monthly`, `pro_yearly`, `coin_pack_*`, the 6 themes + `premium_themes_bundle`, 11 `skin_*`, 11 `trail_*`, `tournament_silver`, `tournament_gold`, coin bundles `mega_pack`/`tactical_pack`/`ultimate_pack`). Prices always come from the store SDK; the prices in the mocks are placeholders. Restore purchases must stay reachable.
- **All 10 themes, 8 modes, all board sizes (all free), 4 control layouts, skins, trails, power-ups, battle pass, tournaments, daily challenges, weekly quests, achievements, replays, friends and multiplayer keep working.** This is a reskin and a UX consolidation, not a feature cut.
- **Offline-first sync rules in CLAUDE.md apply to any new state.** Drift is the single source of truth, the outbox row is written in the same transaction, and SyncEngine is the only pusher. Replays never go to the backend.
- **Tablet/iPad:** use `lib/utils/responsive.dart`. Phone layouts must be a no-op.
- **Honest Pro copy:** never list board sizes as a Pro perk, and never promise premium power-ups that don't work.
- **Icons/splash regeneration caveats in CLAUDE.md** (restore `windowDrawsSystemBarBackgrounds=true`, revert generator churn, splash `#0F380F`, Android 12 circle radius ≤ width/3, composite "transparent" art over magenta to check for fringing).

## 2. Flutter work, in order (one commit per step, `flutter analyze` clean after each)

1. **Branch + assets.** Create the branch. Copy `design_kit/fonts/*.ttf` → `assets/fonts/` and register the `JetBrainsMono` family in `pubspec.yaml`. Copy `design_kit/sounds/` → `assets/audio/lb/`, `design_kit/logo/*` → `assets/brand/`, and the JSON files → `assets/design/`.
2. **Design system.** Add `lib/design/lb_tokens.dart` (from the kit) and the components in DESIGN_SPEC §3 under `lib/widgets/lb/`: `LBGridBackground`, `LBBlock`, `LBCellText` (CustomPainter using `cell_font_3x5.json`), `LBPixelIcon`, `LBCellsBar`, `LBToggle`, `LBChip`, `LBHeader`, `LBBannerSlot` (wraps the existing banner widget). Make the cell font and icons `const`-friendly and cached. Add a hidden debug route that shows every component.
3. **Logo, icons, splash.** Point `flutter_launcher_icons.yaml` and `flutter_native_splash.yaml` at the new files: `app-icon-ios-1024.png` (iOS, no alpha), `app-icon-play-512.png`, `adaptive-foreground-1024.png` + background `#0F380F`, `adaptive-monochrome-1024.png`, `splash-logo-android12-1152.png`, and `notification-glyph-96.png` → `drawable/ic_notification`. Replace in-app uses of `snake_classic_logo.png` / `snake_classic_transparent.png` with the Cell S mark or wordmark. Update `web/` icons and the manifest. Follow every CLAUDE.md caveat.
4. **Screens, in the order of DESIGN_SPEC §4:** Splash → Home → Run setup → Gameplay HUD → Pause → Crash/Revive → Game over → Daily → Trophies → Season → Ranks → Profile → Store (all 6 tabs; Coins, Themes, Trails and Power-Ups follow the Skins pattern) → Settings → Versus lobby/room/match/result → Ad-break intro. Then bring every other screen (auth, consent, username, premium benefits, cosmetics, statistics, replays, tournaments, friends, instructions, legal, route error) into the system. Match the PNGs. Where a PNG conflicts with real data or behavior, follow the real behavior and tell me.
5. **Home interaction.** The snake idles on a loop around the PLAY block. A swipe steers it, and steering into a block opens that destination. A tap on any block works too (accessibility comes first). The mode row cycles through the 8 modes.
6. **Gameplay (Flame).** Ghost score digits behind the board, the level row as the top wall, the combo chip with the decay warning, power-up chips, the gold invincibility tint, the red wall-proximity edge, and the crash shake. Keep all existing skins and trails rendering. Hold 60 fps (120 Hz where enabled). Profile with DevTools and report frame times.
7. **Game over "uncoiled" chart.** Record per-food points during the run (local only) and render the columns. The crash headline comes from the end reason (COPY.md).
8. **Audio.** Map the events in DESIGN_SPEC §6 to the new WAVs through the existing `AudioService` (flutter_soloud). Keep the existing volume and mute settings. Music loops are optional and honor the Music toggle.
9. **Copy + l10n.** Add every COPY.md string to `app_en.arb` with the `lb*` keys, and to the other 8 ARBs according to my answer to question 3. Run `flutter gen-l10n`. No hard-coded user-facing strings.
10. **Clean up.** Remove dead widgets left behind by the old HUD and corner-bracket style only after their replacements ship. List anything you deleted.

## 3. Backend work (`snake-classic-backend`, .NET 10, Clean Architecture)

Add endpoints **only if** the new UI needs data the API doesn't already expose. First audit `LeaderboardController`, `DailyBonusController`, `DailyChallengesController`, `BattlePassController`, `UsersController` and `MultiplayerController`, then tell me what's missing before building anything. Likely candidates:
- `GET /api/v1/leaderboard/me?period=global|weekly`: the caller's rank, score and gap to #1 (Home and Ranks pinned row).
- A `currentStreak` field on the daily bonus/challenge response, if a streak isn't already derivable client-side from Drift claim history.

Rules: follow the existing command/query handler patterns, versioned routes, auth and DTO conventions. Add EF Core migrations if the schema changes. Never touch `ProductCatalog` product IDs, never store replays, and keep the client-mirror sync semantics described in CLAUDE.md. Deploy order: backend first, and the client must degrade gracefully if the endpoint is missing (old backend + new app must still work). Update the backend README and any Postman/HTTP files.

## 4. Done means

- Both branches pushed with clear commits. A PR description for each lists every screen changed, every new file, any backend endpoint (with request/response examples), and anything you couldn't match from the PNGs and why.
- `flutter analyze` clean, `flutter build appbundle` succeeds, `dotnet build` + existing tests pass.
- Ask me before running on a device or emulator. Android is preferred for testing.
- A short manual QA checklist covering: every ad surface still fires as before (debug test IDs), every store tab purchase path, restore purchases, Pro on/off, offline play + later sync, tablet layout, and all 10 themes on Home and Gameplay.
- Screenshots of the implemented screens next to the matching kit PNGs.

If anything in this prompt conflicts with the codebase or with CLAUDE.md, stop and ask me.

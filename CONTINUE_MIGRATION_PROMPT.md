# Prompt to Continue Migration Tomorrow

Copy and paste everything below the line into Claude Code:

---

Continue the Provider to Cubit migration for this Flutter Snake game project. Read `MIGRATION_STATUS.md` for full context.

## Current Status
- **127 errors remaining** from `flutter analyze`
- **10 screens completed**, **12 files remaining**
- Provider files already deleted, but remaining screens still reference them

## Completed Files
- loading_screen.dart ✓
- cosmetics_screen.dart ✓
- tournament_detail_screen.dart ✓
- multiplayer_lobby_screen.dart ✓
- multiplayer_game_screen.dart ✓
- game_screen.dart ✓
- achievements_screen.dart ✓
- battle_pass_screen.dart ✓
- game_over_screen.dart ✓
- home_screen.dart ✓
- main.dart ✓

## Files to Migrate (in suggested order)

### Simple (ThemeProvider only):
1. `lib/screens/replays_screen.dart`
2. `lib/screens/replay_viewer_screen.dart`
3. `lib/screens/tournaments_screen.dart`

### Medium (2-3 providers):
4. `lib/screens/first_time_auth_screen.dart` - ThemeProvider, UserProvider → ThemeCubit, AuthCubit
5. `lib/screens/leaderboard_screen.dart` - ThemeProvider, UserProvider → ThemeCubit, AuthCubit
6. `lib/screens/theme_selector_screen.dart` - ThemeProvider, PremiumProvider → ThemeCubit, PremiumCubit
7. `lib/screens/premium_benefits_screen.dart` - PremiumProvider, ThemeProvider → PremiumCubit, ThemeCubit
8. `lib/screens/profile_screen.dart` - UserProvider, ThemeProvider → AuthCubit, ThemeCubit

### Complex (3+ providers):
9. `lib/screens/store_screen.dart` - PremiumProvider, ThemeProvider, CoinsProvider
10. `lib/screens/settings_screen.dart` - ThemeProvider, GameProvider, UserProvider, PremiumProvider (use GameSettingsCubit for settings)

### Widget & Service:
11. `lib/widgets/game_board.dart` - ThemeProvider, PremiumProvider, GameProvider
12. `lib/services/purchase_service.dart` - UserProvider (just needs userId)

## Key Migration Patterns

```dart
// Consumer → BlocBuilder
Consumer<ThemeProvider>(builder: (ctx, provider, _) => ...)
// becomes
BlocBuilder<ThemeCubit, ThemeState>(builder: (ctx, state) => ...)

// Consumer2 → Nested BlocBuilders
Consumer2<A, B>(builder: (ctx, a, b, _) => ...)
// becomes
BlocBuilder<ACubit, AState>(builder: (ctx, aState) {
  return BlocBuilder<BCubit, BState>(builder: (ctx, bState) => ...);
})

// context.read
context.read<GameProvider>().startGame()
// becomes
context.read<GameCubit>().startGame()
```

## Cubit Mappings
- ThemeProvider → ThemeCubit/ThemeState (currentTheme)
- GameProvider → GameCubit/GameCubitState (gameState, check for null)
- UserProvider → AuthCubit/AuthState (userId)
- PremiumProvider → PremiumCubit/PremiumState (hasPremium, ownedSkins)
- CoinsProvider → CoinsCubit/CoinsState (balance, canAfford)
- Game settings (dPadEnabled, etc.) → GameSettingsCubit/GameSettingsState

## Instructions
1. Start with the simple files (replays_screen, replay_viewer_screen, tournaments_screen)
2. Run `flutter analyze` after each file to verify
3. Continue through medium and complex files
4. End with game_board.dart and purchase_service.dart
5. Final `flutter analyze` should show 0 errors
6. Then we can remove `provider` from pubspec.yaml

Start migrating now, beginning with `lib/screens/replays_screen.dart`.

# Provider to Cubit Migration - Status Report

**Date:** 2025-12-20
**Goal:** Complete removal of Provider package, migrate all screens/widgets to use Cubit-only state management

---

## Migration Patterns Used

### Consumer → BlocBuilder
```dart
// OLD
Consumer<ThemeProvider>(
  builder: (context, themeProvider, child) {
    final theme = themeProvider.currentTheme;
    return ...;
  },
)

// NEW
BlocBuilder<ThemeCubit, ThemeState>(
  builder: (context, themeState) {
    final theme = themeState.currentTheme;
    return ...;
  },
)
```

### Consumer2/Consumer3 → Nested BlocBuilders
```dart
// OLD
Consumer2<GameProvider, ThemeProvider>(builder: (context, game, theme, child) => ...)

// NEW
BlocBuilder<ThemeCubit, ThemeState>(
  builder: (context, themeState) {
    return BlocBuilder<GameCubit, GameCubitState>(
      builder: (context, gameState) {
        return ...;
      },
    );
  },
)
```

### context.read → Same but with Cubit
```dart
// OLD
context.read<GameProvider>().startGame();

// NEW
context.read<GameCubit>().startGame();
```

### Provider.of → context.read
```dart
// OLD
Provider.of<ThemeProvider>(context, listen: false)

// NEW
context.read<ThemeCubit>().state
```

---

## Cubit Mapping Reference

| Old Provider | New Cubit | State Class |
|--------------|-----------|-------------|
| ThemeProvider | ThemeCubit | ThemeState |
| GameProvider | GameCubit | GameCubitState |
| UserProvider | AuthCubit | AuthState |
| PremiumProvider | PremiumCubit | PremiumState |
| CoinsProvider | CoinsCubit | CoinsState |
| MultiplayerProvider | MultiplayerCubit | MultiplayerState |
| (Battle Pass features) | BattlePassCubit | BattlePassState |

---

## State Property Access

### ThemeState
- `themeState.currentTheme` → GameTheme object

### GameCubitState
- `gameCubitState.gameState` → GameState? (can be null, check before use)
- `gameCubitState.status` → GamePlayStatus enum
- `gameCubitState.isPlaying`, `isPaused`, `isGameOver`, `isCrashed`
- `gameCubitState.isTournamentMode`, `tournamentId`, `tournamentMode`

### AuthState
- `authState.userId` → String?
- `authState.user` → User object

### PremiumState
- `premiumState.hasPremium` → bool
- `premiumState.ownedSkins` → Set<String>
- `premiumState.isSkinOwned(skinId)` → bool

### BattlePassState
- `battlePassState.isActive` → bool (replaces hasBattlePass)
- `battlePassState.currentTier` → int (replaces battlePassTier)
- `battlePassState.currentXP` → int (replaces battlePassXP)
- `battlePassState.isFreeTierClaimed(tier)`, `isPremiumTierClaimed(tier)`

### CoinsCubit
- `coinsState.balance` → int
- `coinsState.canAfford(amount)` → bool

---

## Completed Migrations

### Screens (10 completed)
1. **lib/screens/loading_screen.dart** ✓
2. **lib/screens/cosmetics_screen.dart** ✓
3. **lib/screens/tournament_detail_screen.dart** ✓
4. **lib/screens/multiplayer_lobby_screen.dart** ✓
5. **lib/screens/multiplayer_game_screen.dart** ✓
6. **lib/screens/game_screen.dart** ✓
7. **lib/screens/achievements_screen.dart** ✓
8. **lib/screens/battle_pass_screen.dart** ✓
9. **lib/screens/game_over_screen.dart** ✓
10. **lib/screens/home_screen.dart** ✓ (done in earlier session)

### Core Files
- **lib/main.dart** ✓ - Updated to use MultiBlocProvider with all cubits, kept MultiProvider only for services (UnifiedUserService, DataSyncService, PreferencesService)

### Provider Files Deleted
- lib/providers/coins_provider.dart ✓
- lib/providers/game_provider.dart ✓
- lib/providers/multiplayer_provider.dart ✓
- lib/providers/premium_provider.dart ✓
- lib/providers/theme_provider.dart ✓
- lib/providers/user_provider.dart ✓

---

## Remaining Files to Migrate (127 errors)

### Screens (10 remaining)
1. **lib/screens/first_time_auth_screen.dart**
   - Uses: ThemeProvider, UserProvider
   - Pattern: Consumer2

2. **lib/screens/leaderboard_screen.dart**
   - Uses: ThemeProvider, UserProvider
   - Pattern: Consumer2, Provider.of

3. **lib/screens/premium_benefits_screen.dart**
   - Uses: PremiumProvider, ThemeProvider
   - Pattern: Consumer2

4. **lib/screens/profile_screen.dart**
   - Uses: UserProvider, ThemeProvider
   - Pattern: Consumer2, multiple method parameters

5. **lib/screens/replay_viewer_screen.dart**
   - Uses: ThemeProvider
   - Pattern: Consumer

6. **lib/screens/replays_screen.dart**
   - Uses: ThemeProvider
   - Pattern: Consumer

7. **lib/screens/settings_screen.dart**
   - Uses: ThemeProvider, GameProvider, UserProvider, PremiumProvider
   - Pattern: Consumer4 (complex!)
   - Note: GameProvider settings → GameSettingsCubit

8. **lib/screens/store_screen.dart**
   - Uses: PremiumProvider, ThemeProvider, CoinsProvider
   - Pattern: Consumer3, multiple method calls

9. **lib/screens/theme_selector_screen.dart**
   - Uses: ThemeProvider, PremiumProvider
   - Pattern: Consumer2

10. **lib/screens/tournaments_screen.dart**
    - Uses: ThemeProvider
    - Pattern: Consumer

### Widgets (1 remaining)
1. **lib/widgets/game_board.dart**
   - Uses: ThemeProvider, PremiumProvider, GameProvider
   - Pattern: Consumer2, Consumer for GameProvider (moveProgress, previousGameState)
   - Note: Need GameCubit for moveProgress interpolation

### Services (1 remaining)
1. **lib/services/purchase_service.dart**
   - Uses: UserProvider (for user ID during purchases)
   - Fix: Use AuthCubit or pass userId as parameter

---

## Important API Notes

### GameSettingsCubit (for game settings)
Settings like `dPadEnabled`, `dPadPosition`, `crashFeedbackDuration`, `isTrailSystemEnabled` are in **GameSettingsCubit**, not GameCubit.

```dart
final settingsState = context.watch<GameSettingsCubit>().state;
settingsState.dPadEnabled
settingsState.dPadPosition
settingsState.crashFeedbackDuration
settingsState.isTrailSystemEnabled
```

### BattlePassCubit Methods
```dart
battlePassCubit.activate() // replaces unlockBattlePass()
battlePassCubit.claimFreeReward(tier)
battlePassCubit.claimPremiumReward(tier)
battlePassCubit.addXP(xp)
```

### PremiumCubit Methods
```dart
premiumCubit.purchaseSkin(skinId)
premiumCubit.selectSkin(skinId)
premiumCubit.purchaseTheme(theme)
// Note: hasBattlePass, battlePassTier, battlePassXP moved to BattlePassCubit
```

---

## Files Structure

### Cubit Files Location
```
lib/presentation/bloc/
├── auth/
│   ├── auth_cubit.dart
│   └── auth_state.dart
├── coins/
│   ├── coins_cubit.dart
│   └── coins_state.dart
├── game/
│   ├── game_cubit.dart
│   ├── game_state.dart
│   └── game_settings_cubit.dart (exports game_settings_state.dart)
├── multiplayer/
│   ├── multiplayer_cubit.dart
│   └── multiplayer_state.dart
├── premium/
│   ├── premium_cubit.dart
│   ├── premium_state.dart
│   ├── battle_pass_cubit.dart
│   └── battle_pass_state.dart
└── theme/
    ├── theme_cubit.dart
    └── theme_state.dart
```

---

## Import Replacements

```dart
// Remove these imports:
import 'package:provider/provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/providers/game_provider.dart';
import 'package:snake_classic/providers/user_provider.dart';
import 'package:snake_classic/providers/premium_provider.dart';
import 'package:snake_classic/providers/coins_provider.dart';
import 'package:snake_classic/providers/multiplayer_provider.dart';

// Add these imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/battle_pass_cubit.dart';
```

---

## Next Steps

1. Migrate remaining 10 screens (start with simpler ones: replays_screen, replay_viewer_screen, tournaments_screen)
2. Migrate game_board.dart widget
3. Fix purchase_service.dart
4. Run `flutter analyze` to verify all errors are resolved
5. Remove `provider` dependency from pubspec.yaml (only after all migrations complete)
6. Test the app thoroughly

---

## Commands

```bash
# Check remaining errors
flutter analyze

# Count errors only
flutter analyze 2>&1 | grep -c "error"

# Run the app
flutter run
```

---

## Last Flutter Analyze Output
- Total errors: 127
- Warnings: ~10 (mostly unused fields in game_cubit.dart)
- Info: ~15 (mostly unnecessary imports and super_parameters suggestions)

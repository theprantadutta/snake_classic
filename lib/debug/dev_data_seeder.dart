import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/game/session/game_run_summary.dart';
import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/presentation/bloc/game/game_settings_cubit.dart';
import 'package:snake_classic/services/game_end_pipeline.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/logger.dart';

/// Debug-only: gives a TEST account a believable play history, for store
/// screenshots and for testing screens that look empty on a fresh install.
///
///     flutter run -d <device> --dart-define=LB_SEED=true
///
/// It never runs in a release or profile build: [kDebugMode] is a
/// compile-time constant, so the body is tree-shaken out of anything that
/// ships, and the define has to be passed deliberately on top of that.
///
/// How it works: it plays [_runs] synthetic finished runs through
/// [GameEndPipeline], the one path real games use for stats, coins, XP,
/// achievements, daily and weekly progress, Season XP and score submission.
/// So every screen agrees with every other and the data syncs to the backend
/// like real play. Scores climb over the runs the way a real player's do and
/// the last one sets the high score. Replays only come from real games, so
/// play a couple by hand if a screenshot needs them.
///
/// Rules, so it cannot pollute a real account by accident:
///  * It waits for a signed-in, non-guest account and seeds nothing until it
///    gets one: sign in first, then relaunch with the define if it gave up.
///  * It runs once per install. `LB_SEED_FORCE=true` runs it again, adding
///    another batch on top.
///  * `LB_SEED_RUNS` and `LB_SEED_BEST` change how many runs and the final
///    high score (defaults 40 and 3840).
///
/// For screenshots without ads, also give the account Pro on the backend:
/// `dotnet run grant-pro-to-user.cs -- grant <email>` in snake-classic-backend.
/// Only ever seed test accounts (kdstabsystem@gmail.com on the tablet,
/// realjohndoe276@gmail.com on the A24 were used for the 7.0.0 store shots).
abstract final class DevDataSeeder {
  static const bool _requested = bool.fromEnvironment('LB_SEED');
  static const bool _force = bool.fromEnvironment('LB_SEED_FORCE');
  static const int _runs = int.fromEnvironment('LB_SEED_RUNS', defaultValue: 40);
  static const int _best = int.fromEnvironment('LB_SEED_BEST', defaultValue: 3840);
  static const String _doneKey = 'debug_dev_data_seeded_v1';

  /// [authCubit] must be the app's own instance (from the widget tree): the
  /// DI registration is a factory, so `getIt<AuthCubit>()` would hand back a
  /// fresh cubit that never signs in.
  static Future<void> runIfRequested(AuthCubit authCubit) async {
    if (!kDebugMode || !_requested) return;
    final prefs = await SharedPreferences.getInstance();
    if (!_force && (prefs.getBool(_doneKey) ?? false)) return;

    // Home can appear before the cached sign-in has resolved: wait for it.
    bool ready(AuthState s) => s.isSignedIn && !s.isGuestUser;
    if (!ready(authCubit.state)) {
      try {
        await authCubit.stream
            .firstWhere(ready)
            .timeout(const Duration(seconds: 30));
      } catch (_) {
        AppLogger.info('DevDataSeeder: no signed-in account, skipping');
        return;
      }
    }
    // Marked first: a crash mid-seed must not loop on every launch.
    await prefs.setBool(_doneKey, true);

    final runs = max(1, _runs);
    final pipeline = getIt<GameEndPipeline>();
    final rng = Random(42);
    var best = 0;
    var noWallStreak = 0;
    final modes = [
      for (var i = 0; i < 6; i++) GameMode.classic,
      GameMode.zen,
      GameMode.speedChallenge,
      GameMode.multiFood,
      GameMode.survival,
      GameMode.timeAttack,
      GameMode.powerUpMadness,
    ];

    AppLogger.info('DevDataSeeder: seeding $runs runs');
    for (var i = 0; i < runs; i++) {
      final last = i == runs - 1;
      // A learning curve: early runs short, later ones long, the best last.
      final progress = runs == 1 ? 1.0 : i / (runs - 1);
      final trend = 60 + progress * (_best * 0.68);
      final score = last
          ? _best
          : (trend * (0.55 + rng.nextDouble() * 0.7)).round() ~/ 10 * 10;
      final food = max(1, score ~/ 13);
      final bonus = (food * (0.08 + rng.nextDouble() * 0.06)).round();
      final special = (food * (0.02 + rng.nextDouble() * 0.03)).round();
      final normal = max(0, food - bonus - special);
      final powerUps = rng.nextInt(1 + food ~/ 25);
      final hitWall = rng.nextDouble() < .55;
      noWallStreak = hitWall ? 0 : noWallStreak + 1;
      final mode = last ? GameMode.classic : modes[rng.nextInt(modes.length)];
      final powerUpTypes = <String, int>{};
      for (var p = 0; p < powerUps; p++) {
        final t = PowerUpType.values[rng.nextInt(PowerUpType.values.length)].name;
        powerUpTypes[t] = (powerUpTypes[t] ?? 0) + 1;
      }

      final summary = GameRunSummary(
        score: score,
        level: 1 + score ~/ 350,
        maxCombo: min(24, 2 + food ~/ 9 + rng.nextInt(4)),
        snakeLength: 3 + food,
        gameMode: mode.name,
        gameModeWire: mode.wireName,
        difficulty: Difficulty.normal.name,
        isTournament: false,
        durationSeconds: 25 + (score / 7.5).round() + rng.nextInt(30),
        foodTypes: {
          FoodType.normal.name: normal,
          if (bonus > 0) FoodType.bonus.name: bonus,
          if (special > 0) FoodType.special.name: special,
        },
        foodPoints: normal * 10 + bonus * 25 + special * 50,
        foodTypesEaten: {
          FoodType.normal.name,
          if (bonus > 0) FoodType.bonus.name,
          if (special > 0) FoodType.special.name,
        },
        powerUpsCollected: powerUps,
        powerUpTypes: powerUpTypes,
        powerUpTimeSeconds: powerUps * 8,
        hitWall: hitWall,
        hitSelf: !hitWall,
        wallHits: hitWall ? 1 : 0,
        selfHits: hitWall ? 0 : 1,
        consecutiveGamesWithoutWallHits: noWallStreak,
      );

      pipeline.evaluateLocalUnlocks(summary);
      await pipeline.runPostGame(
        summary,
        pendingLevelUpCoinLevels: [],
        awardedMilestones: {},
      );
      best = max(best, score);
    }

    // The high score is settled outside the pipeline, as a real game does.
    // Never lowered: a forced re-seed on top of a better real score keeps it.
    final storage = getIt<StorageService>();
    best = max(best, await storage.getHighScore());
    await storage.saveHighScore(best);
    await getIt<GameSettingsCubit>().updateHighScore(best);
    AppLogger.info('DevDataSeeder: done, best $best');
  }
}

import 'package:get_it/get_it.dart';

// Services
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/offline_cache_service.dart';
import 'package:snake_classic/services/connectivity_service.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/services/preferences_service.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/services/unified_user_service.dart';
import 'package:snake_classic/services/multiplayer_service.dart';
import 'package:snake_classic/services/enhanced_audio_service.dart';
import 'package:snake_classic/services/achievement_service.dart';
import 'package:snake_classic/services/statistics_service.dart';
import 'package:snake_classic/services/purchase_service.dart';

// Core
import 'package:snake_classic/core/network/network_info.dart';

// Data Sources
import 'package:snake_classic/data/datasources/local/cache_datasource.dart';
import 'package:snake_classic/data/datasources/remote/api_datasource.dart';

// Repositories
import 'package:snake_classic/domain/repositories/leaderboard_repository.dart';
import 'package:snake_classic/domain/repositories/achievement_repository.dart';
import 'package:snake_classic/domain/repositories/social_repository.dart';
import 'package:snake_classic/domain/repositories/tournament_repository.dart';
import 'package:snake_classic/data/repositories/leaderboard_repository_impl.dart';
import 'package:snake_classic/data/repositories/achievement_repository_impl.dart';
import 'package:snake_classic/data/repositories/social_repository_impl.dart';
import 'package:snake_classic/data/repositories/tournament_repository_impl.dart';

// Cubits
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart'; // Also exports game_settings_cubit
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/battle_pass_cubit.dart';

/// Global GetIt instance for dependency injection
final getIt = GetIt.instance;

/// Initialize all dependencies
/// Call this in main() before runApp()
Future<void> configureDependencies() async {
  // ==================== External Services ====================
  // These are services that already exist and have their own singleton patterns
  // We register them so other dependencies can use DI

  getIt.registerLazySingleton<ApiService>(() => ApiService());
  getIt.registerLazySingleton<OfflineCacheService>(() => OfflineCacheService());
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  getIt.registerLazySingleton<AudioService>(() => AudioService());
  getIt.registerLazySingleton<HapticService>(() => HapticService());
  getIt.registerLazySingleton<PreferencesService>(() => PreferencesService());
  getIt.registerLazySingleton<StorageService>(() => StorageService());
  getIt.registerLazySingleton<UnifiedUserService>(() => UnifiedUserService());
  getIt.registerLazySingleton<MultiplayerService>(() => MultiplayerService());
  getIt.registerLazySingleton<EnhancedAudioService>(
    () => EnhancedAudioService(),
  );
  getIt.registerLazySingleton<AchievementService>(() => AchievementService());
  getIt.registerLazySingleton<StatisticsService>(() => StatisticsService());
  getIt.registerLazySingleton<PurchaseService>(() => PurchaseService());

  // ==================== Core ====================

  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt<ConnectivityService>()),
  );

  // ==================== Data Sources ====================

  getIt.registerLazySingleton<CacheDataSource>(
    () => CacheDataSource(getIt<OfflineCacheService>()),
  );

  getIt.registerLazySingleton<ApiDataSource>(
    () => ApiDataSource(getIt<ApiService>()),
  );

  // ==================== Repositories ====================
  // Repositories with caching pattern: cache → network → stale fallback

  getIt.registerLazySingleton<LeaderboardRepository>(
    () => LeaderboardRepositoryImpl(
      remote: getIt<ApiDataSource>(),
      cache: getIt<CacheDataSource>(),
      network: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton<AchievementRepository>(
    () => AchievementRepositoryImpl(
      remote: getIt<ApiDataSource>(),
      cache: getIt<CacheDataSource>(),
      network: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton<SocialRepository>(
    () => SocialRepositoryImpl(
      remote: getIt<ApiDataSource>(),
      cache: getIt<CacheDataSource>(),
      network: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton<TournamentRepository>(
    () => TournamentRepositoryImpl(
      remote: getIt<ApiDataSource>(),
      cache: getIt<CacheDataSource>(),
      network: getIt<NetworkInfo>(),
    ),
  );

  // ==================== Cubits ====================
  // Cubits are registered as factories (new instance each time)
  // This ensures fresh state when navigating to new screens

  getIt.registerFactory<ThemeCubit>(
    () => ThemeCubit(getIt<PreferencesService>()),
  );

  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(getIt<UnifiedUserService>()),
  );

  getIt.registerFactory<CoinsCubit>(() => CoinsCubit());

  getIt.registerFactory<MultiplayerCubit>(
    () => MultiplayerCubit(
      multiplayerService: getIt<MultiplayerService>(),
      userService: getIt<UnifiedUserService>(),
      audioService: getIt<AudioService>(),
      hapticService: getIt<HapticService>(),
    ),
  );

  getIt.registerLazySingleton<GameSettingsCubit>(
    () => GameSettingsCubit(getIt<StorageService>()),
  );

  getIt.registerFactory<GameCubit>(
    () => GameCubit(
      audioService: getIt<AudioService>(),
      enhancedAudioService: getIt<EnhancedAudioService>(),
      hapticService: getIt<HapticService>(),
      achievementService: getIt<AchievementService>(),
      statisticsService: getIt<StatisticsService>(),
      storageService: getIt<StorageService>(),
      settingsCubit: getIt<GameSettingsCubit>(),
    ),
  );

  getIt.registerFactory<PremiumCubit>(
    () => PremiumCubit(
      purchaseService: getIt<PurchaseService>(),
      storageService: getIt<StorageService>(),
    ),
  );

  getIt.registerFactory<BattlePassCubit>(
    () => BattlePassCubit(storageService: getIt<StorageService>()),
  );
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
}

/// Check if dependencies are registered
bool get dependenciesRegistered => getIt.isRegistered<ApiService>();

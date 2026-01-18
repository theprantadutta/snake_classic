import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:snake_classic/data/daos/settings_dao.dart';
import 'package:snake_classic/data/daos/game_dao.dart';
import 'package:snake_classic/data/daos/store_dao.dart';
import 'package:snake_classic/data/daos/sync_dao.dart';

part 'app_database.g.dart';

// =====================================================
// TABLE 1: Game Settings
// =====================================================
class GameSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get themeIndex => integer().withDefault(const Constant(0))();
  BoolColumn get soundEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get musicEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get dPadEnabled => boolean().withDefault(const Constant(false))();
  IntColumn get dPadPositionIndex =>
      integer().withDefault(const Constant(1))(); // 0=left, 1=center, 2=right
  IntColumn get boardSizeIndex => integer().withDefault(const Constant(1))();
  IntColumn get highScore => integer().withDefault(const Constant(0))();
  IntColumn get crashFeedbackDurationSeconds =>
      integer().withDefault(const Constant(3))();
  BoolColumn get trailSystemEnabled =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get screenShakeEnabled =>
      boolean().withDefault(const Constant(false))();
  TextColumn get selectedSkinId => text().nullable()();
  TextColumn get selectedTrailId => text().nullable()();
  DateTimeColumn get lastUpdated =>
      dateTime().withDefault(currentDateAndTime)();
}

// =====================================================
// TABLE 2: Statistics (37 fields for comprehensive game stats)
// =====================================================
class Statistics extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Core stats
  IntColumn get totalGamesPlayed => integer().withDefault(const Constant(0))();
  IntColumn get totalScore => integer().withDefault(const Constant(0))();
  IntColumn get highestScore => integer().withDefault(const Constant(0))();
  IntColumn get totalFoodsEaten => integer().withDefault(const Constant(0))();
  IntColumn get totalGameTimeSeconds =>
      integer().withDefault(const Constant(0))();

  // Snake length stats
  IntColumn get maxSnakeLength => integer().withDefault(const Constant(0))();
  IntColumn get totalSnakeLength => integer().withDefault(const Constant(0))();
  RealColumn get averageSnakeLength =>
      real().withDefault(const Constant(0.0))();

  // Death stats
  IntColumn get deathsByWall => integer().withDefault(const Constant(0))();
  IntColumn get deathsBySelf => integer().withDefault(const Constant(0))();
  IntColumn get totalDeaths => integer().withDefault(const Constant(0))();

  // Session stats
  IntColumn get longestSessionSeconds =>
      integer().withDefault(const Constant(0))();
  IntColumn get shortestGameSeconds =>
      integer().withDefault(const Constant(0))();
  IntColumn get longestGameSeconds =>
      integer().withDefault(const Constant(0))();
  RealColumn get averageGameDuration =>
      real().withDefault(const Constant(0.0))();

  // Streak stats
  IntColumn get currentWinStreak => integer().withDefault(const Constant(0))();
  IntColumn get longestWinStreak => integer().withDefault(const Constant(0))();
  IntColumn get currentPlayStreak =>
      integer().withDefault(const Constant(0))(); // Days in a row
  IntColumn get longestPlayStreak => integer().withDefault(const Constant(0))();

  // Per-mode stats (stored as JSON)
  TextColumn get classicModeStats =>
      text().withDefault(const Constant('{}'))();
  TextColumn get zenModeStats => text().withDefault(const Constant('{}'))();
  TextColumn get speedModeStats => text().withDefault(const Constant('{}'))();
  TextColumn get survivalModeStats =>
      text().withDefault(const Constant('{}'))();
  TextColumn get timeAttackModeStats =>
      text().withDefault(const Constant('{}'))();

  // Power-up stats
  IntColumn get powerUpsCollected => integer().withDefault(const Constant(0))();
  IntColumn get speedBoostsUsed => integer().withDefault(const Constant(0))();
  IntColumn get shieldsUsed => integer().withDefault(const Constant(0))();
  IntColumn get scoreMultipliersUsed =>
      integer().withDefault(const Constant(0))();

  // Special achievements data
  IntColumn get perfectGames =>
      integer().withDefault(const Constant(0))(); // No deaths in session
  IntColumn get closeCallsSurvived =>
      integer().withDefault(const Constant(0))(); // Near-miss scenarios
  IntColumn get foodsEatenInSingleGame =>
      integer().withDefault(const Constant(0))();

  // Multiplayer stats
  IntColumn get multiplayerGamesPlayed =>
      integer().withDefault(const Constant(0))();
  IntColumn get multiplayerWins => integer().withDefault(const Constant(0))();
  IntColumn get multiplayerLosses => integer().withDefault(const Constant(0))();

  // Tournament stats
  IntColumn get tournamentsEntered =>
      integer().withDefault(const Constant(0))();
  IntColumn get tournamentsWon => integer().withDefault(const Constant(0))();
  IntColumn get bestTournamentPlacement =>
      integer().withDefault(const Constant(0))();

  // Timestamps
  DateTimeColumn get lastPlayedAt => dateTime().nullable()();
  DateTimeColumn get lastUpdated =>
      dateTime().withDefault(currentDateAndTime)();
}

// =====================================================
// TABLE 3: Achievements
// =====================================================
class Achievements extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get category =>
      text().withDefault(const Constant('general'))(); // general, skill, etc.
  IntColumn get currentProgress => integer().withDefault(const Constant(0))();
  IntColumn get targetProgress => integer().withDefault(const Constant(1))();
  BoolColumn get isUnlocked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get unlockedAt => dateTime().nullable()();
  IntColumn get rewardCoins => integer().withDefault(const Constant(0))();
  BoolColumn get rewardClaimed => boolean().withDefault(const Constant(false))();
  TextColumn get iconName => text().nullable()();
  BoolColumn get isSecret => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastUpdated =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// =====================================================
// TABLE 4: Coins (Balance & Transactions)
// =====================================================
class Coins extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get balance => integer().withDefault(const Constant(0))();
  IntColumn get totalEarned => integer().withDefault(const Constant(0))();
  IntColumn get totalSpent => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastUpdated =>
      dateTime().withDefault(currentDateAndTime)();
}

class CoinTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amount => integer()();
  TextColumn get type =>
      text()(); // 'earned', 'spent', 'bonus', 'purchase', 'refund'
  TextColumn get source =>
      text()(); // 'game', 'achievement', 'daily_bonus', 'purchase', etc.
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// =====================================================
// TABLE 5: Premium Status
// =====================================================
class PremiumStatus extends Table {
  IntColumn get id => integer().autoIncrement()();
  BoolColumn get isPremiumActive =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get premiumExpirationDate => dateTime().nullable()();
  BoolColumn get isOnTrial => boolean().withDefault(const Constant(false))();
  DateTimeColumn get trialStartDate => dateTime().nullable()();
  DateTimeColumn get trialEndDate => dateTime().nullable()();
  IntColumn get bronzeTournamentEntries =>
      integer().withDefault(const Constant(0))();
  IntColumn get silverTournamentEntries =>
      integer().withDefault(const Constant(0))();
  IntColumn get goldTournamentEntries =>
      integer().withDefault(const Constant(0))();
  TextColumn get purchaseReceiptData =>
      text().nullable()(); // For purchase validation
  DateTimeColumn get lastUpdated =>
      dateTime().withDefault(currentDateAndTime)();
}

// =====================================================
// TABLE 6: Unlocked Items
// =====================================================
class UnlockedItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get itemId => text()();
  TextColumn get itemType =>
      text()(); // 'theme', 'skin', 'trail', 'powerup', 'board_size', 'game_mode', 'bundle'
  DateTimeColumn get unlockedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get unlockedBy =>
      text().withDefault(const Constant('purchase'))(); // 'purchase', 'achievement', 'battle_pass', 'gift'
}

// =====================================================
// TABLE 7: Battle Pass
// =====================================================
class BattlePasses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get seasonId => text()();
  IntColumn get currentTier => integer().withDefault(const Constant(0))();
  IntColumn get currentXp => integer().withDefault(const Constant(0))();
  IntColumn get xpForNextTier => integer().withDefault(const Constant(100))();
  BoolColumn get isPremiumPass =>
      boolean().withDefault(const Constant(false))();
  TextColumn get claimedRewards =>
      text().withDefault(const Constant('[]'))(); // JSON array of tier numbers
  DateTimeColumn get seasonStartDate => dateTime().nullable()();
  DateTimeColumn get seasonEndDate => dateTime().nullable()();
  DateTimeColumn get lastUpdated =>
      dateTime().withDefault(currentDateAndTime)();
}

// =====================================================
// TABLE 8: Daily Challenges
// =====================================================
class DailyChallenges extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get challengeId => text()();
  TextColumn get challengeType =>
      text()(); // 'score', 'length', 'time', 'foods', etc.
  TextColumn get title => text()();
  TextColumn get description => text()();
  IntColumn get currentProgress => integer().withDefault(const Constant(0))();
  IntColumn get targetProgress => integer()();
  IntColumn get rewardCoins => integer().withDefault(const Constant(0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get rewardClaimed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get challengeDate => dateTime()();
  DateTimeColumn get expiresAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

// =====================================================
// TABLE 9: Replays
// =====================================================
class Replays extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().nullable()();
  IntColumn get score => integer()();
  IntColumn get snakeLength => integer()();
  IntColumn get gameDurationSeconds => integer()();
  TextColumn get gameMode => text().withDefault(const Constant('classic'))();
  TextColumn get boardSize =>
      text().withDefault(const Constant('20x20'))(); // e.g., "20x20"
  TextColumn get replayData => text()(); // JSON encoded replay frames
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get recordedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// =====================================================
// TABLE 10: Sync Queue (Pending items to sync to backend)
// =====================================================
class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get dataType =>
      text()(); // 'score', 'profile', 'preferences', 'achievement', etc.
  TextColumn get data => text()(); // JSON encoded data
  IntColumn get priority =>
      integer().withDefault(const Constant(2))(); // 0=critical, 1=high, 2=normal, 3=low
  IntColumn get status =>
      integer().withDefault(const Constant(0))(); // 0=pending, 1=syncing, 2=failed, 3=completed
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get queuedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// =====================================================
// TABLE 11: Cache Store (Offline cache with TTL)
// =====================================================
class CacheStore extends Table {
  TextColumn get key => text()();
  TextColumn get data => text()(); // JSON encoded data
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get ttlMillis => integer()(); // Time to live in milliseconds
  DateTimeColumn get expiresAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

// =====================================================
// TABLE 12: User Profile (for offline access)
// =====================================================
class UserProfile extends Table {
  TextColumn get id => text()();
  TextColumn get firebaseUid => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get displayName => text().nullable()();
  TextColumn get photoUrl => text().nullable()();
  TextColumn get providerId =>
      text().nullable()(); // 'google', 'apple', 'guest'
  BoolColumn get isGuest => boolean().withDefault(const Constant(true))();
  IntColumn get globalRank => integer().nullable()();
  IntColumn get weeklyRank => integer().nullable()();
  TextColumn get country => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastLoginAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// =====================================================
// Purchase History (for tracking)
// =====================================================
class PurchaseHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get purchaseId => text()();
  TextColumn get productId => text()();
  TextColumn get transactionId => text().nullable()();
  IntColumn get amount => integer()(); // Price in cents
  TextColumn get currency => text().withDefault(const Constant('USD'))();
  TextColumn get status =>
      text()(); // 'pending', 'completed', 'failed', 'refunded'
  TextColumn get receiptData => text().nullable()();
  DateTimeColumn get purchasedAt => dateTime().withDefault(currentDateAndTime)();
}

// =====================================================
// DATABASE CLASS
// =====================================================
@DriftDatabase(
  tables: [
    GameSettings,
    Statistics,
    Achievements,
    Coins,
    CoinTransactions,
    PremiumStatus,
    UnlockedItems,
    BattlePasses,
    DailyChallenges,
    Replays,
    SyncQueue,
    CacheStore,
    UserProfile,
    PurchaseHistory,
  ],
  daos: [
    SettingsDao,
    GameDao,
    StoreDao,
    SyncDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  /// Initialize default data if tables are empty
  Future<void> initializeDefaults() async {
    // Initialize game settings if not exists
    final existingSettings = await select(gameSettings).getSingleOrNull();
    if (existingSettings == null) {
      await into(gameSettings).insert(GameSettingsCompanion.insert());
    }

    // Initialize statistics if not exists
    final existingStats = await select(statistics).getSingleOrNull();
    if (existingStats == null) {
      await into(statistics).insert(StatisticsCompanion.insert());
    }

    // Initialize coins if not exists
    final existingCoins = await select(coins).getSingleOrNull();
    if (existingCoins == null) {
      await into(coins).insert(CoinsCompanion.insert());
    }

    // Initialize premium status if not exists
    final existingPremium = await select(premiumStatus).getSingleOrNull();
    if (existingPremium == null) {
      await into(premiumStatus).insert(PremiumStatusCompanion.insert());
    }
  }

  /// Clear all data (for logout/reset)
  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(gameSettings).go();
      await delete(statistics).go();
      await delete(achievements).go();
      await delete(coins).go();
      await delete(coinTransactions).go();
      await delete(premiumStatus).go();
      await delete(unlockedItems).go();
      await delete(battlePasses).go();
      await delete(dailyChallenges).go();
      await delete(replays).go();
      await delete(syncQueue).go();
      await delete(cacheStore).go();
      await delete(userProfile).go();
      await delete(purchaseHistory).go();
    });

    // Reinitialize defaults
    await initializeDefaults();
  }
}

/// Opens a connection to the SQLite database
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'snake_classic.db'));
    return NativeDatabase.createInBackground(file);
  });
}

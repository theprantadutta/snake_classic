import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/purchase_service.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/models/premium_cosmetics.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/logger.dart';

import 'premium_state.dart';

export 'premium_state.dart';

/// Cubit for managing premium subscription and owned content
class PremiumCubit extends Cubit<PremiumState> {
  final PurchaseService _purchaseService;
  final StorageService _storageService;
  final CoinsCubit? _coinsCubit;
  StreamSubscription<String>? _purchaseStatusSubscription;

  PremiumCubit({
    required PurchaseService purchaseService,
    required StorageService storageService,
    CoinsCubit? coinsCubit,
  }) : _purchaseService = purchaseService,
       _storageService = storageService,
       _coinsCubit = coinsCubit,
       super(PremiumState.initial());

  /// Initialize premium status
  Future<void> initialize() async {
    if (state.status == PremiumStatus.ready) return;

    emit(state.copyWith(status: PremiumStatus.loading));

    try {
      await _purchaseService.initialize();

      // Load saved premium state
      final isPremiumActive = await _storageService.isPremiumActive();
      final expiryDateStr = await _storageService.getPremiumExpirationDate();
      final selectedSkinId =
          await _storageService.getSelectedSkinId() ?? 'classic';
      final selectedTrailId =
          await _storageService.getSelectedTrailId() ?? 'none';
      final ownedThemes = await _storageService.getUnlockedThemes();
      final ownedSkins = await _storageService.getUnlockedSkins();
      final ownedTrails = await _storageService.getUnlockedTrails();
      final ownedPowerUps = await _storageService.getUnlockedPowerUps();
      final ownedBoardSizes = await _storageService.getUnlockedBoardSizes();
      final ownedBundles = await _storageService.getUnlockedBundles();
      final trialData = await _storageService.getTrialData();
      final tournamentEntries = await _storageService.getTournamentEntries();

      DateTime? expiryDate;
      if (expiryDateStr != null) {
        expiryDate = DateTime.tryParse(expiryDateStr);
      }

      // Parse trial dates
      DateTime? trialStartDate;
      DateTime? trialEndDate;
      if (trialData['trialStartDate'] != null) {
        trialStartDate = DateTime.tryParse(trialData['trialStartDate']);
      }
      if (trialData['trialEndDate'] != null) {
        trialEndDate = DateTime.tryParse(trialData['trialEndDate']);
      }

      // Migrate bare trail IDs to prefixed form (trail_particle, etc.)
      final migratedTrails = _migrateTrailIds(ownedTrails.toSet());
      final migratedSelectedTrail = _migrateTrailId(selectedTrailId);

      emit(
        state.copyWith(
          status: PremiumStatus.ready,
          tier: isPremiumActive ? PremiumTier.pro : PremiumTier.free,
          subscriptionExpiry: expiryDate,
          selectedSkinId: selectedSkinId,
          selectedTrailId: migratedSelectedTrail,
          ownedThemes: _parseThemes(ownedThemes),
          ownedSkins: ownedSkins.toSet(),
          ownedTrails: migratedTrails,
          ownedPowerUps: ownedPowerUps.toSet(),
          ownedBoardSizes: ownedBoardSizes.toSet(),
          ownedBundles: ownedBundles.toSet(),
          isOnTrial: trialData['isOnTrial'] ?? false,
          trialStartDate: trialStartDate,
          trialEndDate: trialEndDate,
          bronzeTournamentEntries: tournamentEntries['bronze'] ?? 0,
          silverTournamentEntries: tournamentEntries['silver'] ?? 0,
          goldTournamentEntries: tournamentEntries['gold'] ?? 0,
        ),
      );

      // Persist migrated trail data if any IDs were changed
      if (migratedTrails.length != ownedTrails.length ||
          !migratedTrails.every((t) => ownedTrails.contains(t))) {
        await _storageService.setUnlockedTrails(migratedTrails.toList());
      }
      if (migratedSelectedTrail != selectedTrailId) {
        await _storageService.setSelectedTrailId(migratedSelectedTrail);
      }

      // Reconcile bundle contents for existing bundle owners
      for (final bundleId in state.ownedBundles) {
        final bundle = CosmeticBundle.availableBundles
            .where((b) => b.id == bundleId)
            .firstOrNull;
        if (bundle != null) {
          for (final skin in bundle.skins) {
            if (!state.ownedSkins.contains(skin.id)) {
              await unlockSkin(skin.id);
            }
          }
          for (final trail in bundle.trails) {
            if (!state.ownedTrails.contains(trail.id)) {
              await unlockTrail(trail.id);
            }
          }
        }
      }

      // Listen to purchase updates
      _setupPurchaseListener();

      // Merge entitlements from backend (non-blocking)
      unawaited(syncWithBackend());

      AppLogger.info('PremiumCubit initialized. Premium: ${state.hasPremium}');
    } catch (e) {
      AppLogger.error('Error initializing PremiumCubit', e);
      emit(
        state.copyWith(status: PremiumStatus.error, errorMessage: e.toString()),
      );
    }
  }

  /// Known bare trail enum names that need the 'trail_' prefix
  static const _bareTrailNames = {
    'particle', 'glow', 'rainbow', 'fire', 'electric',
    'star', 'cosmic', 'neon', 'shadow', 'crystal', 'dragon',
  };

  /// Migrate a single trail ID: bare name → prefixed form
  String _migrateTrailId(String trailId) {
    if (trailId == 'none') return 'none';
    if (_bareTrailNames.contains(trailId)) return 'trail_$trailId';
    return trailId;
  }

  /// Migrate a set of trail IDs from bare to prefixed form
  Set<String> _migrateTrailIds(Set<String> trailIds) {
    return trailIds.map(_migrateTrailId).toSet();
  }

  Set<GameTheme> _parseThemes(List<String> themeNames) {
    return themeNames
        .map((name) {
          try {
            return GameTheme.values.firstWhere((t) => t.name == name);
          } catch (e) {
            return null;
          }
        })
        .whereType<GameTheme>()
        .toSet();
  }

  void _setupPurchaseListener() {
    _purchaseStatusSubscription = _purchaseService.purchaseStatusStream.listen((
      status,
    ) {
      if (status == 'premium_purchased' || status == 'premium_restored') {
        _handlePremiumPurchased();
      } else if (status.startsWith('purchase_completed:')) {
        final productId = status.substring('purchase_completed:'.length);
        _handlePurchaseCompleted(productId);
      }
    });
  }

  Future<void> _handlePurchaseCompleted(String productId) async {
    AppLogger.info('Handling purchase completion: $productId');

    // Strip store prefix — all comparisons below use internal IDs
    final internalId = ProductIds.stripPrefix(productId);

    // Subscriptions — route monthly vs yearly for correct expiry
    if (internalId.contains('pro_monthly')) {
      _handlePremiumPurchased(isYearly: false);
      return;
    }
    if (internalId.contains('pro_yearly')) {
      _handlePremiumPurchased(isYearly: true);
      return;
    }

    // Coin packs — credit coins via CoinsCubit
    const coinPackOptions = {
      'coin_pack_small': 'coin_pack_small',
      'coin_pack_medium': 'coin_pack_medium',
      'coin_pack_large': 'coin_pack_large',
      'coin_pack_mega': 'coin_pack_mega',
    };
    if (coinPackOptions.containsKey(internalId)) {
      final option = CoinPurchaseOption.availableOptions
          .where((o) => o.id == internalId)
          .firstOrNull;
      if (option != null && _coinsCubit != null) {
        await _coinsCubit.purchaseCoins(option, productId);
        AppLogger.info(
          'Coin pack delivered: ${option.totalCoins} coins for $internalId',
        );
      } else {
        AppLogger.error(
          'Failed to deliver coin pack: option=$option, coinsCubit=$_coinsCubit',
        );
      }
      return;
    }

    // Theme purchases
    const themeProductMap = {
      'crystal_theme': GameTheme.crystal,
      'cyberpunk_theme': GameTheme.cyberpunk,
      'space_theme': GameTheme.space,
      'ocean_theme': GameTheme.ocean,
      'desert_theme': GameTheme.desert,
      'forest_theme': GameTheme.forest,
    };
    if (themeProductMap.containsKey(internalId)) {
      await unlockTheme(themeProductMap[internalId]!);
      return;
    }

    // Theme bundle — unlock all premium themes
    if (internalId == 'premium_themes_bundle') {
      for (final theme in PremiumContent.premiumThemes) {
        await unlockTheme(theme);
      }
      return;
    }

    // Trail effects (prefixed with 'trail_')
    if (internalId.startsWith('trail_')) {
      await unlockTrail(internalId);
      return;
    }

    // Snake skins (store IDs use skin_ prefix, strip it for internal ID)
    const skinNames = {
      'golden', 'rainbow', 'galaxy', 'dragon', 'electric',
      'fire', 'ice', 'shadow', 'neon', 'crystal', 'cosmic',
    };
    final skinInternalId = internalId.startsWith('skin_')
        ? internalId.substring('skin_'.length)
        : internalId;
    if (skinNames.contains(skinInternalId)) {
      await unlockSkin(skinInternalId);
      return;
    }

    // Cosmetic bundles
    const bundleIds = {
      'starter_pack', 'elemental_pack', 'cosmic_collection',
      'ultimate_collection',
    };
    if (bundleIds.contains(internalId)) {
      await unlockBundle(internalId);
      return;
    }

    // Tournament entries — handle all 5 types including championship & VIP
    if (internalId.contains('tournament') ||
        internalId.contains('championship')) {
      if (internalId.contains('bronze')) {
        await addTournamentEntry('bronze');
      } else if (internalId.contains('silver')) {
        await addTournamentEntry('silver');
      } else if (internalId.contains('gold')) {
        await addTournamentEntry('gold');
      } else if (internalId.contains('championship')) {
        await addTournamentEntry('gold'); // Championship maps to gold tier
      } else if (internalId.contains('vip')) {
        await addTournamentEntry('gold'); // VIP maps to gold tier
      }
      return;
    }

    // Battle pass
    if (internalId.contains('battle_pass')) {
      emit(state.copyWith(hasBattlePass: true));
      AppLogger.info('Battle pass activated via purchase');
      return;
    }

    AppLogger.warning('Unhandled purchase product: $internalId');
  }

  void _handlePremiumPurchased({bool isYearly = false}) {
    final duration = isYearly
        ? const Duration(days: 365)
        : const Duration(days: 30);
    final expiry = DateTime.now().add(duration);
    emit(state.copyWith(tier: PremiumTier.pro, subscriptionExpiry: expiry));
    _storageService.setPremiumActive(true);
    _storageService.setPremiumExpirationDate(expiry.toIso8601String());
    _coinsCubit?.updatePremiumMultiplier(true, state.hasBattlePass);
  }

  /// Purchase premium subscription (monthly)
  /// Note: actual unlock happens via purchase stream in _handlePurchaseCompleted
  Future<bool> purchasePremium() async {
    try {
      final result = await _purchaseService.purchaseProduct(
        ProductIds.snakeClassicProMonthly,
      );
      // Do NOT call _handlePremiumPurchased() here — purchaseProduct() only
      // initiates the billing flow. The actual completion arrives asynchronously
      // via the purchase stream and is handled in _handlePurchaseCompleted().
      return result;
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Purchase failed: $e'));
      return false;
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    try {
      await _purchaseService.restorePurchases();
      // The purchase stream will handle updating state if purchases are found
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Restore failed: $e'));
    }
  }

  /// Sync battle pass status from BattlePassCubit
  void syncBattlePassStatus({required bool isActive, required int tier}) {
    if (state.hasBattlePass == isActive && state.battlePassTier == tier) return;
    emit(state.copyWith(hasBattlePass: isActive, battlePassTier: tier));
    _coinsCubit?.updatePremiumMultiplier(state.hasPremium, isActive);
  }

  /// Select skin
  Future<void> selectSkin(String skinId) async {
    if (state.selectedSkinId == skinId) return;

    emit(state.copyWith(selectedSkinId: skinId));
    await _storageService.setSelectedSkinId(skinId);
  }

  /// Select trail
  Future<void> selectTrail(String trailId) async {
    if (state.selectedTrailId == trailId) return;

    emit(state.copyWith(selectedTrailId: trailId));
    await _storageService.setSelectedTrailId(trailId);
  }

  /// Unlock a theme
  Future<void> unlockTheme(GameTheme theme) async {
    final updatedThemes = {...state.ownedThemes, theme};
    emit(state.copyWith(ownedThemes: updatedThemes));
    await _storageService.setUnlockedThemes(
      updatedThemes.map((t) => t.name).toList(),
    );
  }

  /// Unlock a skin
  Future<void> unlockSkin(String skinId) async {
    final updatedSkins = {...state.ownedSkins, skinId};
    emit(state.copyWith(ownedSkins: updatedSkins));
    await _storageService.setUnlockedSkins(updatedSkins.toList());
  }

  /// Unlock a trail
  Future<void> unlockTrail(String trailId) async {
    final updatedTrails = {...state.ownedTrails, trailId};
    emit(state.copyWith(ownedTrails: updatedTrails));
    await _storageService.setUnlockedTrails(updatedTrails.toList());
  }

  /// Unlock a power-up
  Future<void> unlockPowerUp(String powerUpId) async {
    final updatedPowerUps = {...state.ownedPowerUps, powerUpId};
    emit(state.copyWith(ownedPowerUps: updatedPowerUps));
    await _storageService.setUnlockedPowerUps(updatedPowerUps.toList());
    AppLogger.info('Power-up unlocked: $powerUpId');
  }

  /// Unlock a board size
  Future<void> unlockBoardSize(String boardSizeId) async {
    final updatedBoardSizes = {...state.ownedBoardSizes, boardSizeId};
    emit(state.copyWith(ownedBoardSizes: updatedBoardSizes));
    await _storageService.setUnlockedBoardSizes(updatedBoardSizes.toList());
    AppLogger.info('Board size unlocked: $boardSizeId');
  }

  /// Unlock a bundle (and all its contents)
  Future<void> unlockBundle(String bundleId) async {
    if (state.ownedBundles.contains(bundleId)) return;

    final updatedBundles = {...state.ownedBundles, bundleId};
    emit(state.copyWith(ownedBundles: updatedBundles));
    await _storageService.setUnlockedBundles(updatedBundles.toList());

    // Unlock all contained items
    final bundle = CosmeticBundle.availableBundles
        .where((b) => b.id == bundleId)
        .firstOrNull;
    if (bundle != null) {
      for (final skin in bundle.skins) {
        await unlockSkin(skin.id);
      }
      for (final trail in bundle.trails) {
        await unlockTrail(trail.id);
      }
    }

    AppLogger.info('Bundle unlocked: $bundleId');
  }

  /// Start free trial
  static const Duration trialDuration = Duration(days: 3);

  Future<void> startFreeTrial() async {
    if (state.hasUsedTrial) {
      emit(state.copyWith(errorMessage: 'Trial already used'));
      return;
    }

    final now = DateTime.now();
    final trialEnd = now.add(trialDuration);

    emit(
      state.copyWith(
        isOnTrial: true,
        trialStartDate: now,
        trialEndDate: trialEnd,
      ),
    );

    await _storageService.setTrialData(
      isOnTrial: true,
      trialStartDate: now,
      trialEndDate: trialEnd,
    );

    _coinsCubit?.updatePremiumMultiplier(true, state.hasBattlePass);
    AppLogger.info('Free trial started, ends: ${trialEnd.toIso8601String()}');
  }

  /// End trial
  Future<void> endTrial() async {
    emit(state.copyWith(isOnTrial: false));
    await _storageService.setTrialData(isOnTrial: false);
    _coinsCubit?.updatePremiumMultiplier(state.hasPremium, state.hasBattlePass);
    AppLogger.info('Trial ended');
  }

  /// Add tournament entry
  Future<void> addTournamentEntry(
    String tournamentType, {
    int count = 1,
  }) async {
    switch (tournamentType.toLowerCase()) {
      case 'bronze':
        emit(
          state.copyWith(
            bronzeTournamentEntries: state.bronzeTournamentEntries + count,
          ),
        );
        break;
      case 'silver':
        emit(
          state.copyWith(
            silverTournamentEntries: state.silverTournamentEntries + count,
          ),
        );
        break;
      case 'gold':
        emit(
          state.copyWith(
            goldTournamentEntries: state.goldTournamentEntries + count,
          ),
        );
        break;
    }
    await _saveTournamentEntries();
    AppLogger.info('Tournament entry added: $tournamentType x$count');
  }

  /// Use tournament entry
  Future<void> useTournamentEntry(String tournamentType) async {
    switch (tournamentType.toLowerCase()) {
      case 'bronze':
        if (state.bronzeTournamentEntries > 0) {
          emit(
            state.copyWith(
              bronzeTournamentEntries: state.bronzeTournamentEntries - 1,
            ),
          );
        }
        break;
      case 'silver':
        if (state.silverTournamentEntries > 0) {
          emit(
            state.copyWith(
              silverTournamentEntries: state.silverTournamentEntries - 1,
            ),
          );
        }
        break;
      case 'gold':
        if (state.goldTournamentEntries > 0) {
          emit(
            state.copyWith(
              goldTournamentEntries: state.goldTournamentEntries - 1,
            ),
          );
        }
        break;
    }
    await _saveTournamentEntries();
    AppLogger.info('Tournament entry used: $tournamentType');
  }

  Future<void> _saveTournamentEntries() async {
    await _storageService.setTournamentEntries(
      bronze: state.bronzeTournamentEntries,
      silver: state.silverTournamentEntries,
      gold: state.goldTournamentEntries,
    );
  }

  // Convenience checker methods (delegate to state)
  bool isThemeUnlocked(GameTheme theme) => state.isThemeUnlocked(theme);
  bool isSkinUnlocked(String skinId) => state.isSkinOwned(skinId);
  bool isTrailUnlocked(String trailId) => state.isTrailOwned(trailId);
  bool isPowerUpUnlocked(String powerUpId) =>
      state.isPowerUpUnlocked(powerUpId);
  bool isBoardSizeUnlocked(String boardSizeId) =>
      state.isBoardSizeUnlocked(boardSizeId);
  bool isBundleOwned(String bundleId) => state.isBundleOwned(bundleId);
  bool hasTournamentEntry(String type) => state.hasTournamentEntry(type);

  /// Sync premium entitlements from backend.
  /// Merges server-side entitlements into local state so purchases made on
  /// other devices or granted server-side are reflected.
  Future<void> syncWithBackend() async {
    try {
      final apiService = ApiService();
      if (!apiService.isAuthenticated) return;

      final data = await apiService.getPremiumContent();
      if (data == null) return;

      await _applyBackendEntitlements(data);
      AppLogger.info('Premium state synced with backend');
    } catch (e) {
      AppLogger.error('Error syncing premium state with backend', e);
    }
  }

  /// Apply entitlements returned by the backend to local state.
  Future<void> _applyBackendEntitlements(Map<String, dynamic> data) async {
    // Merge owned themes
    if (data['owned_themes'] is List) {
      for (final name in data['owned_themes']) {
        final theme = GameTheme.values.where((t) => t.name == name).firstOrNull;
        if (theme != null && !state.ownedThemes.contains(theme)) {
          await unlockTheme(theme);
        }
      }
    }

    // Merge owned skins
    if (data['owned_skins'] is List) {
      for (final skinId in data['owned_skins']) {
        if (!state.ownedSkins.contains(skinId)) {
          await unlockSkin(skinId as String);
        }
      }
    }

    // Merge owned trails
    if (data['owned_trails'] is List) {
      for (final trailId in data['owned_trails']) {
        if (!state.ownedTrails.contains(trailId)) {
          await unlockTrail(trailId as String);
        }
      }
    }

    // Merge owned bundles
    if (data['owned_bundles'] is List) {
      for (final bundleId in data['owned_bundles']) {
        if (!state.ownedBundles.contains(bundleId)) {
          await unlockBundle(bundleId as String);
        }
      }
    }

    // Update subscription status from backend
    if (data['is_premium'] == true) {
      final expiryStr = data['subscription_expiry'] as String?;
      final expiry = expiryStr != null ? DateTime.tryParse(expiryStr) : null;
      if (expiry != null && (state.subscriptionExpiry == null ||
          expiry.isAfter(state.subscriptionExpiry!))) {
        emit(state.copyWith(
          tier: PremiumTier.pro,
          subscriptionExpiry: expiry,
        ));
        _storageService.setPremiumActive(true);
        _storageService.setPremiumExpirationDate(expiry.toIso8601String());
      }
    }
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  /// Get purchase history
  Future<List<Map<String, dynamic>>> getPurchaseHistory() async {
    // Return purchase history from storage or service
    final purchases = _purchaseService.purchases;
    return purchases
        .map(
          (p) => {
            'productId': p.productID,
            'purchaseId': p.purchaseID,
            'transactionDate': p.transactionDate,
            'status': p.status.toString(),
          },
        )
        .toList();
  }

  @override
  Future<void> close() {
    _purchaseStatusSubscription?.cancel();
    return super.close();
  }
}

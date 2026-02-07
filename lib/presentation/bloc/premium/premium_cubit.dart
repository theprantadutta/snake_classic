import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/services/purchase_service.dart';
import 'package:snake_classic/services/storage_service.dart';
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

      // Listen to purchase updates
      _setupPurchaseListener();

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

    // Subscriptions
    if (productId.contains('pro_monthly') ||
        productId.contains('pro_yearly')) {
      _handlePremiumPurchased();
      return;
    }

    // Trail effects (prefixed with 'trail_')
    if (productId.startsWith('trail_')) {
      await unlockTrail(productId);
      return;
    }

    // Snake skins (individual skin IDs without prefix)
    const skinIds = {
      'golden', 'rainbow', 'galaxy', 'dragon', 'electric',
      'fire', 'ice', 'shadow', 'neon', 'crystal', 'cosmic',
    };
    if (skinIds.contains(productId)) {
      await unlockSkin(productId);
      return;
    }

    // Cosmetic bundles
    const bundleIds = {
      'starter_pack', 'elemental_pack', 'cosmic_collection',
      'ultimate_collection',
    };
    if (bundleIds.contains(productId)) {
      await unlockBundle(productId);
      return;
    }

    // Tournament entries
    if (productId.contains('tournament')) {
      if (productId.contains('bronze')) {
        await addTournamentEntry('bronze');
      } else if (productId.contains('silver')) {
        await addTournamentEntry('silver');
      } else if (productId.contains('gold')) {
        await addTournamentEntry('gold');
      }
      return;
    }
  }

  void _handlePremiumPurchased() {
    final expiry = DateTime.now().add(const Duration(days: 30));
    emit(state.copyWith(tier: PremiumTier.pro, subscriptionExpiry: expiry));
    _storageService.setPremiumActive(true);
    _storageService.setPremiumExpirationDate(expiry.toIso8601String());
    _coinsCubit?.updatePremiumMultiplier(true, state.hasBattlePass);
  }

  /// Purchase premium subscription (monthly)
  Future<bool> purchasePremium() async {
    try {
      // Purchase the monthly subscription product
      final result = await _purchaseService.purchaseProduct(
        'snake_classic_pro_monthly',
      );
      if (result) {
        _handlePremiumPurchased();
      }
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
  bool isThemeUnlocked(GameTheme theme) => state.isThemeOwned(theme);
  bool isSkinUnlocked(String skinId) => state.isSkinOwned(skinId);
  bool isTrailUnlocked(String trailId) => state.isTrailOwned(trailId);
  bool isPowerUpUnlocked(String powerUpId) =>
      state.isPowerUpUnlocked(powerUpId);
  bool isBoardSizeUnlocked(String boardSizeId) =>
      state.isBoardSizeUnlocked(boardSizeId);
  bool isBundleOwned(String bundleId) => state.isBundleOwned(bundleId);
  bool hasTournamentEntry(String type) => state.hasTournamentEntry(type);

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

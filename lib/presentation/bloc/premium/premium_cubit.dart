import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
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
  StreamSubscription<String>? _purchaseStatusSubscription;

  PremiumCubit({
    required PurchaseService purchaseService,
    required StorageService storageService,
  }) : _purchaseService = purchaseService,
       _storageService = storageService,
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

      emit(
        state.copyWith(
          status: PremiumStatus.ready,
          tier: isPremiumActive ? PremiumTier.pro : PremiumTier.free,
          subscriptionExpiry: expiryDate,
          selectedSkinId: selectedSkinId,
          selectedTrailId: selectedTrailId,
          ownedThemes: _parseThemes(ownedThemes),
          ownedSkins: ownedSkins.toSet(),
          ownedTrails: ownedTrails.toSet(),
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
      }
    });
  }

  void _handlePremiumPurchased() {
    final expiry = DateTime.now().add(const Duration(days: 30));
    emit(state.copyWith(tier: PremiumTier.pro, subscriptionExpiry: expiry));
    _storageService.setPremiumActive(true);
    _storageService.setPremiumExpirationDate(expiry.toIso8601String());
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

    AppLogger.info('Free trial started, ends: ${trialEnd.toIso8601String()}');
  }

  /// End trial
  Future<void> endTrial() async {
    emit(state.copyWith(isOnTrial: false));
    await _storageService.setTrialData(isOnTrial: false);
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

  /// Handle purchase completion from purchase service
  Future<void> handlePurchaseCompletion(String productId) async {
    AppLogger.info('Handling purchase completion: $productId');

    // Handle subscription purchases
    if (productId.contains('pro_monthly') || productId.contains('pro_yearly')) {
      _handlePremiumPurchased();
      return;
    }

    // Handle battle pass
    if (productId.contains('battle_pass')) {
      // Battle pass is handled by BattlePassCubit
      return;
    }

    // Handle tournament entries
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

    // Handle themes, skins, trails, power-ups based on product ID
    // The purchase service will emit the appropriate product ID
    AppLogger.info('Purchase completed for: $productId');
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

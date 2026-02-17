import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import '../utils/logger.dart';
import 'backend_service.dart';

// Product IDs for different categories
// Store IDs use the com.pranta.snakeclassic. prefix for Google Play / App Store.
// Internal IDs (SharedPreferences, database) stay unprefixed for backward compat.
class ProductIds {
  // Store product ID prefix
  static const String prefix = 'com.pranta.snakeclassic.';

  /// Strip the store prefix to get the internal ID.
  static String stripPrefix(String id) {
    if (id.startsWith(prefix)) return id.substring(prefix.length);
    return id;
  }

  /// Add the store prefix to an internal ID.
  static String withPrefix(String id) {
    if (id.startsWith(prefix)) return id;
    return '$prefix$id';
  }

  /// Convert a bare skin name (e.g. 'golden') to its store product ID.
  static String skinStoreId(String skinId) => '${prefix}skin_$skinId';

  // Premium Themes
  static const String crystalTheme = '${prefix}crystal_theme';
  static const String cyberpunkTheme = '${prefix}cyberpunk_theme';
  static const String spaceTheme = '${prefix}space_theme';
  static const String oceanTheme = '${prefix}ocean_theme';
  static const String desertTheme = '${prefix}desert_theme';
  static const String forestTheme = '${prefix}forest_theme';
  static const String themesBundle = '${prefix}premium_themes_bundle';

  // Snake Coins (Consumable)
  static const String coinPackSmall = '${prefix}coin_pack_small';
  static const String coinPackMedium = '${prefix}coin_pack_medium';
  static const String coinPackLarge = '${prefix}coin_pack_large';
  static const String coinPackMega = '${prefix}coin_pack_mega';

  // Snake Skins (store IDs use skin_ category prefix)
  static const String goldenSnake = '${prefix}skin_golden';
  static const String rainbowSnake = '${prefix}skin_rainbow';
  static const String galaxySnake = '${prefix}skin_galaxy';
  static const String dragonSnake = '${prefix}skin_dragon';
  static const String electricSnake = '${prefix}skin_electric';
  static const String fireSnake = '${prefix}skin_fire';
  static const String iceSnake = '${prefix}skin_ice';
  static const String shadowSnake = '${prefix}skin_shadow';
  static const String neonSnake = '${prefix}skin_neon';
  static const String crystalSnake = '${prefix}skin_crystal';
  static const String cosmicSnake = '${prefix}skin_cosmic';

  // Trail Effects
  static const String particleTrail = '${prefix}trail_particle';
  static const String glowTrail = '${prefix}trail_glow';
  static const String rainbowTrail = '${prefix}trail_rainbow';
  static const String fireTrail = '${prefix}trail_fire';
  static const String electricTrail = '${prefix}trail_electric';
  static const String starTrail = '${prefix}trail_star';
  static const String cosmicTrail = '${prefix}trail_cosmic';
  static const String neonTrail = '${prefix}trail_neon';
  static const String shadowTrail = '${prefix}trail_shadow';
  static const String crystalTrail = '${prefix}trail_crystal';
  static const String dragonTrail = '${prefix}trail_dragon';

  // Cosmetic Bundles
  static const String starterCosmetics = '${prefix}starter_pack';
  static const String elementalCosmetics = '${prefix}elemental_pack';
  static const String cosmicCosmetics = '${prefix}cosmic_collection';
  static const String ultimateCosmetics = '${prefix}ultimate_collection';

  // Subscriptions
  static const String snakeClassicProMonthly = '${prefix}pro_monthly';
  static const String snakeClassicProYearly = '${prefix}pro_yearly';

  // Battle Pass — Coming Soon (not registered on stores yet)
  static const String battlePass = '${prefix}battle_pass_season';

  // Tournament Entries (Consumable)
  static const String tournamentBronze = '${prefix}tournament_bronze';
  static const String tournamentSilver = '${prefix}tournament_silver';
  static const String tournamentGold = '${prefix}tournament_gold';
  static const String championshipEntry = '${prefix}championship_entry';
  static const String tournamentVipEntry = '${prefix}tournament_vip_entry';

  /// All active store product IDs (44 products).
  /// Battle Pass and power-up IAPs are excluded.
  static List<String> get allProductIds => [
    // Themes (7)
    crystalTheme, cyberpunkTheme, spaceTheme,
    oceanTheme, desertTheme, forestTheme, themesBundle,
    // Coins (4)
    coinPackSmall, coinPackMedium, coinPackLarge, coinPackMega,
    // Snake skins (11)
    goldenSnake, rainbowSnake, galaxySnake, dragonSnake, electricSnake,
    fireSnake, iceSnake, shadowSnake, neonSnake, crystalSnake, cosmicSnake,
    // Trail effects (11)
    particleTrail, glowTrail, rainbowTrail, fireTrail, electricTrail, starTrail,
    cosmicTrail, neonTrail, shadowTrail, crystalTrail, dragonTrail,
    // Bundles (4)
    starterCosmetics, elementalCosmetics, cosmicCosmetics, ultimateCosmetics,
    // Subscriptions (2)
    snakeClassicProMonthly, snakeClassicProYearly,
    // Tournament entries (5)
    tournamentBronze, tournamentSilver, tournamentGold,
    championshipEntry, tournamentVipEntry,
  ];

  static List<String> get consumableIds => [
    // Coins
    coinPackSmall, coinPackMedium, coinPackLarge, coinPackMega,
    // Tournament entries
    tournamentBronze, tournamentSilver, tournamentGold,
    championshipEntry, tournamentVipEntry,
  ];

  static List<String> get subscriptionIds => [
    snakeClassicProMonthly,
    snakeClassicProYearly,
  ];
}

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  final List<PurchaseDetails> _purchases = [];
  bool _purchasePending = false;
  String? _queryProductError;
  String? Function()? _getUserId;

  // Getters
  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;
  List<PurchaseDetails> get purchases => _purchases;
  bool get purchasePending => _purchasePending;
  String? get queryProductError => _queryProductError;

  // Stream controllers for UI updates
  final StreamController<bool> _purchasePendingController =
      StreamController<bool>.broadcast();
  final StreamController<List<ProductDetails>> _productsController =
      StreamController<List<ProductDetails>>.broadcast();
  final StreamController<String> _purchaseStatusController =
      StreamController<String>.broadcast();

  Stream<bool> get purchasePendingStream => _purchasePendingController.stream;
  Stream<List<ProductDetails>> get productsStream => _productsController.stream;
  Stream<String> get purchaseStatusStream => _purchaseStatusController.stream;

  // Set user ID getter for accessing current user information
  void setUserIdGetter(String? Function() getUserId) {
    _getUserId = getUserId;
  }

  Future<void> initialize() async {
    try {
      AppLogger.info('Initializing Purchase Service...');

      _isAvailable = await _inAppPurchase.isAvailable();
      if (!_isAvailable) {
        AppLogger.error('In-app purchases not available on this device');
        return;
      }

      // iOS delegate setup would go here when needed

      // Listen to purchase updates
      _subscription = _inAppPurchase.purchaseStream.listen(
        _listenToPurchaseUpdated,
        onDone: () => _subscription.cancel(),
        onError: (error) => AppLogger.error('Purchase stream error', error),
      );

      await loadProducts();
      await restorePurchases();

      AppLogger.info('Purchase Service initialized successfully');
    } catch (e) {
      AppLogger.error('Error initializing Purchase Service', e);
    }
  }

  Future<void> loadProducts() async {
    try {
      AppLogger.info('Loading products...');

      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails(ProductIds.allProductIds.toSet());

      if (response.notFoundIDs.isNotEmpty) {
        AppLogger.warning('Products not found: ${response.notFoundIDs}');
      }

      if (response.error != null) {
        _queryProductError = response.error!.message;
        AppLogger.error('Error loading products: ${response.error!.message}');
        return;
      }

      _products = response.productDetails;
      _productsController.add(_products);

      AppLogger.info('Loaded ${_products.length} products successfully');
    } catch (e) {
      AppLogger.error('Error loading products', e);
      _queryProductError = e.toString();
    }
  }

  Future<bool> buyProduct(ProductDetails productDetails) async {
    if (!_isAvailable) {
      _purchaseStatusController.add('In-app purchases not available');
      return false;
    }

    try {
      AppLogger.info('Initiating purchase for: ${productDetails.id}');
      _purchasePending = true;
      _purchasePendingController.add(true);

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      bool success;
      if (ProductIds.consumableIds.contains(productDetails.id)) {
        success = await _inAppPurchase.buyConsumable(
          purchaseParam: purchaseParam,
        );
      } else {
        success = await _inAppPurchase.buyNonConsumable(
          purchaseParam: purchaseParam,
        );
      }

      if (!success) {
        _purchasePending = false;
        _purchasePendingController.add(false);
        _purchaseStatusController.add('Failed to initiate purchase');
      }

      return success;
    } catch (e) {
      AppLogger.error('Error buying product', e);
      _purchasePending = false;
      _purchasePendingController.add(false);
      _purchaseStatusController.add('Purchase failed: ${e.toString()}');
      return false;
    }
  }

  Future<void> _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _purchaseStatusController.add('Purchase pending...');
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          AppLogger.error('Purchase error: ${purchaseDetails.error}');
          _purchaseStatusController.add('Purchase failed');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Verify purchase with backend
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            _purchases.add(purchaseDetails);
            await _deliverProduct(purchaseDetails);
            _purchaseStatusController.add('Purchase successful!');
          } else {
            _purchaseStatusController.add('Purchase verification failed');
          }
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }

        _purchasePending = false;
        _purchasePendingController.add(false);
      }
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    try {
      AppLogger.info('Verifying purchase: ${purchaseDetails.productID}');

      // In production, you should verify purchases with your backend
      // For now, we'll implement a basic verification

      // Send to backend for verification
      final success = await _verifyWithBackend(purchaseDetails);

      if (success) {
        AppLogger.info('Purchase verified successfully');
        return true;
      } else {
        AppLogger.error('Purchase verification failed');
        return false;
      }
    } catch (e) {
      AppLogger.error('Error verifying purchase', e);
      return false;
    }
  }

  Future<bool> _verifyWithBackend(PurchaseDetails purchaseDetails) async {
    try {
      final backendService = BackendService();

      // Extract platform-specific data
      String platform = 'unknown';
      String receiptData = '';
      String? purchaseToken;

      // Platform detection and receipt extraction
      if (purchaseDetails.verificationData.source == 'app_store') {
        platform = 'ios';
        receiptData = purchaseDetails.verificationData.serverVerificationData;
      } else if (purchaseDetails.verificationData.source == 'google_play') {
        platform = 'android';
        receiptData = purchaseDetails.verificationData.serverVerificationData;
        // Extract the real purchase token from GooglePlayPurchaseDetails
        if (Platform.isAndroid && purchaseDetails is GooglePlayPurchaseDetails) {
          purchaseToken =
              purchaseDetails.billingClientPurchase.purchaseToken;
        } else {
          purchaseToken = purchaseDetails.purchaseID;
        }
      }

      // Get current user ID
      String userId = _getUserId?.call() ?? 'anonymous_user';

      final verificationResult = await backendService.verifyPurchase(
        platform: platform,
        receiptData: receiptData,
        productId: purchaseDetails.productID,
        transactionId: purchaseDetails.purchaseID ?? '',
        userId: userId,
        purchaseToken: purchaseToken,
        deviceInfo: {
          'source': purchaseDetails.verificationData.source,
          'local_verification_data':
              purchaseDetails.verificationData.localVerificationData,
        },
      );

      if (verificationResult != null && verificationResult['valid'] == true) {
        AppLogger.info('Purchase verified successfully by backend');

        // Handle premium content unlocking based on backend response
        if (verificationResult['premium_content_unlocked'] != null) {
          await _unlockPremiumContent(
            verificationResult['premium_content_unlocked'],
          );
        }

        return true;
      } else {
        AppLogger.error(
          'Backend verification failed: ${verificationResult?['error_message'] ?? 'Unknown error'}',
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Error verifying purchase with backend', e);
      return false; // Fail securely - don't unlock content if verification fails
    }
  }

  Future<void> _unlockPremiumContent(List<dynamic> contentList) async {
    try {
      AppLogger.info('Unlocking premium content: ${contentList.join(', ')}');

      // Trigger a premium content sync with the backend
      final userId = _getUserId?.call();
      if (userId != null) {
        final backendService = BackendService();
        await backendService.syncPremiumStatus(userId: userId);
      }

      // Content will be applied when PremiumCubit syncs with backend
      AppLogger.info('Premium content unlock initiated');
    } catch (e) {
      AppLogger.error('Error unlocking premium content', e);
    }
  }

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    try {
      AppLogger.info('Delivering product: ${purchaseDetails.productID}');

      // Get PremiumCubit from the context if available
      // This would normally be passed through dependency injection
      // For now, we'll handle the logic here and the provider will sync later

      switch (purchaseDetails.productID) {
        // Premium Themes
        case ProductIds.crystalTheme:
        case ProductIds.cyberpunkTheme:
        case ProductIds.spaceTheme:
        case ProductIds.oceanTheme:
        case ProductIds.desertTheme:
        case ProductIds.forestTheme:
        case ProductIds.themesBundle:
          await _unlockPremiumTheme(purchaseDetails.productID);
          break;

        // Coins (Consumable)
        case ProductIds.coinPackSmall:
        case ProductIds.coinPackMedium:
        case ProductIds.coinPackLarge:
        case ProductIds.coinPackMega:
          await _addCoins(purchaseDetails.productID);
          break;

        // Snake Skins
        case ProductIds.goldenSnake:
        case ProductIds.rainbowSnake:
        case ProductIds.galaxySnake:
        case ProductIds.dragonSnake:
        case ProductIds.electricSnake:
        case ProductIds.fireSnake:
        case ProductIds.iceSnake:
        case ProductIds.shadowSnake:
        case ProductIds.neonSnake:
        case ProductIds.crystalSnake:
        case ProductIds.cosmicSnake:
          await _unlockCosmetics(purchaseDetails.productID);
          break;

        // Trail Effects
        case ProductIds.particleTrail:
        case ProductIds.glowTrail:
        case ProductIds.rainbowTrail:
        case ProductIds.fireTrail:
        case ProductIds.electricTrail:
        case ProductIds.starTrail:
        case ProductIds.cosmicTrail:
        case ProductIds.neonTrail:
        case ProductIds.shadowTrail:
        case ProductIds.crystalTrail:
        case ProductIds.dragonTrail:
          await _unlockTrail(purchaseDetails.productID);
          break;

        // Cosmetic Bundles
        case ProductIds.starterCosmetics:
        case ProductIds.elementalCosmetics:
        case ProductIds.cosmicCosmetics:
        case ProductIds.ultimateCosmetics:
          await _unlockCosmetics(purchaseDetails.productID);
          break;

        // Subscriptions
        case ProductIds.snakeClassicProMonthly:
        case ProductIds.snakeClassicProYearly:
          await _activateSubscription(purchaseDetails.productID);
          break;

        // Tournament Entries
        case ProductIds.tournamentBronze:
        case ProductIds.tournamentSilver:
        case ProductIds.tournamentGold:
        case ProductIds.championshipEntry:
        case ProductIds.tournamentVipEntry:
          await _addTournamentEntry(purchaseDetails.productID);
          break;
      }

      // Broadcast purchase completion event for PremiumCubit to handle
      _purchaseStatusController.add(
        'purchase_completed:${purchaseDetails.productID}',
      );

      AppLogger.info('Product delivered successfully');
    } catch (e) {
      AppLogger.error('Error delivering product', e);
    }
  }

  Future<void> _unlockPremiumTheme(String productId) async {
    AppLogger.info('Unlocking premium theme: $productId');
    // The actual unlocking is handled by PremiumCubit via purchase completion event
    // This method exists for future backend synchronization if needed
  }

  Future<void> _addCoins(String productId) async {
    AppLogger.info('Adding coins: $productId');
    // The actual coin addition is handled by PremiumCubit via purchase completion event
    // This method exists for future backend synchronization if needed
  }

  Future<void> _unlockCosmetics(String productId) async {
    AppLogger.info('Unlocking cosmetics: $productId');
    // The actual unlocking is handled by PremiumCubit via purchase completion event
    // This method exists for future backend synchronization if needed
  }

  Future<void> _unlockTrail(String productId) async {
    AppLogger.info('Unlocking trail effect: $productId');
    // The actual unlocking is handled by PremiumCubit via purchase completion event
    // This method exists for future backend synchronization if needed
  }

  Future<void> _activateSubscription(String productId) async {
    AppLogger.info('Activating subscription: $productId');
    // The actual activation is handled by PremiumCubit via purchase completion event
    // This method exists for future backend synchronization if needed
  }

  Future<void> _addTournamentEntry(String productId) async {
    AppLogger.info('Adding tournament entry: $productId');
    // The actual entry addition is handled by PremiumCubit via purchase completion event
    // This method exists for future backend synchronization if needed
  }

  Future<void> restorePurchases() async {
    try {
      AppLogger.info('Restoring purchases...');

      // First, restore with the platform store
      await _inAppPurchase.restorePurchases();

      // Then sync with backend to ensure premium status is up to date
      final userId = _getUserId?.call();
      if (userId != null) {
        final backendService = BackendService();
        final syncSuccess = await backendService.syncPremiumStatus(
          userId: userId,
        );
        if (syncSuccess) {
          AppLogger.info('Premium status synced with backend during restore');
        }
      }

      AppLogger.info('Purchases restored successfully');
    } catch (e) {
      AppLogger.error('Error restoring purchases', e);
      _purchaseStatusController.add('Failed to restore purchases');
    }
  }

  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Get the store-formatted price for a product (e.g. "$1.99").
  /// Returns null if the product hasn't been loaded from the store.
  String? getStorePrice(String productId) {
    return getProduct(productId)?.price;
  }

  /// Get the store price, falling back to a formatted default.
  String getStorePriceOrDefault(String productId, double fallbackPrice) {
    return getProduct(productId)?.price ??
        '\$${fallbackPrice.toStringAsFixed(2)}';
  }

  Future<bool> purchaseProduct(String productId) async {
    final product = getProduct(productId);
    if (product == null) {
      throw Exception('Product $productId not found');
    }
    return await buyProduct(product);
  }

  bool isPurchased(String productId) {
    return _purchases.any(
      (purchase) =>
          purchase.productID == productId &&
          purchase.status == PurchaseStatus.purchased,
    );
  }

  bool hasActiveSubscription(String subscriptionId) {
    final purchase = _purchases
        .where((p) => p.productID == subscriptionId)
        .firstOrNull;
    if (purchase == null) return false;

    // For subscriptions, check if still active
    // This would need to be verified with the app store
    return purchase.status == PurchaseStatus.purchased;
  }

  void dispose() {
    _subscription.cancel();
    _purchasePendingController.close();
    _productsController.close();
    _purchaseStatusController.close();
  }
}

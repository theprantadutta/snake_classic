import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../utils/logger.dart';

// Product IDs for different categories
class ProductIds {
  // Premium Themes
  static const String crystalTheme = 'crystal_theme';
  static const String cyberpunkTheme = 'cyberpunk_theme';
  static const String spaceTheme = 'space_theme';
  static const String oceanTheme = 'ocean_theme';
  static const String desertTheme = 'desert_theme';
  static const String themesBundle = 'premium_themes_bundle';

  // Premium Power-ups
  static const String megaPowerups = 'mega_powerups';
  static const String exclusivePowerups = 'exclusive_powerups';
  static const String powerupsBundle = 'powerups_bundle';

  // Snake Cosmetics
  static const String goldenSnake = 'golden_snake';
  static const String rainbowSnake = 'rainbow_snake';
  static const String galaxySnake = 'galaxy_snake';
  static const String dragonSnake = 'dragon_snake';
  static const String premiumTrails = 'premium_trails';
  static const String cosmeticsBundle = 'cosmetics_bundle';

  // Subscriptions
  static const String snakeClassicPro = 'snake_classic_pro';
  static const String battlePass = 'battle_pass_season';

  // Tournament Entries
  static const String tournamentBronze = 'tournament_bronze';
  static const String tournamentSilver = 'tournament_silver';
  static const String tournamentGold = 'tournament_gold';
  static const String championshipEntry = 'championship_entry';

  static List<String> get allProductIds => [
    crystalTheme, cyberpunkTheme, spaceTheme, oceanTheme, desertTheme, themesBundle,
    megaPowerups, exclusivePowerups, powerupsBundle,
    goldenSnake, rainbowSnake, galaxySnake, dragonSnake, premiumTrails, cosmeticsBundle,
    snakeClassicPro, battlePass,
    tournamentBronze, tournamentSilver, tournamentGold, championshipEntry,
  ];

  static List<String> get consumableIds => [
    tournamentBronze, tournamentSilver, tournamentGold, championshipEntry,
  ];

  static List<String> get subscriptionIds => [
    snakeClassicPro, battlePass,
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

  // Getters
  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;
  List<PurchaseDetails> get purchases => _purchases;
  bool get purchasePending => _purchasePending;
  String? get queryProductError => _queryProductError;

  // Stream controllers for UI updates
  final StreamController<bool> _purchasePendingController = StreamController<bool>.broadcast();
  final StreamController<List<ProductDetails>> _productsController = StreamController<List<ProductDetails>>.broadcast();
  final StreamController<String> _purchaseStatusController = StreamController<String>.broadcast();

  Stream<bool> get purchasePendingStream => _purchasePendingController.stream;
  Stream<List<ProductDetails>> get productsStream => _productsController.stream;
  Stream<String> get purchaseStatusStream => _purchaseStatusController.stream;

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
      
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(
        ProductIds.allProductIds.toSet(),
      );

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

      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);

      bool success;
      if (ProductIds.consumableIds.contains(productDetails.id)) {
        success = await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      } else {
        success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
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

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
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
    // This would be implemented with your Python backend
    // For now, return true for testing
    // TODO: Implement actual backend verification
    return true;
  }

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    try {
      AppLogger.info('Delivering product: ${purchaseDetails.productID}');
      
      // Get PremiumProvider from the context if available
      // This would normally be passed through dependency injection
      // For now, we'll handle the logic here and the provider will sync later
      
      switch (purchaseDetails.productID) {
        // Premium Themes
        case ProductIds.crystalTheme:
        case ProductIds.cyberpunkTheme:
        case ProductIds.spaceTheme:
        case ProductIds.oceanTheme:
        case ProductIds.desertTheme:
        case ProductIds.themesBundle:
          await _unlockPremiumTheme(purchaseDetails.productID);
          break;
          
        // Power-ups
        case ProductIds.megaPowerups:
        case ProductIds.exclusivePowerups:
        case ProductIds.powerupsBundle:
          await _unlockPowerups(purchaseDetails.productID);
          break;
          
        // Cosmetics
        case ProductIds.goldenSnake:
        case ProductIds.rainbowSnake:
        case ProductIds.galaxySnake:
        case ProductIds.dragonSnake:
        case ProductIds.premiumTrails:
        case ProductIds.cosmeticsBundle:
          await _unlockCosmetics(purchaseDetails.productID);
          break;
          
        // Subscriptions
        case ProductIds.snakeClassicPro:
        case ProductIds.battlePass:
          await _activateSubscription(purchaseDetails.productID);
          break;
          
        // Tournament Entries
        case ProductIds.tournamentBronze:
        case ProductIds.tournamentSilver:
        case ProductIds.tournamentGold:
        case ProductIds.championshipEntry:
          await _addTournamentEntry(purchaseDetails.productID);
          break;
      }
      
      // Broadcast purchase completion event for PremiumProvider to handle
      _purchaseStatusController.add('purchase_completed:${purchaseDetails.productID}');
      
      AppLogger.info('Product delivered successfully');
    } catch (e) {
      AppLogger.error('Error delivering product', e);
    }
  }

  Future<void> _unlockPremiumTheme(String productId) async {
    AppLogger.info('Unlocking premium theme: $productId');
    // The actual unlocking is handled by PremiumProvider via purchase completion event
    // This method exists for future backend synchronization if needed
  }

  Future<void> _unlockPowerups(String productId) async {
    AppLogger.info('Unlocking powerups: $productId');
    // The actual unlocking is handled by PremiumProvider via purchase completion event
    // This method exists for future backend synchronization if needed
  }

  Future<void> _unlockCosmetics(String productId) async {
    AppLogger.info('Unlocking cosmetics: $productId');
    // The actual unlocking is handled by PremiumProvider via purchase completion event
    // This method exists for future backend synchronization if needed
  }

  Future<void> _activateSubscription(String productId) async {
    AppLogger.info('Activating subscription: $productId');
    // The actual activation is handled by PremiumProvider via purchase completion event
    // This method exists for future backend synchronization if needed
  }

  Future<void> _addTournamentEntry(String productId) async {
    AppLogger.info('Adding tournament entry: $productId');
    // The actual entry addition is handled by PremiumProvider via purchase completion event
    // This method exists for future backend synchronization if needed
  }

  Future<void> restorePurchases() async {
    try {
      AppLogger.info('Restoring purchases...');
      await _inAppPurchase.restorePurchases();
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

  bool isPurchased(String productId) {
    return _purchases.any((purchase) => 
      purchase.productID == productId && 
      purchase.status == PurchaseStatus.purchased
    );
  }

  bool hasActiveSubscription(String subscriptionId) {
    final purchase = _purchases.where((p) => p.productID == subscriptionId).firstOrNull;
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


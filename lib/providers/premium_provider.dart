import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/purchase_service.dart';
import '../services/preferences_service.dart';
import '../services/storage_service.dart';
import '../providers/coins_provider.dart';
import '../models/premium_power_up.dart';
import '../models/premium_cosmetics.dart';
import '../models/snake_coins.dart';
import '../utils/logger.dart';
import '../utils/constants.dart';

enum PremiumTier {
  free,
  pro,
}

class PremiumContent {
  // Premium Themes
  static const Set<GameTheme> premiumThemes = {
    GameTheme.crystal,
    GameTheme.cyberpunk,
    GameTheme.space,
    GameTheme.ocean,
    GameTheme.desert,
  };

  // Premium Power-ups
  static const Set<String> premiumPowerUps = {
    'mega_speed_boost',
    'mega_invincibility', 
    'mega_score_multiplier',
    'mega_slow_motion',
    'teleport',
    'size_reducer',
    'score_shield',
    'combo_multiplier',
  };

  // Premium Snake Skins
  static const Set<String> premiumSkins = {
    'golden',
    'rainbow',
    'galaxy',
    'dragon',
    'electric',
    'fire',
    'ice',
    'shadow',
    'neon',
    'crystal',
    'cosmic',
  };

  // Premium Trails
  static const Set<String> premiumTrails = {
    'particle',
    'glow',
    'rainbow',
    'fire',
    'electric',
    'star',
    'cosmic',
    'neon',
    'shadow',
    'crystal',
    'dragon',
  };

  // Premium Board Sizes (larger boards)
  static const Set<String> premiumBoardSizes = {
    'epic_35x35',
    'massive_40x40',
    'ultimate_50x50',
  };
}

class PremiumProvider extends ChangeNotifier {
  final PurchaseService _purchaseService;
  PreferencesService? _preferencesService;
  final StorageService _storageService = StorageService();
  StreamSubscription<String>? _purchaseStatusSubscription;
  
  PremiumTier _currentTier = PremiumTier.free;
  DateTime? _subscriptionExpiry;
  bool _isInitialized = false;

  // Owned content
  final Set<GameTheme> _ownedThemes = {};
  final Set<String> _ownedPowerUps = {};
  final Set<String> _ownedSkins = {};
  final Set<String> _ownedTrails = {};
  final Set<String> _ownedBoardSizes = {};
  final Set<String> _ownedBundles = {};
  
  // Selected cosmetics
  String _selectedSkinId = 'classic';
  String _selectedTrailId = 'none';
  
  // Battle Pass
  bool _hasBattlePass = false;
  int _battlePassTier = 0;
  int _battlePassXP = 0;
  DateTime? _battlePassExpiry;

  // Premium Trial
  bool _isOnTrial = false;
  DateTime? _trialStartDate;
  DateTime? _trialEndDate;
  static const Duration trialDuration = Duration(days: 3);

  // Tournament entries
  int _bronzeTournamentEntries = 0;
  int _silverTournamentEntries = 0;
  int _goldTournamentEntries = 0;
  int _championshipEntries = 0;

  PremiumProvider(this._purchaseService);

  // Getters
  PremiumTier get currentTier => _currentTier;
  DateTime? get subscriptionExpiry => _subscriptionExpiry;
  bool get isInitialized => _isInitialized;
  bool get hasPremium => (_currentTier == PremiumTier.pro && !isSubscriptionExpired) || (_isOnTrial && !isTrialExpired);
  bool get hasBattlePass => _hasBattlePass && !isBattlePassExpired;
  int get battlePassTier => _battlePassTier;
  int get battlePassXP => _battlePassXP;
  
  // Cosmetics getters
  String get selectedSkinId => _selectedSkinId;
  String get selectedTrailId => _selectedTrailId;

  // Purchase history accessor
  Future<List<String>> getPurchaseHistory() async {
    return await _storageService.getPurchaseHistory();
  }
  
  // Trial getters
  bool get isOnTrial => _isOnTrial && !isTrialExpired;
  DateTime? get trialStartDate => _trialStartDate;
  DateTime? get trialEndDate => _trialEndDate;
  bool get hasUsedTrial => _trialStartDate != null;
  
  bool get isTrialExpired {
    if (_trialEndDate == null) return true;
    return DateTime.now().isAfter(_trialEndDate!);
  }
  
  Duration? get trialTimeRemaining {
    if (!_isOnTrial || _trialEndDate == null) return null;
    final remaining = _trialEndDate!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }
  
  Set<GameTheme> get ownedThemes => _ownedThemes;
  Set<String> get ownedPowerUps => _ownedPowerUps;
  Set<String> get ownedSkins => _ownedSkins;
  Set<String> get ownedTrails => _ownedTrails;
  Set<String> get ownedBoardSizes => _ownedBoardSizes;

  int get bronzeTournamentEntries => _bronzeTournamentEntries;
  int get silverTournamentEntries => _silverTournamentEntries;
  int get goldTournamentEntries => _goldTournamentEntries;
  int get championshipEntries => _championshipEntries;

  bool get isSubscriptionExpired {
    if (_subscriptionExpiry == null) return true;
    return DateTime.now().isAfter(_subscriptionExpiry!);
  }

  bool get isBattlePassExpired {
    if (_battlePassExpiry == null) return true;
    return DateTime.now().isAfter(_battlePassExpiry!);
  }

  Future<void> initialize([BuildContext? context]) async {
    try {
      AppLogger.info('Initializing Premium Provider...');
      
      if (context != null && _preferencesService == null) {
        _preferencesService = Provider.of<PreferencesService>(context, listen: false);
      }
      
      await _loadPremiumStatus();
      await _syncWithPurchaseService();
      
      // Update coins provider with premium multipliers
      _updateCoinsMultiplier();
      
      // Listen to purchase status updates
      _purchaseStatusSubscription = _purchaseService.purchaseStatusStream.listen((status) {
        if (status.startsWith('purchase_completed:')) {
          final productId = status.substring('purchase_completed:'.length);
          handlePurchaseCompletion(productId);
        }
      });
      
      _isInitialized = true;
      notifyListeners();
      
      AppLogger.info('Premium Provider initialized successfully');
    } catch (e) {
      AppLogger.error('Error initializing Premium Provider', e);
    }
  }

  void _updateCoinsMultiplier() {
    try {
      final coinsProvider = CoinsProvider();
      coinsProvider.updatePremiumMultiplier(hasPremium, hasBattlePass);
    } catch (e) {
      AppLogger.error('Error updating coins multiplier', e);
    }
  }

  Future<void> _loadPremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load premium tier
      final tierIndex = prefs.getInt('premium_tier') ?? 0;
      _currentTier = PremiumTier.values[tierIndex];
      
      // Load subscription expiry
      final expiryString = prefs.getString('subscription_expiry');
      if (expiryString != null) {
        _subscriptionExpiry = DateTime.parse(expiryString);
      }
      
      // Load owned themes
      final themesData = prefs.getStringList('owned_themes') ?? [];
      _ownedThemes.clear();
      for (final themeStr in themesData) {
        try {
          final theme = GameTheme.values.firstWhere((t) => t.name == themeStr);
          _ownedThemes.add(theme);
        } catch (e) {
          // Theme not found, skip
        }
      }
      
      // Load owned power-ups
      _ownedPowerUps.clear();
      _ownedPowerUps.addAll(prefs.getStringList('owned_powerups') ?? []);
      
      // Load owned skins
      _ownedSkins.clear();
      _ownedSkins.addAll(prefs.getStringList('owned_skins') ?? []);
      
      // Load owned trails
      _ownedTrails.clear();
      _ownedTrails.addAll(prefs.getStringList('owned_trails') ?? []);
      
      // Load owned board sizes
      _ownedBoardSizes.clear();
      _ownedBoardSizes.addAll(prefs.getStringList('owned_board_sizes') ?? []);
      
      // Load owned bundles
      _ownedBundles.clear();
      _ownedBundles.addAll(prefs.getStringList('owned_bundles') ?? []);
      
      // Load selected cosmetics
      _selectedSkinId = prefs.getString('selected_skin_id') ?? 'classic';
      _selectedTrailId = prefs.getString('selected_trail_id') ?? 'none';
      
      // Load battle pass status
      _hasBattlePass = prefs.getBool('has_battle_pass') ?? false;
      _battlePassTier = prefs.getInt('battle_pass_tier') ?? 0;
      _battlePassXP = prefs.getInt('battle_pass_xp') ?? 0;
      
      final battlePassExpiryString = prefs.getString('battle_pass_expiry');
      if (battlePassExpiryString != null) {
        _battlePassExpiry = DateTime.parse(battlePassExpiryString);
      }
      
      // Load tournament entries
      _bronzeTournamentEntries = prefs.getInt('bronze_tournament_entries') ?? 0;
      _silverTournamentEntries = prefs.getInt('silver_tournament_entries') ?? 0;
      _goldTournamentEntries = prefs.getInt('gold_tournament_entries') ?? 0;
      _championshipEntries = prefs.getInt('championship_entries') ?? 0;
      
      // Load trial data
      _isOnTrial = prefs.getBool('is_on_trial') ?? false;
      final trialStartString = prefs.getString('trial_start_date');
      if (trialStartString != null) {
        _trialStartDate = DateTime.parse(trialStartString);
      }
      final trialEndString = prefs.getString('trial_end_date');
      if (trialEndString != null) {
        _trialEndDate = DateTime.parse(trialEndString);
      }
      
      AppLogger.info('Premium status loaded successfully');
    } catch (e) {
      AppLogger.error('Error loading premium status', e);
    }
  }

  Future<void> _syncWithPurchaseService() async {
    try {
      // Check if user has active subscriptions
      if (_purchaseService.hasActiveSubscription(ProductIds.snakeClassicProMonthly) ||
          _purchaseService.hasActiveSubscription(ProductIds.snakeClassicProYearly)) {
        await _activatePremium(PremiumTier.pro);
      }
      
      if (_purchaseService.hasActiveSubscription(ProductIds.battlePass)) {
        await _activateBattlePass();
      }
      
      // Check individual purchases
      await _syncIndividualPurchases();
      
      AppLogger.info('Synced with Purchase Service successfully');
    } catch (e) {
      AppLogger.error('Error syncing with Purchase Service', e);
    }
  }

  Future<void> _syncIndividualPurchases() async {
    // Check theme purchases
    final themeProducts = [
      ProductIds.crystalTheme,
      ProductIds.cyberpunkTheme,
      ProductIds.spaceTheme,
      ProductIds.oceanTheme,
      ProductIds.desertTheme,
    ];
    
    for (final productId in themeProducts) {
      if (_purchaseService.isPurchased(productId)) {
        await _unlockThemeFromProduct(productId);
      }
    }
    
    // Check bundle purchases
    if (_purchaseService.isPurchased(ProductIds.themesBundle)) {
      await _unlockAllPremiumThemes();
    }
    
    if (_purchaseService.isPurchased(ProductIds.premiumPowerupsBundle)) {
      await _unlockAllPremiumPowerUps();
    }
    
    if (_purchaseService.isPurchased(ProductIds.ultimateCosmetics)) {
      await _unlockAllPremiumCosmetics();
    }
  }

  // Theme management
  bool isThemeUnlocked(GameTheme theme) {
    if (!PremiumContent.premiumThemes.contains(theme)) {
      return true; // Free themes are always unlocked
    }
    
    if (hasPremium) {
      return true; // Premium subscribers get all themes
    }
    
    return _ownedThemes.contains(theme);
  }

  Future<void> unlockTheme(GameTheme theme) async {
    if (!_ownedThemes.contains(theme)) {
      _ownedThemes.add(theme);
      
      // Record the purchase if it's a premium theme
      if (PremiumContent.premiumThemes.contains(theme)) {
        await _recordPurchase(
          type: 'theme',
          itemId: theme.name,
          itemName: '${theme.name.toUpperCase()} Theme',
          price: 199, // $1.99 in cents
          currency: 'USD',
        );
      }
      
      await _savePremiumStatus();
      notifyListeners();
      AppLogger.info('Theme unlocked: ${theme.name}');
    }
  }

  Future<void> _unlockThemeFromProduct(String productId) async {
    GameTheme? theme;
    switch (productId) {
      case ProductIds.crystalTheme:
        theme = GameTheme.crystal;
        break;
      case ProductIds.cyberpunkTheme:
        theme = GameTheme.cyberpunk;
        break;
      case ProductIds.spaceTheme:
        theme = GameTheme.space;
        break;
      case ProductIds.oceanTheme:
        theme = GameTheme.ocean;
        break;
      case ProductIds.desertTheme:
        theme = GameTheme.desert;
        break;
    }
    
    if (theme != null) {
      await unlockTheme(theme);
    }
  }

  Future<void> _unlockAllPremiumThemes() async {
    for (final theme in PremiumContent.premiumThemes) {
      await unlockTheme(theme);
    }
  }

  // Power-up management
  bool isPowerUpUnlocked(String powerUpId) {
    if (!PremiumContent.premiumPowerUps.contains(powerUpId)) {
      return true; // Free power-ups are always unlocked
    }
    
    if (hasPremium) {
      return true; // Premium subscribers get all power-ups
    }
    
    return _ownedPowerUps.contains(powerUpId);
  }

  Future<void> unlockPowerUp(String powerUpId) async {
    if (!_ownedPowerUps.contains(powerUpId)) {
      _ownedPowerUps.add(powerUpId);
      await _savePremiumStatus();
      notifyListeners();
      AppLogger.info('Power-up unlocked: $powerUpId');
    }
  }

  Future<void> _unlockAllPremiumPowerUps() async {
    for (final powerUp in PremiumContent.premiumPowerUps) {
      await unlockPowerUp(powerUp);
    }
  }

  // Cosmetics management
  bool isSkinUnlocked(String skinId) {
    if (!PremiumContent.premiumSkins.contains(skinId)) {
      return true;
    }
    
    if (hasPremium) {
      return true;
    }
    
    return _ownedSkins.contains(skinId);
  }

  bool isTrailUnlocked(String trailId) {
    if (!PremiumContent.premiumTrails.contains(trailId)) {
      return true;
    }
    
    if (hasPremium) {
      return true;
    }
    
    return _ownedTrails.contains(trailId);
  }

  Future<void> unlockSkin(String skinId) async {
    if (!_ownedSkins.contains(skinId)) {
      _ownedSkins.add(skinId);
      
      // Record the purchase if it's a premium skin
      if (PremiumContent.premiumSkins.contains(skinId)) {
        try {
          final skinType = SnakeSkinType.values.firstWhere((s) => s.id == skinId);
          await _recordPurchase(
            type: 'skin',
            itemId: skinId,
            itemName: skinType.displayName,
            price: (skinType.price * 100).round(), // Convert to cents
            currency: 'USD',
          );
        } catch (e) {
          AppLogger.error('Error recording skin purchase', e);
        }
      }
      
      await _savePremiumStatus();
      notifyListeners();
      AppLogger.info('Skin unlocked: $skinId');
    }
  }

  Future<void> unlockTrail(String trailId) async {
    if (!_ownedTrails.contains(trailId)) {
      _ownedTrails.add(trailId);
      
      // Record the purchase if it's a premium trail
      if (PremiumContent.premiumTrails.contains(trailId)) {
        try {
          final trailType = TrailEffectType.values.firstWhere((t) => t.id == trailId);
          await _recordPurchase(
            type: 'trail',
            itemId: trailId,
            itemName: trailType.displayName,
            price: (trailType.price * 100).round(), // Convert to cents
            currency: 'USD',
          );
        } catch (e) {
          AppLogger.error('Error recording trail purchase', e);
        }
      }
      
      await _savePremiumStatus();
      notifyListeners();
      AppLogger.info('Trail unlocked: $trailId');
    }
  }

  Future<void> _unlockAllPremiumCosmetics() async {
    for (final skin in PremiumContent.premiumSkins) {
      await unlockSkin(skin);
    }
    for (final trail in PremiumContent.premiumTrails) {
      await unlockTrail(trail);
    }
  }

  // Bundle Management
  bool isBundleOwned(String bundleId) {
    return _ownedBundles.contains(bundleId);
  }

  Future<void> unlockBundle(String bundleId) async {
    if (!_ownedBundles.contains(bundleId)) {
      _ownedBundles.add(bundleId);
      
      // Also unlock all power-ups in the bundle
      final bundle = _getBundleById(bundleId);
      if (bundle != null) {
        for (final powerUp in bundle.powerUps) {
          await unlockPowerUp(powerUp.id);
        }
        
        // Record the purchase
        await _recordPurchase(
          type: 'bundle',
          itemId: bundleId,
          itemName: bundle.name,
          price: bundle.bundlePrice.round(),
          currency: 'coins',
        );
      }
      
      await _savePremiumStatus();
      notifyListeners();
      AppLogger.info('Bundle unlocked: $bundleId');
    }
  }

  PowerUpBundle? _getBundleById(String bundleId) {
    try {
      return PowerUpBundle.availableBundles.firstWhere((bundle) => bundle.id == bundleId);
    } catch (e) {
      return null;
    }
  }
  
  // Cosmetic selection methods
  Future<void> selectSkin(String skinId) async {
    if (isSkinUnlocked(skinId)) {
      _selectedSkinId = skinId;
      await _savePremiumStatus();
      notifyListeners();
      AppLogger.info('Skin selected: $skinId');
    }
  }
  
  Future<void> selectTrail(String trailId) async {
    if (isTrailUnlocked(trailId)) {
      _selectedTrailId = trailId;
      await _savePremiumStatus();
      notifyListeners();
      AppLogger.info('Trail selected: $trailId');
    }
  }

  // Subscription management
  Future<void> _activatePremium(PremiumTier tier, [Duration? duration]) async {
    _currentTier = tier;
    if (duration != null) {
      _subscriptionExpiry = DateTime.now().add(duration);
    } else {
      // Default to 1 month for pro subscription
      _subscriptionExpiry = DateTime.now().add(const Duration(days: 30));
    }
    
    await _savePremiumStatus();
    notifyListeners();
    AppLogger.info('Premium activated: ${tier.name}');
  }

  Future<void> _activateBattlePass([Duration? duration]) async {
    _hasBattlePass = true;
    if (duration != null) {
      _battlePassExpiry = DateTime.now().add(duration);
    } else {
      // Default to 60 days for battle pass
      _battlePassExpiry = DateTime.now().add(const Duration(days: 60));
    }
    
    await _savePremiumStatus();
    notifyListeners();
    AppLogger.info('Battle Pass activated');
  }

  // Battle Pass management
  Future<void> addBattlePassXP(int xp) async {
    if (!hasBattlePass) return;
    
    // Apply premium multiplier for XP
    final multiplier = hasPremium ? 1.25 : 1.0; // 25% bonus for premium users
    final finalXP = (xp * multiplier).round();
    
    _battlePassXP += finalXP;
    
    // Calculate tier progression (100 XP per tier)
    final newTier = (_battlePassXP / 100).floor();
    if (newTier > _battlePassTier) {
      // final oldTier = _battlePassTier;
      _battlePassTier = newTier.clamp(0, 100); // Max 100 tiers
      
      AppLogger.info('Battle Pass tier increased to: $_battlePassTier');
    }
    
    await _savePremiumStatus();
    notifyListeners();
  }

  // Tournament entries management
  bool hasTournamentEntry(String tournamentType) {
    switch (tournamentType.toLowerCase()) {
      case 'bronze':
        return _bronzeTournamentEntries > 0;
      case 'silver':
        return _silverTournamentEntries > 0;
      case 'gold':
        return _goldTournamentEntries > 0;
      case 'championship':
        return _championshipEntries > 0;
      default:
        return false;
    }
  }

  Future<void> addTournamentEntry(String tournamentType, [int count = 1]) async {
    switch (tournamentType.toLowerCase()) {
      case 'bronze':
        _bronzeTournamentEntries += count;
        break;
      case 'silver':
        _silverTournamentEntries += count;
        break;
      case 'gold':
        _goldTournamentEntries += count;
        break;
      case 'championship':
        _championshipEntries += count;
        break;
    }
    
    await _savePremiumStatus();
    notifyListeners();
    AppLogger.info('Added $count $tournamentType tournament entries');
  }

  Future<void> useTournamentEntry(String tournamentType) async {
    switch (tournamentType.toLowerCase()) {
      case 'bronze':
        if (_bronzeTournamentEntries > 0) _bronzeTournamentEntries--;
        break;
      case 'silver':
        if (_silverTournamentEntries > 0) _silverTournamentEntries--;
        break;
      case 'gold':
        if (_goldTournamentEntries > 0) _goldTournamentEntries--;
        break;
      case 'championship':
        if (_championshipEntries > 0) _championshipEntries--;
        break;
    }
    
    await _savePremiumStatus();
    notifyListeners();
  }

  Future<void> _savePremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setInt('premium_tier', _currentTier.index);
      if (_subscriptionExpiry != null) {
        await prefs.setString('subscription_expiry', _subscriptionExpiry!.toIso8601String());
      }
      
      // Save owned content
      await prefs.setStringList('owned_themes', _ownedThemes.map((t) => t.name).toList());
      await prefs.setStringList('owned_powerups', _ownedPowerUps.toList());
      await prefs.setStringList('owned_skins', _ownedSkins.toList());
      await prefs.setStringList('owned_trails', _ownedTrails.toList());
      await prefs.setStringList('owned_board_sizes', _ownedBoardSizes.toList());
      await prefs.setStringList('owned_bundles', _ownedBundles.toList());
      
      // Save selected cosmetics
      await prefs.setString('selected_skin_id', _selectedSkinId);
      await prefs.setString('selected_trail_id', _selectedTrailId);
      
      // Save battle pass
      await prefs.setBool('has_battle_pass', _hasBattlePass);
      await prefs.setInt('battle_pass_tier', _battlePassTier);
      await prefs.setInt('battle_pass_xp', _battlePassXP);
      if (_battlePassExpiry != null) {
        await prefs.setString('battle_pass_expiry', _battlePassExpiry!.toIso8601String());
      }
      
      // Save tournament entries
      await prefs.setInt('bronze_tournament_entries', _bronzeTournamentEntries);
      await prefs.setInt('silver_tournament_entries', _silverTournamentEntries);
      await prefs.setInt('gold_tournament_entries', _goldTournamentEntries);
      await prefs.setInt('championship_entries', _championshipEntries);
      
      // Save trial data
      await prefs.setBool('is_on_trial', _isOnTrial);
      if (_trialStartDate != null) {
        await prefs.setString('trial_start_date', _trialStartDate!.toIso8601String());
      }
      if (_trialEndDate != null) {
        await prefs.setString('trial_end_date', _trialEndDate!.toIso8601String());
      }
      
    } catch (e) {
      AppLogger.error('Error saving premium status', e);
    }
  }

  Future<void> _recordPurchase({
    required String type,
    required String itemId,
    required String itemName,
    required int price,
    String? currency = 'USD',
  }) async {
    try {
      final purchase = {
        'type': type,
        'itemId': itemId,
        'itemName': itemName,
        'price': price,
        'currency': currency,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      final purchaseJson = purchase.entries
          .map((e) => '"${e.key}":"${e.value}"')
          .join(',');
      await _storageService.addPurchaseToHistory('{$purchaseJson}');
      
      AppLogger.info('Purchase recorded: $itemName (\$${price / 100})');
    } catch (e) {
      AppLogger.error('Error recording purchase history', e);
    }
  }

  Future<void> _recordProductPurchase(String productId) async {
    try {
      final productInfo = _getProductInfo(productId);
      await _recordPurchase(
        type: productInfo['type'] as String,
        itemId: productId,
        itemName: productInfo['name'] as String,
        price: productInfo['price'] as int,
        currency: productInfo['currency'] as String,
      );
    } catch (e) {
      AppLogger.error('Error recording product purchase', e);
    }
  }

  Map<String, dynamic> _getProductInfo(String productId) {
    switch (productId) {
      case ProductIds.snakeClassicProMonthly:
        return {'type': 'subscription', 'name': 'Snake Classic Pro Monthly', 'price': 399, 'currency': 'USD'};
      case ProductIds.snakeClassicProYearly:
        return {'type': 'subscription', 'name': 'Snake Classic Pro Yearly', 'price': 2999, 'currency': 'USD'};
      case ProductIds.battlePass:
        return {'type': 'battlepass', 'name': 'Battle Pass', 'price': 999, 'currency': 'USD'};
      case ProductIds.themesBundle:
        return {'type': 'bundle', 'name': 'All Premium Themes Bundle', 'price': 699, 'currency': 'USD'};
      case ProductIds.premiumPowerupsBundle:
        return {'type': 'bundle', 'name': 'Premium Power-ups Bundle', 'price': 499, 'currency': 'USD'};
      case ProductIds.ultimateCosmetics:
        return {'type': 'bundle', 'name': 'Ultimate Cosmetics Bundle', 'price': 899, 'currency': 'USD'};
      case ProductIds.crystalTheme:
        return {'type': 'theme', 'name': 'Crystal Theme', 'price': 199, 'currency': 'USD'};
      case ProductIds.cyberpunkTheme:
        return {'type': 'theme', 'name': 'Cyberpunk Theme', 'price': 199, 'currency': 'USD'};
      case ProductIds.spaceTheme:
        return {'type': 'theme', 'name': 'Space Theme', 'price': 199, 'currency': 'USD'};
      case ProductIds.oceanTheme:
        return {'type': 'theme', 'name': 'Ocean Theme', 'price': 199, 'currency': 'USD'};
      case ProductIds.desertTheme:
        return {'type': 'theme', 'name': 'Desert Theme', 'price': 199, 'currency': 'USD'};
      case ProductIds.tournamentBronze:
        return {'type': 'tournament', 'name': 'Bronze Tournament Entry', 'price': 99, 'currency': 'USD'};
      case ProductIds.tournamentSilver:
        return {'type': 'tournament', 'name': 'Silver Tournament Entry', 'price': 199, 'currency': 'USD'};
      case ProductIds.tournamentGold:
        return {'type': 'tournament', 'name': 'Gold Tournament Entry', 'price': 299, 'currency': 'USD'};
      case ProductIds.championshipEntry:
        return {'type': 'tournament', 'name': 'Championship Entry', 'price': 499, 'currency': 'USD'};
      default:
        return {'type': 'unknown', 'name': 'Unknown Product', 'price': 0, 'currency': 'USD'};
    }
  }

  // Public method to handle purchase completion
  Future<void> handlePurchaseCompletion(String productId) async {
    AppLogger.info('Handling purchase completion for: $productId');
    
    // Record the purchase in history
    await _recordProductPurchase(productId);
    
    switch (productId) {
      case ProductIds.snakeClassicProMonthly:
      case ProductIds.snakeClassicProYearly:
        await _activatePremium(PremiumTier.pro);
        break;
      case ProductIds.battlePass:
        await _activateBattlePass();
        break;
      case ProductIds.themesBundle:
        await _unlockAllPremiumThemes();
        break;
      case ProductIds.premiumPowerupsBundle:
        await _unlockAllPremiumPowerUps();
        break;
      case ProductIds.ultimateCosmetics:
        await _unlockAllPremiumCosmetics();
        break;
      case ProductIds.crystalTheme:
      case ProductIds.cyberpunkTheme:
      case ProductIds.spaceTheme:
      case ProductIds.oceanTheme:
      case ProductIds.desertTheme:
        await _unlockThemeFromProduct(productId);
        break;
      case ProductIds.tournamentBronze:
        await addTournamentEntry('bronze');
        break;
      case ProductIds.tournamentSilver:
        await addTournamentEntry('silver');
        break;
      case ProductIds.tournamentGold:
        await addTournamentEntry('gold');
        break;
      case ProductIds.championshipEntry:
        await addTournamentEntry('championship');
        break;
    }
  }

  // Trial management
  Future<bool> startFreeTrial() async {
    try {
      if (hasUsedTrial) {
        AppLogger.warning('User has already used their free trial');
        return false;
      }
      
      final now = DateTime.now();
      _isOnTrial = true;
      _trialStartDate = now;
      _trialEndDate = now.add(trialDuration);
      
      await _savePremiumStatus();
      notifyListeners();
      
      AppLogger.info('Free trial started - expires ${_trialEndDate!.toIso8601String()}');
      return true;
    } catch (e) {
      AppLogger.error('Error starting free trial', e);
      return false;
    }
  }

  Future<void> endTrial() async {
    try {
      _isOnTrial = false;
      await _savePremiumStatus();
      notifyListeners();
      
      AppLogger.info('Free trial ended');
    } catch (e) {
      AppLogger.error('Error ending trial', e);
    }
  }

  // Check if board size is unlocked
  bool isBoardSizeUnlocked(String boardSizeId) {
    final size = GameConstants.availableBoardSizes.firstWhere(
      (s) => s.id == boardSizeId,
      orElse: () => GameConstants.availableBoardSizes.first,
    );
    
    if (!size.isPremium) return true;
    return hasPremium;
  }

  // Check if game mode is unlocked
  bool isGameModeUnlocked(GameMode gameMode) {
    if (!gameMode.isPremium) return true;
    return hasPremium;
  }

  // Battle Pass reward distribution methods
  Future<bool> claimBattlePassReward(String rewardId, Map<String, dynamic> rewardData) async {
    try {
      final rewardType = rewardData['type'] as String?;
      final quantity = rewardData['quantity'] as int? ?? 1;
      final itemId = rewardData['item_id'] as String?;
      
      bool success = false;
      
      switch (rewardType) {
        case 'coins':
          success = await _awardCoins(quantity);
          break;
        case 'theme':
          if (itemId != null) {
            success = await _unlockThemeFromId(itemId);
          }
          break;
        case 'skin':
          if (itemId != null) {
            success = await _unlockSkin(itemId);
          }
          break;
        case 'trail':
          if (itemId != null) {
            success = await _unlockTrail(itemId);
          }
          break;
        case 'powerUp':
          if (itemId != null) {
            success = await _unlockPowerUp(itemId);
          }
          break;
        case 'tournamentEntry':
          if (itemId != null) {
            success = await _awardTournamentEntry(itemId, quantity);
          }
          break;
        case 'xp':
          success = await _awardBattlePassXP(quantity);
          break;
        case 'special':
          success = await _handleSpecialReward(itemId, quantity);
          break;
        default:
          AppLogger.warning('Unknown reward type: $rewardType');
          success = false;
      }
      
      if (success) {
        await _savePremiumStatus();
        notifyListeners();
        AppLogger.info('Battle Pass reward claimed: $rewardId');
      }
      
      return success;
    } catch (e) {
      AppLogger.error('Error claiming Battle Pass reward', e);
      return false;
    }
  }

  Future<bool> _awardCoins(int amount) async {
    try {
      // Get CoinsProvider instance and add coins
      final coinsProvider = CoinsProvider();
      await coinsProvider.initialize();
      final success = await coinsProvider.earnCoins(
        CoinEarningSource.battlePassReward,
        customAmount: amount,
        itemName: 'Battle Pass Reward',
      );
      
      if (success) {
        AppLogger.info('Awarded $amount coins from Battle Pass');
        return true;
      } else {
        AppLogger.error('Failed to award coins from Battle Pass');
        return false;
      }
    } catch (e) {
      AppLogger.error('Error awarding coins', e);
      return false;
    }
  }

  Future<bool> _unlockThemeFromId(String themeId) async {
    try {
      // Convert theme ID to GameTheme enum
      final theme = GameTheme.values.firstWhere(
        (t) => t.name.toLowerCase() == themeId.toLowerCase(),
        orElse: () => GameTheme.classic,
      );
      
      if (theme != GameTheme.classic) {
        await unlockTheme(theme);
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error('Error unlocking theme from Battle Pass', e);
      return false;
    }
  }

  Future<bool> _unlockSkin(String skinId) async {
    try {
      if (!_ownedSkins.contains(skinId)) {
        _ownedSkins.add(skinId);
        await _savePremiumStatus();
        notifyListeners();
        AppLogger.info('Unlocked skin from Battle Pass: $skinId');
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error('Error unlocking skin from Battle Pass', e);
      return false;
    }
  }

  Future<bool> _unlockTrail(String trailId) async {
    try {
      if (!_ownedTrails.contains(trailId)) {
        _ownedTrails.add(trailId);
        await _savePremiumStatus();
        notifyListeners();
        AppLogger.info('Unlocked trail from Battle Pass: $trailId');
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error('Error unlocking trail from Battle Pass', e);
      return false;
    }
  }

  Future<bool> _unlockPowerUp(String powerUpId) async {
    try {
      if (!_ownedPowerUps.contains(powerUpId)) {
        _ownedPowerUps.add(powerUpId);
        await _savePremiumStatus();
        notifyListeners();
        AppLogger.info('Unlocked power-up from Battle Pass: $powerUpId');
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error('Error unlocking power-up from Battle Pass', e);
      return false;
    }
  }

  Future<bool> _awardTournamentEntry(String entryType, int quantity) async {
    try {
      switch (entryType.toLowerCase()) {
        case 'bronze':
          _bronzeTournamentEntries += quantity;
          break;
        case 'silver':
          _silverTournamentEntries += quantity;
          break;
        case 'gold':
          _goldTournamentEntries += quantity;
          break;
        case 'championship':
          _championshipEntries += quantity;
          break;
        default:
          AppLogger.warning('Unknown tournament entry type: $entryType');
          return false;
      }
      
      AppLogger.info('Awarded $quantity $entryType tournament entries');
      return true;
    } catch (e) {
      AppLogger.error('Error awarding tournament entry', e);
      return false;
    }
  }

  Future<bool> _awardBattlePassXP(int amount) async {
    try {
      _battlePassXP += amount;
      AppLogger.info('Awarded $amount Battle Pass XP');
      return true;
    } catch (e) {
      AppLogger.error('Error awarding Battle Pass XP', e);
      return false;
    }
  }

  Future<bool> _handleSpecialReward(String? itemId, int quantity) async {
    try {
      // Handle special rewards like exclusive titles, avatars, etc.
      AppLogger.info('Awarded special reward: $itemId (quantity: $quantity)');
      return true;
    } catch (e) {
      AppLogger.error('Error handling special reward', e);
      return false;
    }
  }


  @override
  void dispose() {
    _purchaseStatusSubscription?.cancel();
    super.dispose();
  }
}
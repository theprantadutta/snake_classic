import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/purchase_service.dart';
import '../services/preferences_service.dart';
import '../providers/coins_provider.dart';
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
    'golden_snake',
    'rainbow_snake',
    'galaxy_snake',
    'dragon_snake',
    'electric_snake',
    'fire_snake',
    'ice_snake',
    'shadow_snake',
  };

  // Premium Trails
  static const Set<String> premiumTrails = {
    'particle_trail',
    'glow_trail',
    'rainbow_trail',
    'fire_trail',
    'electric_trail',
    'star_trail',
    'cosmic_trail',
    'neon_trail',
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
      await _savePremiumStatus();
      notifyListeners();
      AppLogger.info('Skin unlocked: $skinId');
    }
  }

  Future<void> unlockTrail(String trailId) async {
    if (!_ownedTrails.contains(trailId)) {
      _ownedTrails.add(trailId);
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

  // Public method to handle purchase completion
  Future<void> handlePurchaseCompletion(String productId) async {
    AppLogger.info('Handling purchase completion for: $productId');
    
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

  @override
  void dispose() {
    _purchaseStatusSubscription?.cancel();
    super.dispose();
  }
}
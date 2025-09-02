import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/services/unified_user_service.dart';

class UserProvider extends ChangeNotifier {
  UnifiedUserService? _userService;
  bool _isInitialized = false;
  bool _isLoading = false;

  // Getters that delegate to UnifiedUserService
  bool get isSignedIn => _userService?.isSignedIn ?? false;
  bool get isAnonymous => _userService?.isAnonymous ?? false;
  bool get isGuestUser => _userService?.isAnonymous ?? false; // Anonymous users are like guests
  bool get isGoogleUser => _userService?.isGoogleUser ?? false;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  
  String get displayName => _userService?.displayName ?? 'Player';
  String get username => _userService?.username ?? 'Guest';
  String? get photoURL => _userService?.photoURL;
  int get highScore => _userService?.highScore ?? 0;
  
  // Firebase user for backward compatibility
  User? get user => _userService?.currentUser?.userType == UserType.anonymous 
      ? null : null; // This needs to be implemented properly
  
  Map<String, dynamic>? get userProfile => _userService?.currentUser != null 
      ? _userService!.currentUser!.toFirestore() : null;

  // Initialize by getting UnifiedUserService from context
  void initialize(BuildContext context) {
    if (_isInitialized) return;
    
    _userService = Provider.of<UnifiedUserService>(context, listen: false);
    _userService?.addListener(_onUserServiceChanged);
    _isInitialized = true;
    notifyListeners();
  }

  void _onUserServiceChanged() {
    notifyListeners();
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final result = await _userService?.signInWithGoogle() ?? false;
      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInAnonymously() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // UnifiedUserService already handles anonymous sign-in automatically
      // This method exists for compatibility but doesn't need to do anything
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _userService?.signOut();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUsername(String newUsername) async {
    return await _userService?.updateUsername(newUsername) ?? false;
  }

  Future<void> updateGameStats({
    int? newHighScore,
    int? gamesPlayed,
    int? totalScore,
    int? level,
  }) async {
    await _userService?.updateGameStats(
      newHighScore: newHighScore,
      gamesPlayed: gamesPlayed,
      totalScore: totalScore,
      level: level,
    );
  }

  // Legacy methods for backward compatibility
  Future<bool> updateGuestUsername(String newUsername) async {
    return await updateUsername(newUsername);
  }

  Future<bool> updateAuthenticatedUsername(String newUsername) async {
    return await updateUsername(newUsername);
  }

  // Properties that were used in the old system
  int get totalGamesPlayed => _userService?.currentUser?.totalGamesPlayed ?? 0;
  int get totalScore => _userService?.currentUser?.totalScore ?? 0;

  // First-time setup management
  Future<bool> isFirstTimeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return !(prefs.getBool('first_time_setup_complete') ?? false);
    } catch (e) {
      return true; // Default to showing first-time screen if error
    }
  }

  Future<void> markFirstTimeSetupComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('first_time_setup_complete', true);
    } catch (e) {
      // Ignore error, not critical
    }
  }

  @override
  void dispose() {
    _userService?.removeListener(_onUserServiceChanged);
    super.dispose();
  }
}
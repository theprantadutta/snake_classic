import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snake_classic/services/auth_service.dart';
import 'package:snake_classic/services/guest_user_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final GuestUserService _guestUserService = GuestUserService();
  
  User? _user;
  Map<String, dynamic>? _userProfile;
  GuestUser? _guestUser;
  bool _isLoading = false;

  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  GuestUser? get guestUser => _guestUser;
  bool get isLoading => _isLoading;
  bool get isSignedIn => _user != null;
  bool get isAnonymous => _user?.isAnonymous ?? false;
  bool get isGuestUser => _guestUser != null && _user == null;

  String get displayName {
    if (_guestUser != null) {
      return _guestUser!.username;
    }
    if (_userProfile != null) {
      return _userProfile!['displayName'] ?? 'Player';
    }
    return _user?.displayName ?? 'Player';
  }

  String? get photoURL => _user?.photoURL;
  
  int get highScore {
    if (_guestUser != null) {
      return _guestUser!.highScore;
    }
    return _userProfile?['highScore'] ?? 0;
  }
  
  int get totalGamesPlayed {
    if (_guestUser != null) {
      return _guestUser!.totalGamesPlayed;
    }
    return _userProfile?['totalGamesPlayed'] ?? 0;
  }
  
  int get totalScore {
    if (_guestUser != null) {
      return _guestUser!.totalScore;
    }
    return _userProfile?['totalScore'] ?? 0;
  }

  UserProvider() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
    
    _user = _authService.currentUser;
    if (_user != null) {
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    if (_user == null) return;
    
    _userProfile = await _authService.getUserProfile();
    notifyListeners();
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final result = await _authService.signInWithGoogle();
      
      // If successful and we have guest data, migrate it
      if (result != null && _guestUser != null) {
        await migrateGuestToAuthenticated();
      }
      
      return result != null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInAnonymously() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _authService.signInAnonymously();
      
      // If successful and we have guest data, migrate it
      if (_user != null && _guestUser != null) {
        await migrateGuestToAuthenticated();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _authService.signOut();
      
      // After signing out, create a new guest user
      final guestUser = await _guestUserService.createGuestUser();
      _guestUser = guestUser;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateHighScore(int score) async {
    await _authService.updateHighScore(score);
    await _loadUserProfile();
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    await _authService.updateUserProfile(data);
    await _loadUserProfile();
  }

  // Guest User Methods

  Future<void> setGuestUser(GuestUser guestUser) async {
    _guestUser = guestUser;
    notifyListeners();
  }

  Future<void> updateGuestHighScore(int score) async {
    if (_guestUser != null) {
      await _guestUserService.updateHighScore(score);
      _guestUser = _guestUserService.currentGuestUser;
      notifyListeners();
    } else if (_user != null) {
      // If signed in, use the regular update method
      await updateHighScore(score);
    }
  }

  Future<bool> updateGuestUsername(String newUsername) async {
    if (_guestUser != null) {
      final success = await _guestUserService.updateUsername(newUsername);
      if (success) {
        _guestUser = _guestUserService.currentGuestUser;
        notifyListeners();
      }
      return success;
    }
    return false;
  }

  Future<bool> updateAuthenticatedUsername(String newUsername) async {
    if (_user != null) {
      final success = await _authService.updateUsername(newUsername);
      if (success) {
        await _loadUserProfile();
      }
      return success;
    }
    return false;
  }

  Future<void> migrateGuestToAuthenticated() async {
    if (_guestUser != null && _user != null) {
      try {
        // Export guest data
        final guestData = _guestUserService.exportGuestData();
        
        // Use the AuthService method that handles guest data migration
        await _authService.createUserProfileWithGuestData(_user!, guestData);
        
        // Clear guest user data
        await _guestUserService.clearGuestUser();
        _guestUser = null;
        
        // Reload user profile
        await _loadUserProfile();
        
      } catch (e) {
        print('Error migrating guest user: $e');
        // Don't clear guest data if migration fails
      }
    }
  }

}
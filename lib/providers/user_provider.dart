import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snake_classic/services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;

  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isSignedIn => _user != null;
  bool get isAnonymous => _user?.isAnonymous ?? false;

  String get displayName {
    if (_userProfile != null) {
      return _userProfile!['displayName'] ?? 'Player';
    }
    return _user?.displayName ?? 'Player';
  }

  String? get photoURL => _user?.photoURL;
  int get highScore => _userProfile?['highScore'] ?? 0;
  int get totalGamesPlayed => _userProfile?['totalGamesPlayed'] ?? 0;
  int get totalScore => _userProfile?['totalScore'] ?? 0;

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
}
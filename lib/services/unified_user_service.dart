import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/notification_service.dart';
import 'package:snake_classic/utils/logger.dart';

enum UserType { guest, anonymous, google }

class UnifiedUser {
  final String uid;
  final UserType userType;
  final String username;
  final String displayName;
  final String? email;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastSeen;
  final bool isPublic;

  // Game Data
  final int highScore;
  final int totalGamesPlayed;
  final int totalScore;
  final int level;

  // Preferences
  final Map<String, dynamic> preferences;

  const UnifiedUser({
    required this.uid,
    required this.userType,
    required this.username,
    required this.displayName,
    this.email,
    this.photoURL,
    required this.createdAt,
    required this.lastSeen,
    this.isPublic = true,
    this.highScore = 0,
    this.totalGamesPlayed = 0,
    this.totalScore = 0,
    this.level = 1,
    this.preferences = const {},
  });

  UnifiedUser copyWith({
    String? uid,
    UserType? userType,
    String? username,
    String? displayName,
    String? email,
    String? photoURL,
    DateTime? createdAt,
    DateTime? lastSeen,
    bool? isPublic,
    int? highScore,
    int? totalGamesPlayed,
    int? totalScore,
    int? level,
    Map<String, dynamic>? preferences,
  }) {
    return UnifiedUser(
      uid: uid ?? this.uid,
      userType: userType ?? this.userType,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      isPublic: isPublic ?? this.isPublic,
      highScore: highScore ?? this.highScore,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalScore: totalScore ?? this.totalScore,
      level: level ?? this.level,
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'userType': userType.name,
      'username': username,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(),
      'lastSeen': lastSeen.toIso8601String(),
      'isPublic': isPublic,
      'highScore': highScore,
      'totalGamesPlayed': totalGamesPlayed,
      'totalScore': totalScore,
      'level': level,
      'preferences': preferences,
    };
  }

  static UnifiedUser fromJson(Map<String, dynamic> data) {
    return UnifiedUser(
      uid: data['uid'] ?? data['id']?.toString() ?? '',
      userType: _parseUserType(data),
      username: data['username'] ?? '',
      displayName: data['displayName'] ?? data['display_name'] ?? '',
      email: data['email'],
      photoURL: data['photoURL'] ?? data['photo_url'],
      createdAt: _parseDateTime(data['createdAt'] ?? data['created_at'] ?? data['joined_date']),
      lastSeen: _parseDateTime(data['lastSeen'] ?? data['last_seen']),
      isPublic: data['isPublic'] ?? data['is_public'] ?? true,
      highScore: data['highScore'] ?? data['high_score'] ?? 0,
      totalGamesPlayed: data['totalGamesPlayed'] ?? data['total_games_played'] ?? 0,
      totalScore: data['totalScore'] ?? data['total_score'] ?? 0,
      level: data['level'] ?? 1,
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
    );
  }

  /// Parse user type from backend response
  static UserType _parseUserType(Map<String, dynamic> data) {
    // Check explicit userType field first
    final userType = data['userType'] ?? data['user_type'];
    if (userType != null) {
      return UserType.values.firstWhere(
        (type) => type.name == userType,
        orElse: () => UserType.anonymous,
      );
    }

    // Otherwise, derive from auth_provider/is_anonymous (backend format)
    final authProvider = data['auth_provider'] ?? data['authProvider'];
    final isAnonymous = data['is_anonymous'] ?? data['isAnonymous'] ?? false;

    if (isAnonymous == true) {
      return UserType.anonymous;
    }

    if (authProvider == 'google') {
      return UserType.google;
    }

    // Default to anonymous
    return UserType.anonymous;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}

class UnifiedUserService extends ChangeNotifier {
  static final UnifiedUserService _instance = UnifiedUserService._internal();
  factory UnifiedUserService() => _instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final ApiService _apiService = ApiService();

  UnifiedUserService._internal() {
    // Initialize Google Sign-In with client ID
    _googleSignIn.initialize(
      serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
    );
  }

  SharedPreferences? _prefs;
  UnifiedUser? _currentUser;
  StreamSubscription<User?>? _authSubscription;
  bool _isInitialized = false;

  // Getters
  UnifiedUser? get currentUser => _currentUser;
  bool get isInitialized => _isInitialized;
  bool get isSignedIn => _currentUser != null;
  bool get isAnonymous => _currentUser?.userType == UserType.anonymous;
  bool get isGuestUser => _currentUser?.userType == UserType.guest;
  bool get isGoogleUser => _currentUser?.userType == UserType.google;

  String get displayName => _currentUser?.displayName ?? 'Player';
  String get username => _currentUser?.username ?? 'Guest';
  String? get photoURL => _currentUser?.photoURL;
  int get highScore => _currentUser?.highScore ?? 0;

  Future<void> initialize() async {
    try {
      AppLogger.user('STARTING UnifiedUserService initialization...');

      if (_isInitialized) {
        AppLogger.user('Already initialized');
        return;
      }

      AppLogger.user('Getting SharedPreferences...');
      _prefs = await SharedPreferences.getInstance();
      AppLogger.success('SharedPreferences obtained');

      // Initialize API service
      await _apiService.initialize();

      // Start listening to auth state changes
      AppLogger.user('Setting up auth state listener...');
      _authSubscription = _auth.authStateChanges().listen(
        _handleAuthStateChange,
      );
      AppLogger.success('Auth state listener set up');

      // Check if user is already signed in
      final currentFirebaseUser = _auth.currentUser;
      AppLogger.user(
        'Current Firebase user: ${currentFirebaseUser?.uid ?? "null"}',
      );

      if (currentFirebaseUser != null) {
        AppLogger.user('Found existing user: ${currentFirebaseUser.uid}');
        await _loadOrCreateUser(currentFirebaseUser);
      } else {
        AppLogger.user('No existing user, signing in anonymously...');
        // No user signed in, create anonymous user
        await _signInAnonymously();
      }

      _isInitialized = true;
      AppLogger.success(
        'UnifiedUserService initialization complete. Current user: ${_currentUser?.username}',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'UnifiedUserService initialization failed',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> _handleAuthStateChange(User? firebaseUser) async {
    if (firebaseUser != null) {
      await _loadOrCreateUser(firebaseUser);
    } else {
      _currentUser = null;
      notifyListeners();
    }
  }

  Future<void> _loadOrCreateUser(User firebaseUser) async {
    try {
      AppLogger.user('Loading/creating user for UID: ${firebaseUser.uid}');

      // Authenticate with backend using Firebase token
      final idToken = await firebaseUser.getIdToken();
      if (idToken != null) {
        final authResult = await _apiService.authenticateWithFirebase(idToken);

        if (authResult != null) {
          AppLogger.success('Backend authentication successful');

          // Load user profile from backend
          final userProfile = await _apiService.getCurrentUser();
          if (userProfile != null) {
            _currentUser = UnifiedUser.fromJson(userProfile);
            AppLogger.success('User loaded from backend: ${_currentUser?.username}');
          } else {
            // Create local user object from Firebase data
            _currentUser = await _createUserFromFirebase(firebaseUser);
          }
        } else {
          // Backend auth failed, create local user
          _currentUser = await _createUserFromFirebase(firebaseUser);
        }
      } else {
        // No token, create local user
        _currentUser = await _createUserFromFirebase(firebaseUser);
      }

      notifyListeners();

      // Initialize notification backend integration after user is loaded
      _initializeNotificationIntegration();
    } catch (e, stackTrace) {
      AppLogger.user('Error loading/creating user', e, stackTrace);
    }
  }

  Future<UnifiedUser> _createUserFromFirebase(User firebaseUser) async {
    // Determine user type
    UserType userType = UserType.anonymous;
    if (firebaseUser.providerData.any(
      (provider) => provider.providerId == 'google.com',
    )) {
      userType = UserType.google;
    }

    // Generate unique username
    final username = await _generateUniqueUsername();

    // Get default preferences
    final preferences = await _getDefaultPreferences();

    // Check if we have local guest data to migrate
    final guestData = await _getLocalGuestData();

    return UnifiedUser(
      uid: firebaseUser.uid,
      userType: userType,
      username: username,
      displayName: firebaseUser.displayName ?? username,
      email: firebaseUser.email,
      photoURL: firebaseUser.photoURL,
      createdAt: DateTime.now(),
      lastSeen: DateTime.now(),
      highScore: guestData['highScore'] ?? 0,
      totalGamesPlayed: guestData['totalGamesPlayed'] ?? 0,
      totalScore: guestData['totalScore'] ?? 0,
      level: guestData['level'] ?? 1,
      preferences: preferences,
    );
  }

  Future<String> _generateUniqueUsername() async {
    final adjectives = [
      'Swift', 'Quick', 'Fast', 'Sneaky', 'Sharp', 'Cool', 'Epic', 'Super',
      'Mega', 'Ultra', 'Pro', 'Elite', 'Master', 'Ace', 'Clever', 'Smart',
      'Brave', 'Bold', 'Wild', 'Fierce', 'Mighty', 'Strong', 'Agile', 'Smooth',
      'Silent', 'Shadow', 'Golden', 'Silver', 'Diamond', 'Ruby', 'Fire', 'Ice',
    ];

    final nouns = [
      'Snake', 'Viper', 'Python', 'Cobra', 'Serpent', 'Player', 'Gamer',
      'Champion', 'Hunter', 'Racer', 'Striker', 'Warrior', 'Hero', 'Legend',
      'Dragon', 'Phoenix', 'Eagle', 'Hawk', 'Wolf', 'Tiger', 'Lion', 'Bear',
      'Fox', 'Shark', 'Panther', 'Falcon', 'Raven', 'Knight', 'Ninja', 'Samurai',
    ];

    final random = Random();
    final adjective = adjectives[random.nextInt(adjectives.length)];
    final noun = nouns[random.nextInt(nouns.length)];
    final number = random.nextInt(9999) + 1;

    return '${adjective}_${noun}_$number';
  }

  Future<Map<String, dynamic>> _getDefaultPreferences() async {
    return {
      'theme': 'classic',
      'soundEnabled': true,
      'musicEnabled': true,
      'trailSystemEnabled': false,
      'boardSize': {'width': 20, 'height': 20, 'name': 'Classic'},
    };
  }

  Future<Map<String, dynamic>> _getLocalGuestData() async {
    if (_prefs == null) return {};

    try {
      final guestDataJson = _prefs!.getString('guest_user_data');
      if (guestDataJson != null) {
        final data = jsonDecode(guestDataJson);
        return {
          'highScore': data['highScore'] ?? 0,
          'totalGamesPlayed': data['totalGamesPlayed'] ?? 0,
          'totalScore': data['totalScore'] ?? 0,
          'level': 1,
        };
      }
    } catch (e) {
      AppLogger.storage('Error loading local guest data', e);
    }

    return {};
  }

  // ignore: unused_element - May be useful later for guest data migration
  Future<void> _clearLocalGuestData() async {
    if (_prefs == null) return;

    await _prefs!.remove('guest_user_data');
    await _prefs!.remove('has_initialized_guest');
  }

  // Public methods

  Future<bool> _signInAnonymously() async {
    try {
      AppLogger.firebase('Attempting anonymous sign-in...');

      final result = await _auth.signInAnonymously();

      AppLogger.success('Anonymous sign-in successful: ${result.user?.uid}');

      return true;
    } catch (e, stackTrace) {
      AppLogger.firebase('Error signing in anonymously', e, stackTrace);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      AppLogger.user('Starting Google Sign-In from UnifiedUserService...');

      // Check if authentication is supported on this platform
      if (_googleSignIn.supportsAuthenticate()) {
        // Use authenticate method for supported platforms
        final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

        AppLogger.user('Google user signed in: ${googleUser.email}');

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;

        if (googleAuth.idToken == null) {
          AppLogger.user('Failed to get Google ID token');
          return false;
        }

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        AppLogger.user('Creating Firebase credential...');

        // Sign in to Firebase with the credential
        final UserCredential result = await _auth.signInWithCredential(credential);

        if (result.user != null) {
          AppLogger.success('Firebase sign-in successful: ${result.user!.uid}');

          // The auth state change listener will handle creating the user profile
          // and migrating data if needed
          return true;
        }

        return false;
      } else {
        AppLogger.user('Google Sign-In authenticate not supported on this platform');
        return false;
      }
    } on FirebaseAuthException catch (e) {
      AppLogger.user('Firebase Auth error during Google Sign-In: ${e.code} - ${e.message}');
      return false;
    } catch (e, stackTrace) {
      AppLogger.user('Error signing in with Google', e, stackTrace);
      return false;
    }
  }

  Future<bool> updateUsername(String newUsername) async {
    if (_currentUser == null) return false;

    try {
      // Update via backend API
      final result = await _apiService.setUsername(newUsername);
      if (result == null) return false;

      // Update local user
      _currentUser = _currentUser!.copyWith(username: newUsername);

      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      AppLogger.user('Error updating username', e, stackTrace);
      return false;
    }
  }

  Future<void> updateGameStats({
    int? newHighScore,
    int? gamesPlayed,
    int? totalScore,
    int? level,
  }) async {
    if (_currentUser == null) return;

    final updatedHighScore =
        (newHighScore != null && newHighScore > _currentUser!.highScore)
        ? newHighScore
        : _currentUser!.highScore;

    _currentUser = _currentUser!.copyWith(
      highScore: updatedHighScore,
      totalGamesPlayed: (_currentUser!.totalGamesPlayed + (gamesPlayed ?? 0)),
      totalScore: (_currentUser!.totalScore + (totalScore ?? 0)),
      level: level ?? _currentUser!.level,
    );

    // Update via backend API
    if (_apiService.isAuthenticated) {
      await _apiService.updateProfile({
        'high_score': _currentUser!.highScore,
        'total_games_played': _currentUser!.totalGamesPlayed,
        'total_score': _currentUser!.totalScore,
        'level': _currentUser!.level,
      });

      // Also submit the score
      if (newHighScore != null) {
        await _apiService.submitScore(score: newHighScore);
      }
    }

    notifyListeners();
  }

  Future<void> updatePreferences(Map<String, dynamic> newPreferences) async {
    if (_currentUser == null) return;

    final updatedPrefs = Map<String, dynamic>.from(_currentUser!.preferences);
    updatedPrefs.addAll(newPreferences);

    _currentUser = _currentUser!.copyWith(preferences: updatedPrefs);

    // Update via backend API
    if (_apiService.isAuthenticated) {
      await _apiService.updateProfile({
        'preferences': updatedPrefs,
      });
    }

    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      // Logout from backend
      await _apiService.logout();

      // Sign out from Google Sign-In as well
      await _googleSignIn.signOut();
      await _auth.signOut();
      _currentUser = null;

      // Create new anonymous user
      await _signInAnonymously();

      notifyListeners();
    } catch (e) {
      AppLogger.user('Error signing out', e);
    }
  }

  /// Initialize notification backend integration
  Future<void> _initializeNotificationIntegration() async {
    try {
      // Use a brief delay to ensure notification service is fully initialized
      await Future.delayed(const Duration(seconds: 1));

      // Initialize backend integration
      await NotificationService().initializeBackendIntegration();
    } catch (e) {
      AppLogger.user('Error initializing notification integration', e);
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

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

  // Storage keys for offline session persistence
  static const String _cachedUserKey = 'cached_unified_user';

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
  bool _isLoadingUser = false; // Prevents concurrent user loading
  String? _loadingUserId; // Track which user is being loaded

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
        // No Firebase user - try cached session first
        final cachedUser = await _loadCachedUserSession();
        if (cachedUser != null) {
          AppLogger.user('Using cached user session (no Firebase auth)');
          _currentUser = cachedUser;
          notifyListeners();

          // Try anonymous sign-in in background (if we come online later)
          _signInAnonymously().catchError((_) {
            // Ignore errors - we have a cached user
            return false;
          });
        } else {
          AppLogger.user('No existing user or cache, signing in anonymously...');
          // No user signed in and no cache, create anonymous user
          await _signInAnonymously();
        }
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

      // Last resort: try cached user
      try {
        final cachedUser = await _loadCachedUserSession();
        if (cachedUser != null) {
          _currentUser = cachedUser;
          _isInitialized = true;
          AppLogger.warning('Recovered with cached user after init failure');
          notifyListeners();
          return;
        }
      } catch (_) {}

      rethrow;
    }
  }

  Future<void> _handleAuthStateChange(User? firebaseUser) async {
    if (firebaseUser != null) {
      // Skip if this user is already loaded or currently being loaded
      if (_currentUser != null && _currentUser!.uid == firebaseUser.uid) {
        return;
      }
      if (_isLoadingUser && _loadingUserId == firebaseUser.uid) {
        AppLogger.user('User ${firebaseUser.uid} is already being loaded, skipping duplicate');
        return;
      }
      await _loadOrCreateUser(firebaseUser);
    } else {
      _currentUser = null;
      notifyListeners();
    }
  }

  Future<void> _loadOrCreateUser(User firebaseUser) async {
    // Prevent concurrent loading of the same user
    if (_isLoadingUser && _loadingUserId == firebaseUser.uid) {
      AppLogger.user('Already loading user ${firebaseUser.uid}, skipping');
      return;
    }

    _isLoadingUser = true;
    _loadingUserId = firebaseUser.uid;

    try {
      AppLogger.user('Loading/creating user for UID: ${firebaseUser.uid}');

      // Try to get ID token - may fail if offline with expired token
      String? idToken;
      try {
        idToken = await firebaseUser.getIdToken();
      } catch (tokenError) {
        AppLogger.warning('Failed to get ID token (may be offline): $tokenError');
        // Continue without token - we'll try cached data
      }

      if (idToken != null) {
        // Online path - authenticate with backend
        final authResult = await _apiService.authenticateWithFirebase(idToken);

        if (authResult != null) {
          AppLogger.success('Backend authentication successful');

          // Load user profile from backend
          final userProfile = await _apiService.getCurrentUser();
          if (userProfile != null) {
            _currentUser = UnifiedUser.fromJson(userProfile);
            // Cache the session for offline use
            await _cacheUserSession(_currentUser!);
            AppLogger.success('User loaded from backend: ${_currentUser?.username}');
          } else {
            // Create local user object from Firebase data
            _currentUser = await _createUserFromFirebase(firebaseUser);
            await _cacheUserSession(_currentUser!);
          }
        } else {
          // Backend auth failed, create local user
          _currentUser = await _createUserFromFirebase(firebaseUser);
          await _cacheUserSession(_currentUser!);
        }
      } else {
        // Offline path - try to load cached session
        final cachedUser = await _loadCachedUserSession();
        if (cachedUser != null && cachedUser.uid == firebaseUser.uid) {
          _currentUser = cachedUser;
          AppLogger.success('Restored user from cache (offline): ${_currentUser?.username}');
        } else {
          // No matching cache, create minimal local user
          _currentUser = await _createUserFromFirebase(firebaseUser);
          await _cacheUserSession(_currentUser!);
        }
      }

      notifyListeners();

      // Initialize notification backend integration after user is loaded
      _initializeNotificationIntegration();
    } catch (e, stackTrace) {
      AppLogger.user('Error loading/creating user', e, stackTrace);

      // Fallback: try to restore from cache
      final cachedUser = await _loadCachedUserSession();
      if (cachedUser != null) {
        _currentUser = cachedUser;
        AppLogger.warning('Restored user from cache after error');
        notifyListeners();
      }
    } finally {
      _isLoadingUser = false;
      _loadingUserId = null;
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

  /// Save user session to local storage for offline access
  Future<void> _cacheUserSession(UnifiedUser user) async {
    if (_prefs == null) return;
    try {
      await _prefs!.setString(_cachedUserKey, jsonEncode(user.toJson()));
      AppLogger.user('Cached user session for offline use');
    } catch (e) {
      AppLogger.error('Failed to cache user session', e);
    }
  }

  /// Load cached user session from local storage
  Future<UnifiedUser?> _loadCachedUserSession() async {
    if (_prefs == null) return null;
    try {
      final cachedJson = _prefs!.getString(_cachedUserKey);
      if (cachedJson != null) {
        final userData = jsonDecode(cachedJson) as Map<String, dynamic>;
        AppLogger.user('Loaded cached user session');
        return UnifiedUser.fromJson(userData);
      }
    } catch (e) {
      AppLogger.error('Failed to load cached user session', e);
    }
    return null;
  }

  /// Clear cached user session
  Future<void> _clearCachedUserSession() async {
    if (_prefs == null) return;
    await _prefs!.remove(_cachedUserKey);
  }

  /// Create a purely offline guest user (no Firebase auth required)
  Future<UnifiedUser> _createOfflineGuestUser() async {
    AppLogger.user('Creating offline guest user...');

    // Generate a local ID for offline guest
    final offlineId = 'offline_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}';
    final username = await _generateUniqueUsername();

    // Try to get data from local guest data if available
    final guestData = await _getLocalGuestData();

    return UnifiedUser(
      uid: offlineId,
      userType: UserType.guest,
      username: username,
      displayName: username,
      createdAt: DateTime.now(),
      lastSeen: DateTime.now(),
      highScore: guestData['highScore'] ?? 0,
      totalGamesPlayed: guestData['totalGamesPlayed'] ?? 0,
      totalScore: guestData['totalScore'] ?? 0,
      level: guestData['level'] ?? 1,
      preferences: await _getDefaultPreferences(),
    );
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

      // If we can't sign in anonymously (likely offline),
      // try to restore a cached session or create an offline guest
      final cachedUser = await _loadCachedUserSession();
      if (cachedUser != null) {
        _currentUser = cachedUser;
        AppLogger.warning('Restored cached user after anonymous sign-in failed');
        notifyListeners();
        return true;
      }

      // Create a purely offline guest user
      _currentUser = await _createOfflineGuestUser();
      await _cacheUserSession(_currentUser!);
      AppLogger.warning('Created offline guest user');
      notifyListeners();
      return true;
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

  /// Public wrapper for anonymous sign-in
  Future<bool> signInAnonymously() async {
    return _signInAnonymously();
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

  /// Update username for guest users (local only)
  Future<bool> updateGuestUsername(String newUsername) async {
    if (_currentUser == null) return false;
    if (_currentUser!.userType != UserType.guest &&
        _currentUser!.userType != UserType.anonymous) {
      return false;
    }

    try {
      _currentUser = _currentUser!.copyWith(
        username: newUsername,
        displayName: newUsername,
      );
      await _cacheUserSession(_currentUser!);
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      AppLogger.user('Error updating guest username', e, stackTrace);
      return false;
    }
  }

  /// Update username for authenticated users (via backend)
  Future<bool> updateAuthenticatedUsername(String newUsername) async {
    if (_currentUser == null) return false;
    if (_currentUser!.userType != UserType.google) {
      return false;
    }

    return updateUsername(newUsername);
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

      // Clear cached session
      await _clearCachedUserSession();

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

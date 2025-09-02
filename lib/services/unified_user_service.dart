import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/services/username_service.dart';
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

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'userType': userType.name,
      'username': username,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastSeen': Timestamp.fromDate(lastSeen),
      'isPublic': isPublic,
      'highScore': highScore,
      'totalGamesPlayed': totalGamesPlayed,
      'totalScore': totalScore,
      'level': level,
      'preferences': preferences,
    };
  }

  static UnifiedUser fromFirestore(Map<String, dynamic> data) {
    return UnifiedUser(
      uid: data['uid'] ?? '',
      userType: UserType.values.firstWhere(
        (type) => type.name == data['userType'],
        orElse: () => UserType.anonymous,
      ),
      username: data['username'] ?? '',
      displayName: data['displayName'] ?? '',
      email: data['email'],
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPublic: data['isPublic'] ?? true,
      highScore: data['highScore'] ?? 0,
      totalGamesPlayed: data['totalGamesPlayed'] ?? 0,
      totalScore: data['totalScore'] ?? 0,
      level: data['level'] ?? 1,
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
    );
  }
}

class UnifiedUserService extends ChangeNotifier {
  static final UnifiedUserService _instance = UnifiedUserService._internal();
  factory UnifiedUserService() => _instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  // Note: Removed DataSyncService dependency to avoid circular imports
  final UsernameService _usernameService = UsernameService();

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
      AppLogger.user('🚀 STARTING UnifiedUserService initialization...');

      if (_isInitialized) {
        AppLogger.user('Already initialized');
        return;
      }

      AppLogger.user('Getting SharedPreferences...');
      _prefs = await SharedPreferences.getInstance();
      AppLogger.success('SharedPreferences obtained');

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
        '🎉 UnifiedUserService initialization complete. Current user: ${_currentUser?.username}',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        '❌ UnifiedUserService initialization failed',
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

      // Try to load existing user from Firestore
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      AppLogger.firebase('Firestore document exists: ${doc.exists}');

      if (doc.exists) {
        // User exists, load their data
        AppLogger.user('Loading existing user data');
        _currentUser = UnifiedUser.fromFirestore(doc.data()!);

        // Update last seen
        await _updateLastSeen();
      } else {
        // New user, create their profile
        AppLogger.user('Creating new user profile');
        await _createNewUser(firebaseUser);
      }

      // Sync service will be initialized separately

      notifyListeners();
      AppLogger.success(
        'User loaded/created successfully: ${_currentUser?.username}',
      );
      
      // Initialize notification backend integration after user is loaded
      _initializeNotificationIntegration();
    } catch (e, stackTrace) {
      AppLogger.user('Error loading/creating user', e, stackTrace);
    }
  }

  Future<void> _createNewUser(User firebaseUser) async {
    try {
      AppLogger.user('Creating new user: ${firebaseUser.uid}');

      // Determine user type
      UserType userType = UserType.anonymous;
      if (firebaseUser.providerData.any(
        (provider) => provider.providerId == 'google.com',
      )) {
        userType = UserType.google;
      }

      AppLogger.user('User type: $userType');

      // Generate unique username
      final username = await _generateUniqueUsername();
      AppLogger.user('Generated username: $username');

      // Create default preferences
      final preferences = await _getDefaultPreferences();

      // Check if we have local guest data to migrate
      final guestData = await _getLocalGuestData();

      _currentUser = UnifiedUser(
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

      // Save to Firestore
      await _saveUserToFirestore();
      AppLogger.success('User saved to Firestore');

      // Reserve username
      await _usernameService.reserveUsername(username, firebaseUser.uid);
      AppLogger.success('Username reserved');

      // Clear local guest data if migrated
      if (guestData.isNotEmpty) {
        await _clearLocalGuestData();
      }
    } catch (e, stackTrace) {
      AppLogger.user('Error creating user', e, stackTrace);
      rethrow;
    }
  }

  Future<String> _generateUniqueUsername() async {
    final adjectives = [
      'Swift',
      'Quick',
      'Fast',
      'Sneaky',
      'Sharp',
      'Cool',
      'Epic',
      'Super',
      'Mega',
      'Ultra',
      'Pro',
      'Elite',
      'Master',
      'Ace',
      'Clever',
      'Smart',
      'Brave',
      'Savage',
      'Mighty',
      'Crazy',
      'Silent',
      'Deadly',
      'Furious',
      'Stealthy',
      'Fearless',
      'Wicked',
      'Wild',
      'Dark',
      'Glorious',
      'Lucky',
      'Blazing',
      'Icy',
      'Stormy',
      'Golden',
      'Shadow',
      'Crimson',
      'Electric',
      'Phantom',
      'Cosmic',
      'Galactic',
      'Infernal',
      'Radiant',
      'Silver',
      'Iron',
      'Neon',
      'Toxic',
      'Venomous',
      'Turbo',
      'Dynamic',
      'Atomic',
      'Frozen',
      'Legendary',
      'Supreme',
      'Obsidian',
      'Lunar',
      'Solar',
      'Stellar',
      'Epic',
      'Cyber',
      'Virtual',
      'Mystic',
      'Enchanted',
      'Chaotic',
      'Noble',
      'Savvy',
    ];

    final nouns = [
      'Snake',
      'Viper',
      'Python',
      'Cobra',
      'Serpent',
      'Player',
      'Gamer',
      'Champion',
      'Hunter',
      'Racer',
      'Striker',
      'Warrior',
      'Hero',
      'Legend',
      'Beast',
      'Dragon',
      'Wolf',
      'Tiger',
      'Panther',
      'Eagle',
      'Falcon',
      'Hawk',
      'Shark',
      'Leopard',
      'Lion',
      'Bear',
      'Cheetah',
      'Rogue',
      'Knight',
      'Samurai',
      'Ninja',
      'Assassin',
      'Viking',
      'Pirate',
      'Wizard',
      'Witch',
      'Mage',
      'Druid',
      'Paladin',
      'Demon',
      'Angel',
      'Reaper',
      'Phantom',
      'Ghost',
      'Specter',
      'Zombie',
      'Ghoul',
      'Ogre',
      'Goblin',
      'Elf',
      'Orc',
      'Troll',
      'Golem',
      'Phoenix',
      'Hydra',
      'Kraken',
      'Cyclone',
      'Tornado',
      'Blizzard',
      'Storm',
      'Bolt',
      'Inferno',
      'Meteor',
      'Comet',
      'Galaxy',
      'Nebula',
      'Asteroid',
      'Star',
      'Nova',
      'Titan',
      'Colossus',
      'Juggernaut',
      'Destroyer',
      'Overlord',
      'Champion',
      'Gladiator',
      'Sentinel',
      'Guardian',
      'Ranger',
    ];

    final random = Random();

    for (int attempt = 0; attempt < 10; attempt++) {
      final adjective = adjectives[random.nextInt(adjectives.length)];
      final noun = nouns[random.nextInt(nouns.length)];
      final number = random.nextInt(9999) + 1;
      final username = '${adjective}_${noun}_$number';

      // Check if username is available
      final validation = await _usernameService.validateUsernameComplete(
        username,
      );
      if (validation.isValid) {
        return username;
      }
    }

    // Fallback: use Firebase UID with prefix
    return 'Player_${_auth.currentUser?.uid.substring(0, 8) ?? Random().nextInt(99999)}';
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

  Future<void> _clearLocalGuestData() async {
    if (_prefs == null) return;

    await _prefs!.remove('guest_user_data');
    await _prefs!.remove('has_initialized_guest');
  }

  Future<void> _saveUserToFirestore() async {
    if (_currentUser == null) {
      AppLogger.user('Cannot save - no current user');
      return;
    }

    try {
      AppLogger.firebase('Saving user to Firestore: ${_currentUser!.uid}');
      AppLogger.logObject('User data', _currentUser!.toFirestore());

      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .set(_currentUser!.toFirestore(), SetOptions(merge: true));

      AppLogger.success('Successfully saved to Firestore');
    } catch (e, stackTrace) {
      AppLogger.firebase('Error saving user to Firestore', e, stackTrace);
      // Don't rethrow to prevent app crashes, but log the error
    }
  }

  Future<void> _updateLastSeen() async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(lastSeen: DateTime.now());

    // Just save directly to Firestore for now, avoiding DataSyncService dependency
    try {
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'lastSeen': Timestamp.now(),
      });
    } catch (e) {
      AppLogger.firebase('Error updating last seen', e);
    }
  }

  // Public methods

  Future<bool> _signInAnonymously() async {
    try {
      AppLogger.firebase('🔐 Attempting anonymous sign-in...');

      final result = await _auth.signInAnonymously();

      AppLogger.success('🎯 Anonymous sign-in successful: ${result.user?.uid}');
      AppLogger.user(
        'User providers: ${result.user?.providerData.map((p) => p.providerId).toList()}',
      );

      return true;
    } catch (e, stackTrace) {
      AppLogger.firebase('❌ Error signing in anonymously', e, stackTrace);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      AppLogger.user('🔐 Starting Google Sign-In from UnifiedUserService...');

      // Check if authentication is supported on this platform
      if (_googleSignIn.supportsAuthenticate()) {
        // Use authenticate method for supported platforms
        final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
        
        AppLogger.user('Google user signed in: ${googleUser.email}');

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;

        if (googleAuth.idToken == null) {
          AppLogger.user('❌ Failed to get Google ID token');
          return false;
        }

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        AppLogger.user('Creating Firebase credential...');

        // Note: Anonymous user data migration will be handled automatically
        // by the auth state change listener and user profile creation process

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
        AppLogger.user('❌ Google Sign-In authenticate not supported on this platform');
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
      // Validate username
      final validation = await _usernameService.validateUsernameComplete(
        newUsername,
      );
      if (!validation.isValid) return false;

      // Release old username and reserve new one
      await _usernameService.releaseUsername(_currentUser!.username);
      await _usernameService.reserveUsername(newUsername, _currentUser!.uid);

      // Update user
      _currentUser = _currentUser!.copyWith(username: newUsername);

      // Save directly to Firestore
      await _saveUserToFirestore();

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

    // Save to Firestore directly
    await _saveUserToFirestore();

    notifyListeners();
  }

  Future<void> updatePreferences(Map<String, dynamic> newPreferences) async {
    if (_currentUser == null) return;

    final updatedPrefs = Map<String, dynamic>.from(_currentUser!.preferences);
    updatedPrefs.addAll(newPreferences);

    _currentUser = _currentUser!.copyWith(preferences: updatedPrefs);

    // Save to Firestore directly
    await _saveUserToFirestore();

    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      if (_currentUser != null) {
        // Release username
        await _usernameService.releaseUsername(_currentUser!.username);
      }

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

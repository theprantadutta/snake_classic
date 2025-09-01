import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snake_classic/services/username_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UsernameService _usernameService = UsernameService();

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Initialize if needed
      await _googleSignIn.initialize();
      
      // Check if authentication is supported
      if (_googleSignIn.supportsAuthenticate()) {
        // Trigger the authentication flow
        final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

        // Get authentication details
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;

        // Create a new credential for Firebase
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the credential
        final UserCredential result = await _auth.signInWithCredential(credential);
        
        if (result.user != null) {
          await _createUserProfile(result.user!);
        }
        
        return result;
      } else {
        // Fallback or return null if not supported
        return null;
      }
    } catch (e) {
      // Handle error appropriately for production
      return null;
    }
  }

  Future<void> signInAnonymously() async {
    try {
      final UserCredential result = await _auth.signInAnonymously();
      if (result.user != null) {
        await _createUserProfile(result.user!, isAnonymous: true);
      }
    } catch (e) {
      // Error:Error signing in anonymously: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      // Error signing out
    }
  }

  Future<void> _createUserProfile(User user, {bool isAnonymous = false, Map<String, dynamic>? guestData}) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();
      
      if (!docSnapshot.exists) {
        // Generate username
        String username;
        if (guestData != null && guestData['username'] != null) {
          // If migrating from guest, try to keep the username
          username = await _usernameService.findAvailableUsername(guestData['username']);
        } else if (!isAnonymous && user.displayName != null) {
          // Generate from display name for signed-in users
          username = await _usernameService.findAvailableUsername(
            _usernameService.generateUsernameFromDisplayName(user.displayName!),
          );
        } else {
          // Generate random username
          username = await _usernameService.findAvailableUsername(
            _usernameService.generateRandomUsername(),
          );
        }
        
        await userDoc.set({
          'uid': user.uid,
          'displayName': isAnonymous ? 'Anonymous Player' : (user.displayName ?? 'Player'),
          'username': username,
          'email': user.email,
          'photoUrl': user.photoURL,
          'isAnonymous': isAnonymous,
          'joinedDate': FieldValue.serverTimestamp(),
          'lastSeen': FieldValue.serverTimestamp(),
          'status': 'online',
          'highScore': guestData?['highScore'] ?? 0,
          'totalGamesPlayed': guestData?['totalGamesPlayed'] ?? 0,
          'totalScore': guestData?['totalScore'] ?? 0,
          'level': 1,
          'achievements': guestData?['achievements'] ?? [],
          'preferredTheme': guestData?['preferredTheme'] ?? 'classic',
          'soundEnabled': guestData?['soundEnabled'] ?? true,
          'musicEnabled': guestData?['musicEnabled'] ?? true,
          // Social features
          'friends': [],
          'friendRequests': [],
          'sentRequests': [],
          'gameStats': guestData?['gameStats'] ?? {},
          'isPublic': !isAnonymous, // Anonymous users are private by default
          'statusMessage': null,
        });
      } else {
        // User exists, just update last seen and status
        await userDoc.update({
          'lastSeen': FieldValue.serverTimestamp(),
          'status': 'online',
        });
      }
    } catch (e) {
      print('Error creating/updating user profile: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser == null) return null;
    
    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      
      return doc.data();
    } catch (e) {
      // Error:Error getting user profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (currentUser == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update(data);
    } catch (e) {
      // Error:Error updating user profile: $e');
    }
  }

  Future<void> updateHighScore(int score) async {
    if (currentUser == null) return;
    
    try {
      final userDoc = _firestore.collection('users').doc(currentUser!.uid);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        if (!snapshot.exists) return;
        
        final currentHighScore = snapshot.data()?['highScore'] ?? 0;
        final totalGamesPlayed = (snapshot.data()?['totalGamesPlayed'] ?? 0) + 1;
        final totalScore = (snapshot.data()?['totalScore'] ?? 0) + score;
        
        Map<String, dynamic> updates = {
          'totalGamesPlayed': totalGamesPlayed,
          'totalScore': totalScore,
          'lastPlayed': FieldValue.serverTimestamp(),
        };
        
        if (score > currentHighScore) {
          updates['highScore'] = score;
          updates['highScoreDate'] = FieldValue.serverTimestamp();
        }
        
        transaction.update(userDoc, updates);
      });
    } catch (e) {
      // Error:Error updating high score: $e');
    }
  }

  // Username management methods

  Future<bool> updateUsername(String newUsername) async {
    if (currentUser == null) return false;
    
    final result = await _usernameService.updateUsername(currentUser!.uid, newUsername);
    return result.success;
  }

  Future<UsernameValidationResult> validateUsername(String username) async {
    return await _usernameService.validateUsernameComplete(username);
  }

  List<String> generateUsernameSuggestions() {
    return _usernameService.generateUsernameSuggestions();
  }

  Future<List<Map<String, dynamic>>> searchUsersByUsername(String query) async {
    return await _usernameService.searchUsersByUsername(query);
  }

  // Updated method to handle guest data migration
  Future<void> createUserProfileWithGuestData(User user, Map<String, dynamic> guestData, {bool isAnonymous = false}) async {
    await _createUserProfile(user, isAnonymous: isAnonymous, guestData: guestData);
  }
}
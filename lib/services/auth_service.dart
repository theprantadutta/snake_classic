import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> _createUserProfile(User user, {bool isAnonymous = false}) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();
      
      if (!docSnapshot.exists) {
        await userDoc.set({
          'uid': user.uid,
          'displayName': isAnonymous ? 'Anonymous Player' : (user.displayName ?? 'Player'),
          'email': user.email,
          'photoURL': user.photoURL,
          'isAnonymous': isAnonymous,
          'createdAt': FieldValue.serverTimestamp(),
          'lastSignIn': FieldValue.serverTimestamp(),
          'highScore': 0,
          'totalGamesPlayed': 0,
          'totalScore': 0,
          'achievements': [],
          'preferredTheme': 'classic',
          'soundEnabled': true,
          'musicEnabled': true,
        });
      } else {
        await userDoc.update({
          'lastSignIn': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Error:Error creating/updating user profile: $e');
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
}
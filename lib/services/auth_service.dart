import 'dart:math';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static bool _googleSignInInitialized = false;

  static User? get currentFirebaseUser => _auth.currentUser;

  // Must be called ONCE at app startup (e.g. in main()) before any sign-in call
  static Future<void> initGoogleSignIn() async {
    if (_googleSignInInitialized) return;
    await _googleSignIn.initialize();
    _googleSignInInitialized = true;
  }

  // Generate 6-digit random OTP
  static String generateOTP() {
    Random rnd = Random();
    int code = 100000 + rnd.nextInt(900000);
    return code.toString();
  }

  // Admin Check
  static bool isAdminCredentials(String email, String password) {
    return email.toLowerCase() == "kemo.magdy" && password == "kkkk";
  }

  // Get User Profile from Firestore
  static Future<UserModel?> getCurrentUserProfile() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, user.uid);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching profile: $e");
      }
    }
    return null;
  }

  // Save / Update User Profile
  static Future<void> saveUserProfile(UserModel userModel) async {
    await _firestore
        .collection('users')
        .doc(userModel.uid)
        .set(userModel.toMap());
  }

  // Sign In with Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      await initGoogleSignIn();

      if (!_googleSignIn.supportsAuthenticate()) {
        if (kDebugMode) {
          print("This platform doesn't support explicit authenticate()");
        }
        return null;
      }

      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();

      // authentication is now synchronous and only carries idToken
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (kDebugMode) {
        print("Google Sign In Error: ${e.code} - ${e.description}");
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print("Google Sign In Error: $e");
      }
      return null;
    }
  }

  // Sign Out
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
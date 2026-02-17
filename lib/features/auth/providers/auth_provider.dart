// lib/features/auth/providers/auth_provider.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:mobimart_app/features/models/user_model.dart';
import '../services/google_auth.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<User?>? _authSub;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// ================= CONSTRUCTOR =================
  AuthProvider() {
    _listenToAuthChanges();
  }

  /// ================= GETTERS =================
  UserModel? get currentUser => _user;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// =========================================================
  /// AUTH STATE LISTENER (CORE AUTH ENGINE)
  /// =========================================================
  void _listenToAuthChanges() {
    _authSub = _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        _user = null;
        notifyListeners();
        return;
      }

      await _loadFirestoreUser(firebaseUser.uid);
    });
  }

  /// ================= LOAD USER FROM FIRESTORE =================
  Future<void> _loadFirestoreUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        _user = UserModel.fromFirestore(doc);
      } else {
        _user = null;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Firestore user fetch error: $e');
    }
  }

  /// ================= REGISTER =================
  Future<String?> register({
    required String name,
    required String email,
    required String password,
    String role = 'user',
    String? photoUrl,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = cred.user;
      if (firebaseUser == null) {
        return 'Registration failed';
      }

      final userModel = UserModel(
        uid: firebaseUser.uid,
        name: name,
        email: email.trim(),
        role: role,
        photoUrl: photoUrl,
        isActive: true,
        wishlist: [],
        cart: [],
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(userModel.toFirestore());

      /// Send verification email
      await firebaseUser.sendEmailVerification();

      /// Prevent partial auth session (important for web)
      await _auth.signOut();

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Registration failed';
    } catch (e) {
      return 'Registration failed: $e';
    }
  }

  /// ================= EMAIL LOGIN =================
  Future<String?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = cred.user;
      if (firebaseUser == null) {
        return 'Login failed';
      }

      /// Refresh verification state
      try {
        await firebaseUser.reload();
      } catch (_) {}

      final refreshedUser = _auth.currentUser;

      if (refreshedUser == null) {
        return 'Login failed';
      }

      // WARNING ONLY: don't block old users
      if (!refreshedUser.emailVerified) {
        // Return special string to let LoginScreen show a warning
        return 'email not verified';
      }

      /// authStateChanges handles user loading
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Login failed';
    } catch (e) {
      debugPrint('Login error: $e');
      return 'Login failed. Try again.';
    }
  }

  /// ================= FORCE LOGIN (OLD USERS) =================
  Future<void> forceLogin(String email, String password) async {
    // Simply sign in again ignoring email verification
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// ================= GOOGLE LOGIN =================
  Future<String?> loginWithGoogle({
    required GoogleSignInAccount account,
  }) async {
    try {
      _setLoading(true);

      final googleAuth = await account.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        _setLoading(false);
        return "Google authentication failed";
      }

      /// Ensure Firestore user exists
      final docRef = _firestore.collection('users').doc(firebaseUser.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        final newUser = UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? "User",
          email: firebaseUser.email ?? "",
          role: 'user',
          photoUrl: firebaseUser.photoURL,
          isActive: true,
          wishlist: [],
          cart: [],
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        );

        await docRef.set(newUser.toFirestore());
      }

      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message ?? "Google sign-in failed";
    } catch (e) {
      debugPrint("Google login error: $e");
      _setLoading(false);
      return "Something went wrong. Try again.";
    }
  }

  /// ================= PASSWORD RESET =================
  Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'Invalid email address.';
        case 'missing-email':
          return 'Please enter your email.';
        default:
          return 'Unable to send reset email.';
      }
    } catch (_) {
      return 'Something went wrong.';
    }
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    await GoogleAuth.signOut();
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  /// ================= CLEANUP =================
  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

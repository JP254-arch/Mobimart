// lib/features/auth/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import 'google_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// =========================================================
  /// REGISTER USER (Email/Password)
  /// =========================================================
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String role = 'customer',
    String? photoUrl,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final firebaseUser = cred.user;
      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'registration-failed',
          message: 'User creation failed.',
        );
      }

      final user = AppUser(
        id: firebaseUser.uid,
        name: name.trim(),
        email: email.trim().toLowerCase(),
        role: role,
        photoUrl: photoUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      /// Save profile in Firestore
      await _db.collection('users').doc(firebaseUser.uid).set(user.toMap());

      /// Send verification email
      await firebaseUser.sendEmailVerification();

      /// Immediately sign out to prevent partial web auth session
      await _auth.signOut();

      print('User registered successfully: ${user.email}');
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  /// =========================================================
  /// LOGIN USER (Email/Password)
  /// =========================================================
  Future<void> login({required String email, required String password}) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      User? user = cred.user;
      if (user == null) throw FirebaseAuthException(
          code: 'login-failed', message: 'Login failed.');

      /// Refresh verification state
      await user.reload();
      user = _auth.currentUser;

      if (user == null) throw FirebaseAuthException(
          code: 'login-failed', message: 'Login failed.');

      /// Enforce email verification
      if (!user.emailVerified) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Please verify your email before logging in.',
        );
      }

      print('User logged in successfully: ${user.email}');
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  /// =========================================================
  /// LOGIN WITH GOOGLE
  /// =========================================================
  Future<void> loginWithGoogle() async {
    try {
      final account = await GoogleAuth.signIn();
      if (account == null) {
        throw FirebaseAuthException(
          code: 'google-cancelled',
          message: 'Google sign-in cancelled by user.',
        );
      }

      final googleAuth = await account.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'google-failed',
          message: 'Google authentication failed.',
        );
      }

      /// Ensure Firestore user exists
      final docRef = _db.collection('users').doc(firebaseUser.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        final newUser = AppUser(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          role: 'user',
          photoUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await docRef.set(newUser.toMap());
        print('New Google user created: ${newUser.email}');
      } else {
        print('Google user exists: ${firebaseUser.email}');
      }
    } catch (e) {
      print('Google login error: $e');
      rethrow;
    }
  }

  /// =========================================================
  /// SEND PASSWORD RESET EMAIL
  /// =========================================================
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
      print('Password reset email sent to: $email');
    } catch (e) {
      print('Password reset error: $e');
      rethrow;
    }
  }

  /// =========================================================
  /// FETCH USER PROFILE FROM FIRESTORE
  /// =========================================================
  Future<AppUser?> fetchUser(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return AppUser.fromMap(doc.id, doc.data()!);
    } catch (e) {
      print('Fetch user error: $e');
      return null;
    }
  }

  /// =========================================================
  /// CURRENT FIREBASE USER
  /// =========================================================
  User? get firebaseUser => _auth.currentUser;

  /// =========================================================
  /// LOGOUT
  /// =========================================================
  Future<void> logout() async {
    try {
      await GoogleAuth.signOut();
      await _auth.signOut();
      print('User logged out successfully');
    } catch (e) {
      print('Logout error: $e');
    }
  }
}
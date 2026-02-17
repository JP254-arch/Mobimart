import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ============================================================
  /// REGISTER USER
  /// ============================================================
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String role = 'customer',
  }) async {
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
    );

    /// Save profile in Firestore
    await _db.collection('users').doc(firebaseUser.uid).set({
      ...user.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    /// Send verification email
    await firebaseUser.sendEmailVerification();

    /// IMPORTANT:
    /// Immediately sign out to avoid web auth mismatch
    await _auth.signOut();
  }

  /// ============================================================
  /// LOGIN USER
  /// ============================================================
  Future<void> login({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );

    User? user = cred.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'login-failed',
        message: 'Login failed.',
      );
    }

    /// Web-safe reload (prevents LegacyJavaScriptObject crash)
    if (!user.emailVerified) {
      try {
        await user.reload();
        user = _auth.currentUser;
      } catch (_) {
        // ignore web reload edge-case
      }
    }

    if (user == null) {
      throw FirebaseAuthException(
        code: 'login-failed',
        message: 'Login failed.',
      );
    }

    /// Enforce email verification
    if (!user.emailVerified) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'email-not-verified',
        message: 'Please verify your email before logging in.',
      );
    }

    /// DO NOT fetch Firestore user here.
    /// AuthProvider listener will handle that automatically.
  }

  /// ============================================================
  /// PASSWORD RESET
  /// ============================================================
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
  }

  /// ============================================================
  /// FETCH FIRESTORE USER PROFILE
  /// (Used by AuthProvider listener)
  /// ============================================================
  Future<AppUser?> fetchUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists) return null;

    return AppUser.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  /// ============================================================
  /// CURRENT FIREBASE USER
  /// ============================================================
  User? get firebaseUser => _auth.currentUser;

  /// ============================================================
  /// LOGOUT
  /// ============================================================
  Future<void> logout() async {
    await _auth.signOut();
  }
}

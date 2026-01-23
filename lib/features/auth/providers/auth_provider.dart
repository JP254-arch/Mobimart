import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobimart_app/features/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ================= GETTERS =================
  UserModel? get currentUser => _user;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  /// ================= FETCH USER =================
  Future<void> fetchUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      _user = null;
      notifyListeners();
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        _user = UserModel.fromFirestore(doc);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching user: $e');
      rethrow;
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
        email: email,
        password: password,
      );

      final userModel = UserModel(
        uid: cred.user!.uid,
        name: name,
        email: email,
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
          .doc(cred.user!.uid)
          .set(userModel.toFirestore());

      _user = userModel;
      notifyListeners();

      // Send email verification
      await cred.user!.sendEmailVerification();

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Registration failed';
    } catch (e) {
      return 'Registration failed: $e';
    }
  }

  /// ================= LOGIN =================
  Future<String?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user == null) return 'Login failed';

      if (!user.emailVerified) {
        await _auth.signOut();
        return 'Please verify your email before logging in.';
      }

      await fetchUser();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Login failed';
    } catch (e) {
      return 'Login failed: $e';
    }
  }

  /// ================= SET USER =================
  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }
}

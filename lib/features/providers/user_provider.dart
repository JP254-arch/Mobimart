// lib/features/providers/user_provider.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobimart_app/features/models/product_model.dart';
import 'package:mobimart_app/features/models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ================= GETTERS =================
  UserModel? get currentUser => _user;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isRegularUser => _user?.isUser ?? false;

  List<ProductModel> get wishlist => _user?.wishlist ?? [];
  List<ProductModel> get cart => _user?.cart ?? [];

  /// ================= FETCH USER =================
  Future<void> fetchUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      _user = null;
      notifyListeners();
      return;
    }

    final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (!doc.exists) return;

    _user = UserModel.fromFirestore(doc);
    notifyListeners();
  }

  /// ================= LOGIN =================
  /// Returns null if successful, otherwise error message
  Future<String?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _firestore.collection('users').doc(cred.user!.uid).get();
      if (!userDoc.exists) return 'User not found';

      _user = UserModel.fromFirestore(userDoc);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Login failed: $e';
    }
  }

  /// ================= REGISTER =================
  Future<String?> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        uid: cred.user!.uid,
        name: name,
        email: email,
        phone: phone,
        role: 'user',
        isActive: true,
        wishlist: [],
        cart: [],
        createdAt: Timestamp.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(user.toFirestore());
      _user = user;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Registration failed: $e';
    }
  }

  /// ================= SET USER =================
  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  /// ================= UPDATE SINGLE FIELD =================
  Future<void> updateField(String field, String value) async {
    if (_user == null) return;

    await _firestore.collection('users').doc(_user!.uid).update({
      field: value,
      'updatedAt': Timestamp.now(),
    });

    _user = _user!.copyWith(
      name: field == 'name' ? value : null,
      email: field == 'email' ? value : null,
      phone: field == 'phone' ? value : null,
      photoUrl: field == 'photoUrl' ? value : null,
    );

    notifyListeners();
  }

  /// ================= UPDATE PASSWORD =================
  Future<String?> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) return 'Not authenticated';

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  /// ================= WISHLIST =================
  Future<void> addToWishlist(ProductModel product) async {
    if (_user == null) return;

    if (!_user!.wishlist.any((p) => p.id == product.id)) {
      final updatedWishlist = [..._user!.wishlist, product];
      await _firestore.collection('users').doc(_user!.uid).update({
        'wishlist': updatedWishlist.map((e) => e.toJson()).toList(),
        'updatedAt': Timestamp.now(),
      });

      _user = _user!.copyWith(wishlist: updatedWishlist);
      notifyListeners();
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    if (_user == null) return;

    final updatedWishlist = _user!.wishlist.where((p) => p.id != productId).toList();
    await _firestore.collection('users').doc(_user!.uid).update({
      'wishlist': updatedWishlist.map((e) => e.toJson()).toList(),
      'updatedAt': Timestamp.now(),
    });

    _user = _user!.copyWith(wishlist: updatedWishlist);
    notifyListeners();
  }

  /// ================= CART =================
  Future<void> addToCart(ProductModel product) async {
    if (_user == null) return;

    if (!_user!.cart.any((p) => p.id == product.id)) {
      final updatedCart = [..._user!.cart, product];
      await _firestore.collection('users').doc(_user!.uid).update({
        'cart': updatedCart.map((e) => e.toJson()).toList(),
        'updatedAt': Timestamp.now(),
      });

      _user = _user!.copyWith(cart: updatedCart);
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String productId) async {
    if (_user == null) return;

    final updatedCart = _user!.cart.where((p) => p.id != productId).toList();
    await _firestore.collection('users').doc(_user!.uid).update({
      'cart': updatedCart.map((e) => e.toJson()).toList(),
      'updatedAt': Timestamp.now(),
    });

    _user = _user!.copyWith(cart: updatedCart);
    notifyListeners();
  }

  Future<void> clearCart() async {
    if (_user == null) return;

    await _firestore.collection('users').doc(_user!.uid).update({
      'cart': [],
      'updatedAt': Timestamp.now(),
    });

    _user = _user!.copyWith(cart: []);
    notifyListeners();
  }

  /// ================= PICK & UPLOAD PROFILE PHOTO =================
  Future<String?> uploadProfilePhoto() async {
    if (_user == null) return 'User not logged in';

    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );

      if (image == null) return null;

      final file = File(image.path);
      final ref = FirebaseStorage.instance
          .ref()
          .child('users/profile_photos/${_user!.uid}.jpg');

      await ref.putFile(file);
      final photoUrl = await ref.getDownloadURL();

      await _firestore.collection('users').doc(_user!.uid).update({
        'photoUrl': photoUrl,
        'updatedAt': Timestamp.now(),
      });

      _user = _user!.copyWith(photoUrl: photoUrl);
      notifyListeners();

      return null;
    } catch (e) {
      return 'Failed to upload photo';
    }
  }
}

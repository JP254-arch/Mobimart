import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobimart_app/features/models/product_model.dart';
import 'package:mobimart_app/features/models/user_model.dart';
import 'package:mobimart_app/features/auth/services/google_auth.dart';
import 'package:http/http.dart' as http;

class UserProvider with ChangeNotifier {
  UserModel? _user;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ================= GETTERS =================
  UserModel? get currentUser => _user;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.role == 'admin';
  bool get isRegularUser => _user?.role == 'user';

  List<ProductModel> get wishlist =>
      _user?.wishlist.map((p) => p).toList() ?? [];
  List<ProductModel> get cart => _user?.cart.map((p) => p).toList() ?? [];

  /// ================= SET CURRENT USER =================
  void setCurrentUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  /// ================= FETCH USER =================
  Future<void> fetchUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      _user = null;
      notifyListeners();
      return;
    }
    try {
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (!doc.exists) return;

      _user = UserModel.fromFirestore(doc);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching user: $e');
    }
  }

  /// ================= LOGIN =================
  Future<String?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc = await _firestore
          .collection('users')
          .doc(cred.user!.uid)
          .get();
      if (!doc.exists) return 'User not found';

      _user = UserModel.fromFirestore(doc);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Login failed: $e';
    }
  }

  /// ================= GOOGLE SIGN-IN / SIGN-UP =================
  Future<String?> loginWithGoogle({GoogleSignInAccount? account}) async {
    try {
      final googleUser = account ?? await GoogleAuth.signIn();
      if (googleUser == null) return 'Sign-in cancelled';

      final googleAuth = await googleUser.authentication;
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        return 'Google authentication failed';
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final authResult = await _auth.signInWithCredential(credential);

      final userDoc = await _firestore
          .collection('users')
          .doc(authResult.user!.uid)
          .get();

      if (!userDoc.exists) {
        final newUser = UserModel(
          uid: authResult.user!.uid,
          name: authResult.user!.displayName ?? '',
          email: authResult.user!.email ?? '',
          phone: null,
          role: 'user',
          isActive: true,
          wishlist: [],
          cart: [],
          createdAt: Timestamp.now(),
          photoUrl: authResult.user!.photoURL ?? '',
        );

        await _firestore
            .collection('users')
            .doc(newUser.uid)
            .set(newUser.toFirestore());
        _user = newUser;
      } else {
        _user = UserModel.fromFirestore(userDoc);
      }

      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Google login failed: $e';
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

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toFirestore());
      setCurrentUser(user);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Registration failed: $e';
    }
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  /// ================= UPDATE FIELD =================
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

  /// ================= WISHLIST =================
  Future<void> addToWishlist(ProductModel product) async {
    if (_user == null) return;
    if (_user!.wishlist.any((p) => p.id == product.id)) return;

    final updatedWishlist = [..._user!.wishlist, product];

    await _firestore.collection('users').doc(_user!.uid).update({
      'wishlist': updatedWishlist.map((p) => p.toJson()).toList(),
      'updatedAt': Timestamp.now(),
    });

    _user = _user!.copyWith(wishlist: updatedWishlist);
    notifyListeners();
  }

  Future<void> removeFromWishlist(String productId) async {
    if (_user == null) return;

    final updatedWishlist = _user!.wishlist
        .where((p) => p.id != productId)
        .toList();

    await _firestore.collection('users').doc(_user!.uid).update({
      'wishlist': updatedWishlist.map((p) => p.toJson()).toList(),
      'updatedAt': Timestamp.now(),
    });

    _user = _user!.copyWith(wishlist: updatedWishlist);
    notifyListeners();
  }

  /// ================= CART =================
  Future<void> addToCart(ProductModel product) async {
    if (_user == null) return;

    final index = _user!.cart.indexWhere((p) => p.id == product.id);
    final updatedCart = [..._user!.cart];

    if (index == -1) {
      updatedCart.add(product);
    } else {
      updatedCart[index].quantity += product.quantity;
    }

    await _firestore.collection('users').doc(_user!.uid).update({
      'cart': updatedCart.map((p) => p.toJson()).toList(),
      'updatedAt': Timestamp.now(),
    });

    _user = _user!.copyWith(cart: updatedCart);
    notifyListeners();
  }

  Future<void> removeFromCart(String productId) async {
    if (_user == null) return;

    final updatedCart = _user!.cart.where((p) => p.id != productId).toList();

    await _firestore.collection('users').doc(_user!.uid).update({
      'cart': updatedCart.map((p) => p.toJson()).toList(),
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

  void updateCartItemQuantity(String productId, int quantity) {
    if (_user == null) return;

    final index = _user!.cart.indexWhere((p) => p.id == productId);
    if (index == -1) return;

    _user!.cart[index].quantity = quantity;

    _firestore.collection('users').doc(_user!.uid).update({
      'cart': _user!.cart.map((p) => p.toJson()).toList(),
      'updatedAt': Timestamp.now(),
    });

    notifyListeners();
  }

  /// ================= DARAJA PAYMENT =================
  Future<String?> initiateDarajaPayment({
    required String phone,
    required double amount,
  }) async {
    if (_user == null) return 'User not logged in';

    try {
      final transactionRef = _firestore.collection('transactions').doc();

      await transactionRef.set({
        'userId': _user!.uid,
        'phone': phone,
        'amount': amount,
        'items': _user!.cart.map((p) => p.toJson()).toList(),
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      final response = await http.post(
        Uri.parse('https://supercultivated-limonitic-adelia.ngrok-free.dev/stkpush'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'amount': amount,
          'transactionId': transactionRef.id,
          'userId': _user!.uid,
        }),
      );

      if (response.statusCode != 200) {
        throw 'Failed to initiate STK Push';
      }

      final data = jsonDecode(response.body);
      debugPrint('STK Push Response: $data');

      if (data['CheckoutRequestID'] != null) {
        await transactionRef.update({
          'checkoutRequestId': data['CheckoutRequestID'],
        });
      }

      return transactionRef.id;
    } catch (e) {
      debugPrint('Daraja payment error: $e');
      return null;
    }
  }

  /// ================= REAL-TIME PAYMENT LISTENER =================
  /// This replaces polling and immediately notifies the UI
  Future<void> listenForPaymentStatus({
    required String transactionId,
    required void Function(bool success) onStatusChange,
  }) async {
    final ref = _firestore.collection('transactions').doc(transactionId);

    ref.snapshots().listen((snapshot) async {
      if (!snapshot.exists) return;
      final status = snapshot.get('status') as String? ?? 'pending';

      if (status == 'success') {
        await moveCartToOrders(transactionId: transactionId);
        await clearCart();
        onStatusChange(true);
      } else if (status == 'failed' || status == 'cancelled') {
        onStatusChange(false);
      }
    });
  }

  /// ================= MOVE CART TO ORDERS AND CLEAR CART =================
  Future<void> moveCartToOrders({String? transactionId}) async {
    if (_user == null || _user!.cart.isEmpty) return;

    final cartItems = _user!.cart;

    // 1. Create the order
    final orderRef = _firestore.collection('orders').doc();
    await orderRef.set({
      'userId': _user!.uid,
      'items': cartItems.map((p) => p.toJson()).toList(),
      'transactionId': transactionId,
      'status': 'paid',
      'createdAt': Timestamp.now(),
    });

    // 2. Clear cart in Firestore
    await _firestore.collection('users').doc(_user!.uid).update({
      'cart': [],
      'updatedAt': Timestamp.now(),
    });

    // 3. Clear cart locally and notify listeners
    _user = _user!.copyWith(cart: []);
    notifyListeners();
  }

  /// ================= PROFILE PHOTO =================
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
      final ref = FirebaseStorage.instance.ref(
        'users/profile_photos/${_user!.uid}.jpg',
      );

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

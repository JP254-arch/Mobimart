import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobimart_app/features/models/product_model.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String role; // user | admin
  final String? photoUrl;
  final bool isActive;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  final List<ProductModel> wishlist;
  final List<ProductModel> cart;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.photoUrl,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.wishlist = const [],
    this.cart = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      role: data['role'] ?? 'user',
      photoUrl: data['photoUrl'],
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      wishlist: (data['wishlist'] as List<dynamic>?)
              ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      cart: (data['cart'] as List<dynamic>?)
              ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'photoUrl': photoUrl,
      'isActive': isActive,
      'wishlist': wishlist.map((e) => e.toJson()).toList(),
      'cart': cart.map((e) => e.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': Timestamp.now(),
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? photoUrl,
    bool? isActive,
    List<ProductModel>? wishlist,
    List<ProductModel>? cart,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      isActive: isActive ?? this.isActive,
      wishlist: wishlist ?? this.wishlist,
      cart: cart ?? this.cart,
      createdAt: createdAt,
      updatedAt: Timestamp.now(),
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user';
}

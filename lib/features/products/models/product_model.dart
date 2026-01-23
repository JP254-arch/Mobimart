// lib/features/admin/models/product_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
  });

  // ================== From Firestore Document ==================
  factory ProductModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  // ================== From Map (optional) ==================
  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  // ================== To Map ==================
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
    };
  }
}

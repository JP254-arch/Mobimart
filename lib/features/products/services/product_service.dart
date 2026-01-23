// lib/features/products/services/product_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final _db = FirebaseFirestore.instance;

  /// Returns a stream of products from Firestore
  Stream<List<ProductModel>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}

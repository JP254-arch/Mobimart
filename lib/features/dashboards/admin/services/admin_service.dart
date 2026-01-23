// lib/features/dashboards/admin/services/admin_service.dart

import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../../../products/models/product_model.dart';
import '../../../orders/models/order_model.dart';

class AdminService {
  final firestore.FirebaseFirestore _db = firestore.FirebaseFirestore.instance;

  // -------------------- Products CRUD --------------------

  /// Add a new product to Firestore
  Future<void> addProduct(ProductModel product) async {
    await _db.collection('products').add(product.toMap());
  }

  /// Update an existing product in Firestore
  Future<void> updateProduct(ProductModel product) async {
    await _db.collection('products').doc(product.id).update(product.toMap());
  }

  /// Delete a product from Firestore
  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  // -------------------- Orders fetching --------------------

  /// Fetch all orders as a stream
  Stream<List<Order>> getOrders() {
    return _db.collection('orders').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data(); // No cast needed
        return Order.fromMap(data, doc.id);
      }).toList();
    });
  }

  // -------------------- Update order status --------------------

  /// Update the status of a specific order
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db.collection('orders').doc(orderId).update({'status': status});
  }
}

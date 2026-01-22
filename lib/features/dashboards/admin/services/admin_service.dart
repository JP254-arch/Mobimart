import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../../../products/models/product_model.dart';
import '../../../orders/models/order_model.dart';

class AdminService {
  final firestore.FirebaseFirestore _db = firestore.FirebaseFirestore.instance;

  // -------------------- Products CRUD --------------------
  Future<void> addProduct(Product product) async {
    await _db.collection('products').add(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    await _db.collection('products').doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  // -------------------- Orders fetching --------------------
  Stream<List<Order>> getOrders() {
    return _db.collection('orders').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Order(
            id: doc.id,
            userId: doc['userId'],
            total: (doc['total'] as num).toDouble(),
            status: doc['status'],
          )).toList();
    });
  }

  // -------------------- Update order status --------------------
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db.collection('orders').doc(orderId).update({'status': status});
  }
}

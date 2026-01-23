// lib/features/orders/models/order_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobimart_app/features/models/product_model.dart';

class Order {
  final String id;
  final List<ProductModel> items;
  final double total;
  final DateTime date;
  final String status;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.date,
    this.status = 'Pending',
  });

  // Convert from Map (Firestore)
  factory Order.fromMap(Map<String, dynamic> data, String id) {
    // Firestore stores date as Timestamp
    final Timestamp? timestamp = data['date'] as Timestamp?;
    return Order(
      id: id,
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => ProductModel.fromMap(item as Map<String, dynamic>, item['id'] ?? ''))
          .toList(),
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      date: timestamp?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'Pending',
    );
  }

  // Convert to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'date': Timestamp.fromDate(date),
      'status': status,
    };
  }
}

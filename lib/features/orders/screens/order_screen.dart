import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobimart_app/features/orders/models/order_model.dart' as order_model;

class OrdersScreen extends StatelessWidget {
  OrdersScreen({super.key}); // non-const due to dynamic content

  final CollectionReference ordersCollection =
      FirebaseFirestore.instance.collection('orders');

  static const String routeName = '/orders'; // give a proper route name

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders'), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<QueryDocumentSnapshot> orderDocs = snapshot.data?.docs ?? [];

          if (orderDocs.isEmpty) {
            return const Center(child: Text('You have no orders yet'));
          }

          final List<order_model.Order> orders = orderDocs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return order_model.Order.fromMap(data, doc.id);
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) => OrderCard(order: orders[index]),
          );
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final order_model.Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (order.status) {
      case 'Delivered':
        statusColor = Colors.green;
        break;
      case 'Shipped':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()), // replaces deprecated withOpacity
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /* Header Row */
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order ID: ${order.id}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                order.status,
                style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          /* Date */
          Text(
            'Date: ${order.date.toLocal().toString().split(' ')[0]}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const Divider(height: 24),
          /* Items */
          ...order.items.map(
            (item) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text('KSh ${item.price.toStringAsFixed(0)}'),
              ],
            ),
          ),
          const Divider(height: 24),
          /* Total */
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'KSh ${order.total.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

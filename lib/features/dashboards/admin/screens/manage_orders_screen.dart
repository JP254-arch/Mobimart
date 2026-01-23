// lib/features/dashboards/admin/screens/manage_orders_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  static const String routeName = '/admin/manage-orders';

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  final CollectionReference ordersCollection =
      FirebaseFirestore.instance.collection('orders');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Orders'), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersCollection.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orderDocs = snapshot.data?.docs ?? [];

          if (orderDocs.isEmpty) {
            return const Center(child: Text('No orders found'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orderDocs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orderDocs[index];
              final orderData = {
                'id': order.id,
                'userName': order['userName'] ?? 'Unknown',
                'totalAmount': (order['totalAmount'] as num?)?.toDouble() ?? 0.0,
                'status': order['status'] ?? 'Pending',
                'createdAt': order['createdAt'] != null
                    ? (order['createdAt'] as Timestamp).toDate()
                    : DateTime.now(),
                'items': List.from(order['items'] ?? []),
              };

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text('Order by: ${orderData['userName']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total: \$${orderData['totalAmount'].toStringAsFixed(2)}'),
                      Text('Status: ${orderData['status']}'),
                      Text(
                        'Date: ${orderData['createdAt'].toLocal().toString().split(' ')[0]}',
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.blue),
                    onPressed: () {
                      _showOrderDetails(orderData);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order Details (${order['id']})'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text('User: ${order['userName']}'),
              Text('Total Amount: \$${order['totalAmount'].toStringAsFixed(2)}'),
              Text('Status: ${order['status']}'),
              const SizedBox(height: 12),
              const Text(
                'Items:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...List.generate(order['items'].length, (i) {
                final item = order['items'][i];
                return Text(
                  '- ${item['name']} x ${item['quantity']} (\$${item['price']})',
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

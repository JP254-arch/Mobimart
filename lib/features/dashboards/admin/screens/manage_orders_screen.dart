// lib/features/admin/screens/manage_orders_screen.dart

import 'package:flutter/material.dart';

class ManageOrdersScreen extends StatelessWidget {
  const ManageOrdersScreen({super.key});

  static const String routeName = '/admin/manage-orders';

  // Mock orders data
  final List<Map<String, String>> orders = const [
    {'id': 'ORD001', 'status': 'Delivered', 'user': 'John Doe'},
    {'id': 'ORD002', 'status': 'Shipped', 'user': 'Jane Smith'},
    {'id': 'ORD003', 'status': 'Pending', 'user': 'Alice Johnson'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Orders"),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final order = orders[index];
          return ListTile(
            leading: const Icon(Icons.receipt_long),
            title: Text("Order ${order['id']}"),
            subtitle: Text("User: ${order['user']}"),
            trailing: Text(
              order['status']!,
              style: TextStyle(
                color: order['status'] == 'Delivered'
                    ? Colors.green
                    : (order['status'] == 'Shipped' ? Colors.orange : Colors.blue),
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              // TODO: View order details
            },
          );
        },
      ),
    );
  }
}

// lib/features/admin/screens/manage_products_screen.dart

import 'package:flutter/material.dart';
import 'product_form_screen.dart';

class ManageProductsScreen extends StatelessWidget {
  const ManageProductsScreen({super.key});

  static const String routeName = '/admin/manage-products';

  // Mock product data
  final List<Map<String, dynamic>> mockProducts = const [
    {
      "name": "Mobimart Sneakers",
      "category": "Shoes",
      "price": 3500,
      "description": "Comfortable running sneakers.",
    },
    {
      "name": "Mobimart Backpack",
      "category": "Bags",
      "price": 2500,
      "description": "Spacious backpack.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Products")),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: mockProducts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final product = mockProducts[index];
          return Card(
            child: ListTile(
              title: Text(product['name']),
              subtitle: Text("${product['category']} \nKSh ${product['price']}"),
              isThreeLine: true,
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductFormScreen(productData: product),
                    ),
                  );
                },
                child: const Text("Edit"),
              ),
            ),
          );
        },
      ),
    );
  }
}

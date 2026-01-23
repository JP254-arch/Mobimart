// lib/features/dashboards/admin/screens/manage_products_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_form_screen.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  static const String routeName = '/admin/manage-products';

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final CollectionReference productsCollection =
      FirebaseFirestore.instance.collection('products');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Products'), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: productsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final productDocs = snapshot.data?.docs ?? [];

          if (productDocs.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemCount: productDocs.length,
            itemBuilder: (context, index) {
              final product = productDocs[index];
              final productData = {
                'id': product.id,
                'name': product['name'] ?? '',
                'price': product['price']?.toDouble() ?? 0.0,
                'category': product['category'] ?? '',
                'description': product['description'] ?? '',
                'imageUrl': product['imageUrl'] ?? '',
              };

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: productData['imageUrl'] != ''
                      ? Image.network(
                          productData['imageUrl'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image, size: 50),
                  title: Text(productData['name']),
                  subtitle: Text(
                    'Category: ${productData['category']}\nPrice: \$${productData['price'].toStringAsFixed(2)}',
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // EDIT BUTTON
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editProduct(productData),
                      ),
                      // DELETE BUTTON
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(product.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ================= ADD PRODUCT =================
  Future<void> _addProduct() async {
    final scaffoldContext = context;
    final newProduct = await Navigator.push(
      scaffoldContext,
      MaterialPageRoute(builder: (_) => const ProductFormScreen()),
    );
    if (!mounted) return;
    if (newProduct != null) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        const SnackBar(content: Text('Product added')),
      );
    }
  }

  // ================= EDIT PRODUCT =================
  Future<void> _editProduct(Map<String, dynamic> productData) async {
    final scaffoldContext = context;
    final updatedProduct = await Navigator.push(
      scaffoldContext,
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(productData: productData),
      ),
    );
    if (!mounted) return;
    if (updatedProduct != null) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        const SnackBar(content: Text('Product updated')),
      );
    }
  }

  // ================= DELETE PRODUCT =================
  Future<void> _deleteProduct(String productId) async {
    final scaffoldContext = context;
    final confirm = await showDialog<bool>(
      context: scaffoldContext,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(scaffoldContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(scaffoldContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirm == true) {
      await productsCollection.doc(productId).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        const SnackBar(content: Text('Product deleted')),
      );
    }
  }
}

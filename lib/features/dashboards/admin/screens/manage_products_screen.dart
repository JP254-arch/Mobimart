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

  String searchQuery = '';
  String selectedCategory = 'All';
  List<String> categories = ['All'];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final snapshot = await productsCollection.get();
    final categoriesSet = <String>{};
    for (var doc in snapshot.docs) {
      final category = doc['category'] ?? '';
      if (category.isNotEmpty) categoriesSet.add(category);
    }
    if (!mounted) return;
    setState(() {
      categories = ['All', ...categoriesSet];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Manage Products'), centerTitle: true),
      body: Column(
        children: [
          // ================= SEARCH BAR =================
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // ================= CATEGORY FILTER =================
          if (categories.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),
            ),

          const SizedBox(height: 12),

          // ================= PRODUCT LIST =================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: productsCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var productDocs = snapshot.data?.docs ?? [];

                // Apply search filter
                if (searchQuery.isNotEmpty) {
                  productDocs = productDocs.where((doc) {
                    final name = (doc['name'] ?? '').toString().toLowerCase();
                    return name.contains(searchQuery);
                  }).toList();
                }

                // Apply category filter
                if (selectedCategory != 'All') {
                  productDocs = productDocs.where((doc) {
                    final category = doc['category'] ?? '';
                    return category == selectedCategory;
                  }).toList();
                }

                if (productDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Oops! No products here 😢',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try another product or category or check back later.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Browse Other Categories'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
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
                          'Category: ${productData['category']}\nPrice: KES ${productData['price'].toStringAsFixed(2)}',
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ================= ADD PRODUCT =================
  Future<void> _addProduct() async {
    if (!mounted) return;
    final newProduct = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductFormScreen()),
    );
    if (!mounted) return;
    if (newProduct != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Product added')));
    }
  }

  // ================= EDIT PRODUCT =================
  Future<void> _editProduct(Map<String, dynamic> productData) async {
    if (!mounted) return;
    final updatedProduct = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(productData: productData),
      ),
    );
    if (!mounted) return;
    if (updatedProduct != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Product updated')));
    }
  }

  // ================= DELETE PRODUCT =================
  Future<void> _deleteProduct(String productId) async {
    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted || confirm != true) return;

    await productsCollection.doc(productId).delete();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Product deleted')));
  }
}
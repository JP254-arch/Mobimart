// lib/features/admin/screens/product_form_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.productData});

  static const String routeName = '/admin/product-form';

  /// If null → Create product
  /// If not null → Edit product
  final Map<String, dynamic>? productData;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final CollectionReference productsCollection = FirebaseFirestore.instance
      .collection('products');

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _categoryController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;

  bool get isEditMode => widget.productData != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.productData?['name'] ?? '',
    );
    _priceController = TextEditingController(
      text: widget.productData?['price']?.toString() ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.productData?['category'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.productData?['description'] ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.productData?['imageUrl'] ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final product = {
      'name': _nameController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
      'category': _categoryController.text.trim(),
      'description': _descriptionController.text.trim(),
      'imageUrl': _imageUrlController.text.trim(),
    };

    try {
      if (isEditMode) {
        // Update existing product
        await productsCollection.doc(widget.productData!['id']).update(product);

        if (!mounted) return; // <-- Async-safe check
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Product updated')));
      } else {
        // Add new product
        await productsCollection.add(product);

        if (!mounted) return; // <-- Async-safe check
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Product added')));
      }

      if (!mounted) return; // <-- Async-safe check before navigation
      Navigator.pop(context, product);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Product' : 'Add Product'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /* Name */
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Name is required'
                    : null,
              ),
              const SizedBox(height: 16),

              /* Price */
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixText: 'KES ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Price is required'
                    : null,
              ),

              /* Category */
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Category is required'
                    : null,
              ),
              const SizedBox(height: 16),

              /* Description */
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(height: 16),

              /* Image URL */
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  prefixIcon: Icon(Icons.image),
                ),
              ),
              const SizedBox(height: 32),

              /* Submit Button */
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(isEditMode ? 'Save Changes' : 'Add Product'),
                  onPressed: _submitForm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

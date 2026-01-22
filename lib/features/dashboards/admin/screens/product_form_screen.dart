// lib/features/admin/screens/product_form_screen.dart

import 'package:flutter/material.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.productData});

  static const String routeName = '/admin/product-form';

  final Map<String, dynamic>? productData;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController categoryController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.productData?['name'] ?? '');
    categoryController = TextEditingController(text: widget.productData?['category'] ?? '');
    priceController = TextEditingController(text: widget.productData?['price']?.toString() ?? '');
    descriptionController = TextEditingController(text: widget.productData?['description'] ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Product")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Product Name"),
                validator: (value) => value!.isEmpty ? "Enter product name" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: "Category"),
                validator: (value) => value!.isEmpty ? "Enter category" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter price" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 4,
                validator: (value) => value!.isEmpty ? "Enter description" : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // TODO: save changes
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Product updated!")),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text("Save Changes"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

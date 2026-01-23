import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../../cart/providers/cart_provider.dart';
import '../../../core/widgets/primary_button.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product; // <-- use ProductModel instead of Product

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* Product Image */
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image, size: 50),
                    )
                  : const Icon(Icons.image, size: 50),
            ),
            const SizedBox(height: 16),

            /* Product Name */
            Text(
              product.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            /* Product Price */
            Text(
              'KSh ${product.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
            const SizedBox(height: 16),

            /* Product Description */
            Text(product.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),

            /* Add to Cart Button */
            PrimaryButton(
              text: 'Add to Cart',
              onPressed: () {
                // Add product using the current CartProvider
                context.read<CartProvider>().addItem(product.id);

                // Show a snackbar confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${product.name} added to cart')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

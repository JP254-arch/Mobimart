// lib/features/product/screens/product_details_page.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mobimart_app/features/models/product_model.dart';
import 'package:mobimart_app/features/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ProductDetailsPage extends StatelessWidget {
  final ProductModel product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            /* ================= TOP APP BAR ================= */
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.arrow_back),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      switch (value) {
                        case 'home':
                          Navigator.popUntil(context, (route) => route.isFirst);
                          break;
                        case 'cart':
                          Navigator.pushNamed(context, '/cart');
                          break;
                        case 'wishlist':
                          Navigator.pushNamed(context, '/wishlist');
                          break;
                        case 'account':
                          Navigator.pushNamed(context, '/profile');
                          break;
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'home', child: Text('Home')),
                      PopupMenuItem(value: 'cart', child: Text('Cart')),
                      PopupMenuItem(value: 'wishlist', child: Text('Wishlist')),
                      PopupMenuItem(value: 'account', child: Text('Account')),
                    ],
                  ),
                ],
              ),
            ),

            /* ================= PRODUCT CONTENT ================= */
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    /* Category Badge */
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(
                          primaryColor.red,
                          primaryColor.green,
                          primaryColor.blue,
                          0.8, // opacity between 0.0 and 1.0
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    /* Product Price */
                    Text(
                      "KSh ${product.price.toStringAsFixed(0)}",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    /* Product Description */
                    Text(
                      product.description,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),

                    const SizedBox(height: 100), // space for sticky button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      /* ================= ADD TO CART BUTTON ================= */
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Access the provider
                  final userProvider =
                      Provider.of<UserProvider>(context, listen: false);

                  // Add product to cart
                  userProvider.addToCart(product);

                  // Show confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} added to cart'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text("Add to Cart"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

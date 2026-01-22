// lib/features/wishlist/screens/wishlist_screen.dart

import 'package:flutter/material.dart';
import 'package:mobimart_app/features/models/product_model.dart';
import 'package:mobimart_app/features/screens/product_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  // Mock wishlist products
  List<ProductModel> get mockWishlist => [
        ProductModel(
          id: '1',
          name: 'Mobimart Sneakers',
          imageUrl: 'assets/images/banners/banner1.png',
          price: 3500,
          category: 'Shoes',
          description: 'Comfortable running sneakers for daily use.',
        ),
        ProductModel(
          id: '2',
          name: 'Mobimart Backpack',
          imageUrl: 'assets/images/banners/banner2.png',
          price: 2500,
          category: 'Bags',
          description: 'Spacious backpack with multiple compartments.',
        ),
        ProductModel(
          id: '3',
          name: 'Mobimart Headphones',
          imageUrl: 'assets/images/banners/banner3.png',
          price: 1800,
          category: 'Electronics',
          description: 'High-quality wireless headphones with bass boost.',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final wishlist = mockWishlist;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mobimart Wishlist"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // SEARCH BAR
            TextField(
              decoration: InputDecoration(
                hintText: "Search wishlist...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                // FIXED: Replace deprecated withOpacity
                fillColor: Theme.of(context).cardColor.withAlpha((0.1 * 255).toInt()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // EMPTY STATE
            if (wishlist.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    "Your Mobimart wishlist is empty.",
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            // WISHLIST GRID
            if (wishlist.isNotEmpty)
              Expanded(
                child: GridView.builder(
                  itemCount: wishlist.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.70,
                  ),
                  itemBuilder: (context, index) {
                    final product = wishlist[index];
                    return WishlistProductCard(product: product);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/* ================= WISHLIST PRODUCT CARD ================= */
class WishlistProductCard extends StatelessWidget {
  final ProductModel product;

  const WishlistProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // Navigate to Product Details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsPage(product: product),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              // FIXED: Replace deprecated withOpacity
              color: Colors.black.withAlpha((0.05 * 255).toInt()),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PRODUCT IMAGE
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // PRODUCT NAME
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),

            // PRODUCT PRICE
            Text(
              "KSh ${product.price.toStringAsFixed(0)}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 4),

            // ACTION BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // REMOVE BUTTON
                IconButton(
                  onPressed: () {
                    // TODO: Remove from wishlist logic
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  iconSize: 20,
                ),

                // ADD TO CART BUTTON
                IconButton(
                  onPressed: () {
                    // TODO: Add to cart logic
                  },
                  icon: const Icon(Icons.shopping_cart_outlined, color: Colors.green),
                  iconSize: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

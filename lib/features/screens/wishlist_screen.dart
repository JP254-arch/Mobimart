// lib/features/screens/wishlist_screen.dart

import 'package:flutter/material.dart';
import 'package:mobimart_app/features/models/product_model.dart';
import 'package:mobimart_app/features/providers/user_provider.dart';
import 'package:mobimart_app/features/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  static const String routeName = '/wishlist';

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Mobimart Wishlist"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            final wishlist = userProvider.wishlist;

            // 🔹 LIVE FILTER
            final filteredWishlist = wishlist.where((product) {
              final query = _searchQuery.toLowerCase();
              return product.name.toLowerCase().contains(query) ||
                  product.category.toLowerCase().contains(query);
            }).toList();

            return Column(
              children: [
                // ================= SEARCH BAR =================
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search wishlist...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: theme.cardColor.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // ================= EMPTY STATES =================
                if (wishlist.isEmpty)
                  Expanded(child: _EmptyWishlistState())
                else if (filteredWishlist.isEmpty)
                  Expanded(child: _NoSearchResultsState())
                // ================= GRID =================
                else
                  Expanded(
                    child: GridView.builder(
                      itemCount: filteredWishlist.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.70,
                          ),
                      itemBuilder: (context, index) {
                        final product = filteredWishlist[index];
                        return WishlistProductCard(product: product);
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/* ================= EMPTY STATES ================= */

class _EmptyWishlistState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Your wishlist is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items you love and find them here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _NoSearchResultsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No matching items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different name or category.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

/* ================= PRODUCT CARD ================= */

class WishlistProductCard extends StatelessWidget {
  final ProductModel product;

  const WishlistProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final userProvider = context.read<UserProvider>();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
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
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image),
                      )
                    : const Icon(Icons.image),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "KSh ${product.price.toStringAsFixed(0)}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => userProvider.removeFromWishlist(product.id),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  iconSize: 20,
                ),
                IconButton(
                  onPressed: () async {
                    await userProvider.addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to cart'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.green,
                  ),
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

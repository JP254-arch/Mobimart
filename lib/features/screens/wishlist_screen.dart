import 'package:flutter/material.dart';
import 'package:mobimart_app/features/models/product_model.dart';
import 'package:mobimart_app/features/providers/user_provider.dart';
import 'package:mobimart_app/features/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  static const String routeName = '/wishlist';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mobimart Wishlist"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            final wishlist = userProvider.wishlist;

            return Column(
              children: [
                // ================= SEARCH BAR =================
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search wishlist...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context)
                        .cardColor
                        .withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ================= EMPTY STATE =================
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

                // ================= WISHLIST GRID =================
                if (wishlist.isNotEmpty)
                  Expanded(
                    child: GridView.builder(
                      itemCount: wishlist.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
            );
          },
        ),
      ),
    );
  }
}

/* ================= WISHLIST PRODUCT CARD ================= */
class WishlistProductCard extends StatelessWidget {
  final ProductModel product;

  const WishlistProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
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
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                IconButton(
                  onPressed: () {
                    userProvider.removeFromWishlist(product.id);
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  iconSize: 20,
                ),
                IconButton(
                  onPressed: () {
                    userProvider.addToCart(product);
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

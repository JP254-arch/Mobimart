// lib/features/home/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobimart_app/core/theme/theme_provider.dart';
import 'package:mobimart_app/features/models/product_model.dart';
import 'package:mobimart_app/features/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.getIsDarkTHeme ?? false;

    final CollectionReference productsCollection = FirebaseFirestore.instance
        .collection('products');

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Mobimart",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                    onPressed: () {
                      themeProvider.setDarkTheme(!isDark);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // SEARCH BAR
              TextField(
                decoration: InputDecoration(
                  hintText: "Search Mobimart products...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).cardColor.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // BANNER
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/banners/banner1.png',
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),

              // SECTION TITLE
              Text(
                "Popular Products",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // PRODUCT GRID: Firestore
              StreamBuilder<QuerySnapshot>(
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

                  final products = productDocs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ProductModel.fromMap(data, doc.id);
                  }).toList();

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.70,
                        ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailsPage(product: product),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ================= PRODUCT CARD WIDGET ================= */
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).cardColor,
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
            // PRODUCT IMAGE
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image, size: 50),
                      )
                    : const Icon(Icons.image, size: 50),
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

            // CATEGORY BADGE
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                product.category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

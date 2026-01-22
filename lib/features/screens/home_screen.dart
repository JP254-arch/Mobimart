// lib/features/home/screens/home_screen.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mobimart_app/core/theme/theme_provider.dart';
import 'package:mobimart_app/features/models/product_model.dart';
import 'package:mobimart_app/features/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Mock product list
  List<ProductModel> get mockProducts => [
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
        ProductModel(
          id: '4',
          name: 'Mobimart Watch',
          imageUrl: 'assets/images/banners/banner4.png',
          price: 5000,
          category: 'Accessories',
          description: 'Stylish wristwatch with leather strap.',
        ),
        ProductModel(
          id: '5',
          name: 'Mobimart Jacket',
          imageUrl: 'assets/images/banners/banner5.png',
          price: 4200,
          category: 'Clothing',
          description: 'Warm and comfortable jacket for all seasons.',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.getIsDarkTHeme ?? false;

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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),

              // PRODUCT GRID
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: mockProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.70,
                ),
                itemBuilder: (context, index) {
                  final product = mockProducts[index];
                  return ProductCard(
                    product: product,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailsPage(product: product),
                        ),
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

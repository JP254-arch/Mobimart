import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mobimart_app/features/models/product_model.dart' as pmodel;
import 'package:mobimart_app/features/products/providers/product_provider.dart';
import 'package:mobimart_app/features/providers/user_provider.dart';
import 'package:mobimart_app/features/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:mobimart_app/core/constants/categories.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> bannerImages = [
    'assets/images/banners/banner1.jpg',
    'assets/images/banners/banner2.jpg',
    'assets/images/banners/banner3.jpeg',
    'assets/images/banners/banner4.jpg',
  ];

  /// ================= PAGINATION =================
  int _currentPage = 0;
  static const int _itemsPerPage = 9; // 3 per row x 3 rows per page

  void _nextPage(int totalProducts) {
    final maxPage = (totalProducts / _itemsPerPage).ceil() - 1;
    if (_currentPage < maxPage) {
      setState(() => _currentPage++);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  void _resetPagination() {
    setState(() => _currentPage = 0);
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final userProvider = context.read<UserProvider>();
    final primaryColor = Theme.of(context).colorScheme.primary;

    final products = productProvider.filteredProducts;

    /// page slicing
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, products.length);

    final visibleProducts = products.isEmpty
        ? []
        : products.sublist(startIndex, endIndex);

    return SafeArea(
      child: Column(
        children: [
          /// ================= STATIC TOP BAR =================
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                /// SEARCH
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    onChanged: (value) {
                      productProvider.setSearchQuery(value);
                      _resetPagination();
                    },
                    decoration: InputDecoration(
                      hintText: 'Search products or categories...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Theme.of(context).cardColor.withAlpha(25),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                /// CATEGORIES
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected =
                          productProvider.selectedCategory == category.key;

                      return GestureDetector(
                        onTap: () {
                          productProvider.setCategory(category.key);
                          _resetPagination();
                        },
                        child: Container(
                          width: 72,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryColor
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 37, 179, 32).withAlpha(13),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                category.icon,
                                size: 24,
                                color: isSelected
                                    ? Colors.white
                                    : const Color.fromARGB(255, 7, 180, 13),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                category.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          /// ================= SCROLLABLE PART =================
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Icon(
                      Icons.search_off,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// CAROUSEL
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: 170,
                              autoPlay: true,
                              enlargeCenterPage: true,
                              viewportFraction: 1,
                            ),
                            items: bannerImages.map((imagePath) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  imagePath,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        /// PRODUCTS GRID
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: visibleProducts.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3, // 3 products per row
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 0.60,
                                ),
                            itemBuilder: (context, index) {
                              final product = visibleProducts[index];

                              return ProductCard(
                                product: product,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetailsPage(product: product),
                                  ),
                                ),
                                onAddToCart: () async {
                                  await userProvider.addToCart(product);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${product.name} added to cart',
                                      ),
                                    ),
                                  );
                                },
                                onAddToWishlist: () async {
                                  await userProvider.addToWishlist(product);
                                },
                              );
                            },
                          ),
                        ),

                        /// PAGINATION CONTROLS
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: _currentPage == 0
                                    ? null
                                    : _previousPage,
                                icon: const Icon(Icons.arrow_back_ios),
                                label: const Text('Prev'),
                              ),
                              TextButton.icon(
                                onPressed:
                                    (_currentPage + 1) * _itemsPerPage >=
                                        products.length
                                    ? null
                                    : () => _nextPage(products.length),
                                icon: const Icon(Icons.arrow_forward_ios),
                                label: const Text('Next'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// ================= PRODUCT CARD =================
class ProductCard extends StatelessWidget {
  final pmodel.ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback onAddToWishlist;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
    required this.onAddToWishlist,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
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
                      )
                    : const Icon(Icons.image),
              ),
            ),
            const SizedBox(height: 4),
            Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              'KSh ${product.price.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryColor,
                fontSize: 13,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: onAddToWishlist,
                  icon: const Icon(Icons.favorite_border, color: Colors.red),
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                IconButton(
                  onPressed: onAddToCart,
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.green,
                  ),
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

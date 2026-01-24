import 'package:flutter/material.dart';
import 'package:mobimart_app/features/models/product_model.dart';
import 'package:mobimart_app/features/providers/user_provider.dart';
import 'package:mobimart_app/features/screens/home_screen.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  static const String routeName = '/cart';

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isProcessingCheckout = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final cartItems = userProvider.currentUser?.cart ?? <ProductModel>[];

    final totalPrice = cartItems.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Mobimart Cart"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: cartItems.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Whoops! Your cart is empty!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Looks like your cart is empty.\nAdd something to make me happy!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HomeScreen()),
                        );
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Browse Other Categories'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final product = cartItems[index];
                  return CartItemCard(
                    product: product,
                    onRemove: () async {
                      await userProvider.removeFromCart(product.id);
                    },
                    onQuantityChanged: (newQuantity) {
                      userProvider.updateCartItemQuantity(
                          product.id, newQuantity);
                    },
                  );
                },
              ),
      ),
      bottomSheet: cartItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Total: KSh ${totalPrice.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isProcessingCheckout
                        ? null
                        : () async {
                            final messenger = ScaffoldMessenger.of(context);

                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Confirm Checkout'),
                                content: const Text(
                                  'Are you sure you want to checkout?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Confirm'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed != true) return;

                            setState(() {
                              _isProcessingCheckout = true;
                            });

                            try {
                              await userProvider.clearCart();

                              if (!mounted) return;

                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Checkout successful! Your cart is now empty.",
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text("Checkout failed. Error: $e"),
                                ),
                              );
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isProcessingCheckout = false;
                                });
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isProcessingCheckout
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Checkout"),
                  ),
                ],
              ),
            ),
    );
  }
}

/* ================= CART ITEM CARD ================= */
class CartItemCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onRemove;
  final ValueChanged<int> onQuantityChanged;

  const CartItemCard({
    super.key,
    required this.product,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final quantity = product.quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: product.imageUrl.isNotEmpty
                ? Image.network(
                    product.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(Icons.image),
                  )
                : const Icon(Icons.image, size: 80),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "KSh ${(product.price * quantity).toStringAsFixed(0)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (quantity > 1) {
                          onQuantityChanged(quantity - 1);
                        }
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text(
                      quantity.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () {
                        onQuantityChanged(quantity + 1);
                      },
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }
}

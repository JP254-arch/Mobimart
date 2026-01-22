// lib/features/cart/screens/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:mobimart_app/features/models/product_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Mock cart items
  List<CartItem> cartItems = [
    CartItem(
      product: ProductModel(
        id: '1',
        name: 'Mobimart Sneakers',
        imageUrl: 'assets/images/banners/banner1.png',
        price: 3500,
        category: 'Shoes',
        description: 'Comfortable running sneakers for daily use.',
      ),
      quantity: 1,
    ),
    CartItem(
      product: ProductModel(
        id: '2',
        name: 'Mobimart Backpack',
        imageUrl: 'assets/images/banners/banner2.png',
        price: 2500,
        category: 'Bags',
        description: 'Spacious backpack with multiple compartments.',
      ),
      quantity: 2,
    ),
  ];

  // Calculate total
  double get totalPrice {
    double total = 0.0;
    for (var item in cartItems) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mobimart Cart"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: cartItems.isEmpty
            ? Center(
                child: Text(
                  "Your Mobimart cart is empty.",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final cartItem = cartItems[index];
                  return CartItemCard(
                    cartItem: cartItem,
                    onQuantityChanged: (newQuantity) {
                      setState(() {
                        cartItem.quantity = newQuantity;
                      });
                    },
                    onRemove: () {
                      setState(() {
                        cartItems.removeAt(index);
                      });
                    },
                  );
                },
              ),
      ),

      // Checkout button & total price
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
                    onPressed: () {
                      // TODO: Checkout logic
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Checkout"),
                  ),
                ],
              ),
            ),
    );
  }
}

/* ================= CART ITEM MODEL ================= */
class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

/* ================= CART ITEM CARD ================= */
class CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  final void Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

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
          // PRODUCT IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              cartItem.product.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),

          // PRODUCT DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.product.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "KSh ${cartItem.product.price.toStringAsFixed(0)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),

                // QUANTITY SELECTOR
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (cartItem.quantity > 1) {
                          onQuantityChanged(cartItem.quantity - 1);
                        }
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text(
                      cartItem.quantity.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () {
                        onQuantityChanged(cartItem.quantity + 1);
                      },
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // REMOVE BUTTON
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }
}

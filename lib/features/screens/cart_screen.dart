import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobimart_app/features/models/product_model.dart';
import 'package:mobimart_app/features/providers/user_provider.dart';
import 'package:mobimart_app/features/screens/payment_success_screen.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  static const String routeName = '/cart';

  Future<void> _checkout(BuildContext context, double totalPrice) async {
    final userProvider = context.read<UserProvider>();
    final cartItems = userProvider.currentUser?.cart ?? [];

    if (cartItems.isEmpty) return;

    // --- PHONE INPUT DIALOG ---
    final TextEditingController phoneController = TextEditingController();
    final phone = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter your phone number'),
        content: TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: '2547XXXXXXXX'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () =>
                  Navigator.of(ctx).pop(phoneController.text.trim()),
              child: const Text('Continue')),
        ],
      ),
    );

    if (phone == null || phone.isEmpty) return;

    // --- SHOW PROCESSING DIALOG ---
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Expanded(child: Text("Processing your payment...")),
          ],
        ),
      ),
    );

    try {
      // --- INITIATE PAYMENT ---
      final transactionId = await userProvider.initiateDarajaPayment(
        phone: phone,
        amount: totalPrice,
      );

      if (transactionId == null) {
        Navigator.pop(context);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to initiate payment")),
          );
        }
        return;
      }

      // --- LISTEN TO PAYMENT STATUS ---
      userProvider.listenForPaymentStatus(
        transactionId: transactionId,
        onStatusChange: (success) async {
          if (!context.mounted) return;
          Navigator.pop(context); // close processing dialog

          if (success) {
            // Clear cart and move to orders automatically
            await userProvider.clearCart();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const PaymentSuccessScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Payment failed or cancelled")),
            );
          }
        },
      );
    } catch (e) {
      Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error processing payment: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final cartItems = userProvider.currentUser?.cart ?? [];

    final totalPrice = cartItems.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Mobimart Cart')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: cartItems.isEmpty
            ? _buildEmptyCart()
            : ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (_, index) {
                  final product = cartItems[index];
                  return CartItemCard(
                    product: product,
                    onRemove: () => userProvider.removeFromCart(product.id),
                    onQuantityChanged: (qty) =>
                        userProvider.updateCartItemQuantity(product.id, qty),
                  );
                },
              ),
      ),
      bottomSheet: cartItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Total: KES ${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _checkout(context, totalPrice),
                    child: const Text('Checkout'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            product.imageUrl.isNotEmpty
                ? Image.network(
                    product.imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image, size: 70),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'KES ${(product.price * product.quantity).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: product.quantity > 1
                            ? () => onQuantityChanged(product.quantity - 1)
                            : null,
                      ),
                      Text(product.quantity.toString()),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () =>
                            onQuantityChanged(product.quantity + 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
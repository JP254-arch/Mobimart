import 'package:flutter/material.dart';
import 'package:mobimart_app/features/models/product_model.dart';
import 'package:mobimart_app/features/orders/models/order_model.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  static const String routeName = '/orders';

  // ================= MOCK DATA =================
  List<Order> get mockOrders => [
        Order(
          id: 'ORD001',
          items: [
            ProductModel(
              id: '1',
              name: 'Mobimart Sneakers',
              imageUrl: 'assets/images/banners/banner1.png',
              price: 3500,
              category: 'Shoes',
              description: 'Comfortable running sneakers',
            ),
          ],
          total: 3500,
          date: DateTime.now().subtract(const Duration(days: 1)),
          status: 'Delivered',
        ),
        Order(
          id: 'ORD002',
          items: [
            ProductModel(
              id: '2',
              name: 'Mobimart Backpack',
              imageUrl: 'assets/images/banners/banner2.png',
              price: 2500,
              category: 'Bags',
              description: 'Spacious backpack',
            ),
            ProductModel(
              id: '3',
              name: 'Mobimart Headphones',
              imageUrl: 'assets/images/banners/banner3.png',
              price: 1800,
              category: 'Electronics',
              description: 'Wireless headphones',
            ),
          ],
          total: 4300,
          date: DateTime.now().subtract(const Duration(days: 3)),
          status: 'Shipped',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final orders = mockOrders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        centerTitle: true,
      ),
      body: orders.isEmpty
          ? const Center(child: Text('You have no orders yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return OrderCard(order: orders[index]);
              },
            ),
    );
  }
}

/* ================= ORDER CARD ================= */

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order ID: ${order.id}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                order.status,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: order.status == 'Delivered'
                      ? Colors.green
                      : order.status == 'Shipped'
                          ? Colors.orange
                          : Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Text(
            'Date: ${order.date.toLocal().toString().split(' ')[0]}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),

          const Divider(height: 24),

          // ITEMS
          ...order.items.map(
            (item) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text('KSh ${item.price.toStringAsFixed(0)}'),
              ],
            ),
          ),

          const Divider(height: 24),

          // TOTAL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'KSh ${order.total.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobimart_app/features/orders/models/order_model.dart'
    as order_model;
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  static const String routeName = '/orders';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final CollectionReference ordersCollection = FirebaseFirestore.instance
      .collection('orders');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ordersCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final orderDocs = snapshot.data?.docs ?? [];

                if (orderDocs.isEmpty) {
                  return const Center(child: Text('You have no orders yet'));
                }

                final orders = orderDocs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return order_model.Order.fromMap(data, doc.id);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) =>
                      OrderCard(order: orders[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Download Orders'),
              onPressed: _downloadOrdersPdf,
            ),
          ),
        ],
      ),
    );
  }

  /// MAIN DOWNLOAD HANDLER
  Future<void> _downloadOrdersPdf() async {
    final snapshot = await ordersCollection.get();

    final orders = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return order_model.Order.fromMap(data, doc.id);
    }).toList();

    if (orders.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No orders to export')));
      return;
    }

    final pdfData = await _generateOrdersPdf(orders);

    final directory = await _getDownloadDirectory();

    // Timestamped filename (no overwrite)
    final date = DateTime.now().toIso8601String().split('T').first;
    final file = File('${directory.path}/orders_$date.pdf');

    await file.writeAsBytes(pdfData);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('PDF saved to Downloads')));
  }

  /// Resolves a clean Downloads directory
  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      final dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    }

    // iOS / fallback
    return await getApplicationDocumentsDirectory();
  }

  /// Generates PDF bytes (NO fonts, NO assets)
  Future<Uint8List> _generateOrdersPdf(List<order_model.Order> orders) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            'Orders Report',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 16),

          ...orders.map(
            (order) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Order ID: ${order.id}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text('Status: ${order.status}'),
                pw.Text(
                  'Date: ${order.date.toLocal().toString().split(' ')[0]}',
                ),
                pw.SizedBox(height: 8),

                ...order.items.map(
                  (item) => pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(item.name),
                      pw.Text('KSh ${item.price.toStringAsFixed(0)}'),
                    ],
                  ),
                ),

                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'KSh ${order.total.toStringAsFixed(0)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}

class OrderCard extends StatelessWidget {
  final order_model.Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (order.status) {
      case 'Delivered':
        statusColor = Colors.green;
        break;
      case 'Shipped':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  color: statusColor,
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

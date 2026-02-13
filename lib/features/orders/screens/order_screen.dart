import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobimart_app/features/orders/models/order_model.dart'
    as order_model;
import 'package:mobimart_app/features/providers/user_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  static const String routeName = '/orders';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late final Query ordersQuery;

  static const double vatRate = 0.16; // 16% VAT

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final uid = userProvider.currentUser?.uid ?? '';

    ordersQuery = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: uid);
  }

  double _calculateSubtotal(order_model.Order order) {
    return order.items.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  double _calculateVAT(double subtotal) => subtotal * vatRate;

  double _calculateGrandTotal(double subtotal, double vat) => subtotal + vat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ordersQuery.snapshots(),
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

  Future<void> _downloadOrdersPdf() async {
    final snapshot = await ordersQuery.get();

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

    final date = DateTime.now().toIso8601String().split('T').first;
    final fileName = 'orders_$date.pdf';

    if (kIsWeb) {
      await Printing.sharePdf(bytes: pdfData, filename: fileName);
    } else {
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final file = File('${downloadsDir.path}/$fileName');
      await file.writeAsBytes(pdfData);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF File saved to ${file.path}')));
    }
  }

  Future<Uint8List> _generateOrdersPdf(List<order_model.Order> orders) async {
    final pdf = pw.Document();

    final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );

    final logoBytes = await rootBundle.load('assets/images/logo.jpeg');
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(32),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(font: regularFont, fontSize: 10),
          ),
        ),
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Image(logo, width: 80),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'MobiMart Ltd',
                    style: pw.TextStyle(font: boldFont, fontSize: 18),
                  ),
                  pw.Text(
                    'Nairobi, Kenya',
                    style: pw.TextStyle(font: regularFont),
                  ),
                  pw.Text(
                    'info@mobimart.com',
                    style: pw.TextStyle(font: regularFont),
                  ),
                  pw.Text(
                    '+254 740 623879',
                    style: pw.TextStyle(font: regularFont),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Orders Financial Report',
            style: pw.TextStyle(font: boldFont, fontSize: 20),
          ),
          pw.SizedBox(height: 20),

          ...orders.map((order) {
            final subtotal = _calculateSubtotal(order);
            final vat = _calculateVAT(subtotal);
            final grandTotal = _calculateGrandTotal(subtotal, vat);

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Order ID: ${order.id}',
                  style: pw.TextStyle(font: boldFont),
                ),
                pw.SizedBox(height: 8),
                pw.Table(
                  border: pw.TableBorder.all(width: 0.5),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Item',
                            style: pw.TextStyle(font: boldFont),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Price',
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(font: boldFont),
                          ),
                        ),
                      ],
                    ),
                    ...order.items.map(
                      (item) => pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              item.name,
                              style: pw.TextStyle(font: regularFont),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              'KSh ${(item.price * item.quantity).toStringAsFixed(0)}',
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(font: regularFont),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Subtotal: KSh ${subtotal.toStringAsFixed(0)}',
                        style: pw.TextStyle(font: regularFont),
                      ),
                      pw.Text(
                        'VAT (${(vatRate * 100).toInt()}%): KSh ${vat.toStringAsFixed(0)}',
                        style: pw.TextStyle(font: regularFont),
                      ),
                      pw.Divider(),
                      pw.Text(
                        'Grand Total: KSh ${grandTotal.toStringAsFixed(0)}',
                        style: pw.TextStyle(font: boldFont, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),
              ],
            );
          }).toList(),

          pw.SizedBox(height: 40),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Text('Authorized Signature:', style: pw.TextStyle(font: boldFont)),
          pw.SizedBox(height: 40),
          pw.Container(width: 200, height: 1, color: PdfColors.black),
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
        ],
      ),
    );
  }
}

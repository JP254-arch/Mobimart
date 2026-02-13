import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobimart_app/features/orders/models/order_model.dart'
    as order_model;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  final CollectionReference ordersRef =
      FirebaseFirestore.instance.collection('orders');

  final TextEditingController _searchController = TextEditingController();
  final Map<String, bool> _selectedOrders = {};

  String searchQuery = "";

  static const double vatRate = 0.16;

  // ================= CALCULATIONS (COPIED) =================

  double _calculateSubtotal(order_model.Order order) {
    return order.items.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  double _calculateVAT(double subtotal) => subtotal * vatRate;

  double _calculateGrandTotal(double subtotal, double vat) =>
      subtotal + vat;

  // ================= PDF DOWNLOAD =================

  Future<void> _downloadOrdersPdf(
      List<order_model.Order> orders) async {
    if (orders.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No orders to export')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF File saved to ${file.path}')),
      );
    }
  }

  // ================= EXACT PDF (ORDERS SCREEN COPY) =================

  Future<Uint8List> _generateOrdersPdf(
      List<order_model.Order> orders) async {
    final pdf = pw.Document();

    final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );

    final logoBytes =
        await rootBundle.load('assets/images/logo.jpeg');
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
            mainAxisAlignment:
                pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Image(logo, width: 80),
              pw.Column(
                crossAxisAlignment:
                    pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'MobiMart Ltd',
                    style:
                        pw.TextStyle(font: boldFont, fontSize: 18),
                  ),
                  pw.Text('Nairobi, Kenya',
                      style: pw.TextStyle(font: regularFont)),
                  pw.Text('info@mobimart.com',
                      style: pw.TextStyle(font: regularFont)),
                  pw.Text('+254 740 623879',
                      style: pw.TextStyle(font: regularFont)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // ONLY CHANGE YOU REQUESTED
          pw.Text(
            'Official Receipt',
            style: pw.TextStyle(font: boldFont, fontSize: 20),
          ),

          pw.SizedBox(height: 20),

          ...orders.map((order) {
            final subtotal = _calculateSubtotal(order);
            final vat = _calculateVAT(subtotal);
            final grandTotal =
                _calculateGrandTotal(subtotal, vat);

            return pw.Column(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.start,
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
                          padding:
                              const pw.EdgeInsets.all(6),
                          child: pw.Text('Item',
                              style:
                                  pw.TextStyle(font: boldFont)),
                        ),
                        pw.Padding(
                          padding:
                              const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Price',
                            textAlign: pw.TextAlign.right,
                            style:
                                pw.TextStyle(font: boldFont),
                          ),
                        ),
                      ],
                    ),
                    ...order.items.map(
                      (item) => pw.TableRow(
                        children: [
                          pw.Padding(
                            padding:
                                const pw.EdgeInsets.all(6),
                            child: pw.Text(item.name,
                                style: pw.TextStyle(
                                    font: regularFont)),
                          ),
                          pw.Padding(
                            padding:
                                const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              'KSh ${(item.price * item.quantity).toStringAsFixed(0)}',
                              textAlign:
                                  pw.TextAlign.right,
                              style: pw.TextStyle(
                                  font: regularFont),
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
                    crossAxisAlignment:
                        pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Subtotal: KSh ${subtotal.toStringAsFixed(0)}',
                        style:
                            pw.TextStyle(font: regularFont),
                      ),
                      pw.Text(
                        'VAT (${(vatRate * 100).toInt()}%): KSh ${vat.toStringAsFixed(0)}',
                        style:
                            pw.TextStyle(font: regularFont),
                      ),
                      pw.Divider(),
                      pw.Text(
                        'Grand Total: KSh ${grandTotal.toStringAsFixed(0)}',
                        style: pw.TextStyle(
                            font: boldFont, fontSize: 14),
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
          pw.Text('Authorized Signature:',
              style: pw.TextStyle(font: boldFont)),
          pw.SizedBox(height: 40),
          pw.Container(width: 200, height: 1, color: PdfColors.black),
        ],
      ),
    );

    return pdf.save();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Orders")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Search by Order ID or Owner",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ordersRef
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                final orders = docs.map((doc) {
                  final data =
                      doc.data() as Map<String, dynamic>;
                  return order_model.Order.fromMap(
                      data, doc.id);
                }).where((order) {
                  final owner =
                      (order.name ?? "")
                          .toLowerCase();
                  return order.id
                          .toLowerCase()
                          .contains(searchQuery) ||
                      owner.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];

                    _selectedOrders.putIfAbsent(
                        order.id, () => false);

                    return CheckboxListTile(
                      value: _selectedOrders[order.id],
                      onChanged: (v) {
                        setState(() {
                          _selectedOrders[order.id] = v!;
                        });
                      },
                      title: Text("Order ID: ${order.id}"),
                      subtitle: Text(
                          "Customer: ${order.name} • ${order.status}"),
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final snap = await ordersRef.get();

                      final orders = snap.docs.map((doc) {
                        final data =
                            doc.data() as Map<String, dynamic>;
                        return order_model.Order.fromMap(
                            data, doc.id);
                      }).toList();

                      _downloadOrdersPdf(orders);
                    },
                    child: const Text("Download All"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final snap = await ordersRef.get();

                      final selected = snap.docs
                          .where((doc) =>
                              _selectedOrders[doc.id] == true)
                          .map((doc) {
                        final data =
                            doc.data() as Map<String, dynamic>;
                        return order_model.Order.fromMap(
                            data, doc.id);
                      }).toList();

                      _downloadOrdersPdf(selected);
                    },
                    child:
                        const Text("Download Selected"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
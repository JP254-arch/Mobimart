// lib/features/dashboards/admin/screens/manage_orders_screen.dart

import 'dart:typed_data';
import 'dart:io' show Directory, File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  static const String routeName = '/admin/manage-orders';

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  final CollectionReference ordersCollection = FirebaseFirestore.instance
      .collection('orders');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download PDF',
            onPressed: _downloadOrdersPdf,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersCollection
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No orders found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final order = docs[index];
              final data = order.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text('Order: ${order.id}'),
                  subtitle: Text(
                    'Total: KSh ${(data['totalAmount'] as num?)?.toStringAsFixed(0) ?? '0'}\n'
                    'Status: ${data['status'] ?? 'Pending'}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // =====================
  // DOWNLOAD PDF
  // =====================

  Future<void> _downloadOrdersPdf() async {
    final snapshot = await ordersCollection
        .orderBy('createdAt', descending: true)
        .get();

    if (snapshot.docs.isEmpty) {
      if (!mounted) return;
      _showMessage('No orders to export');
      return;
    }

    final pdfData = await _generateOrdersPdf(snapshot.docs);

    // 🚫 WEB: cannot write to filesystem
    if (kIsWeb) {
      _showMessage('PDF download is not supported on Web yet');
      return;
    }

    final dir = await _getSaveDirectory();
    final file = File(
      '${dir.path}/admin_orders_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );

    await file.writeAsBytes(pdfData);

    if (!mounted) return;
    _showMessage('PDF saved to Downloads');
  }

  // =====================
  // PDF GENERATION
  // =====================

  Future<Uint8List> _generateOrdersPdf(List<QueryDocumentSnapshot> docs) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            'Admin Orders Report',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 16),

          ...docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final items = List.from(data['items'] ?? []);

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Order ID: ${doc.id}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text('User: ${data['userName'] ?? 'Unknown'}'),
                pw.Text('Status: ${data['status'] ?? 'Pending'}'),
                pw.SizedBox(height: 8),

                ...items.map(
                  (item) => pw.Text('- ${item['name']} (KSh ${item['price']})'),
                ),

                pw.Divider(),
                pw.Text(
                  'Total: KSh ${(data['totalAmount'] as num?)?.toStringAsFixed(0) ?? '0'}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 16),
              ],
            );
          }),
        ],
      ),
    );

    return pdf.save();
  }

  // =====================
  // SAVE LOCATION
  // =====================

  Future<Directory> _getSaveDirectory() async {
    // ANDROID: Downloads folder
    final androidDownloads = Directory('/storage/emulated/0/Download');
    if (await androidDownloads.exists()) {
      return androidDownloads;
    }

    // iOS / fallback
    return await getApplicationDocumentsDirectory();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

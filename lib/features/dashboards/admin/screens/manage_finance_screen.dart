import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

class ManageFinanceScreen extends StatefulWidget {
  const ManageFinanceScreen({super.key});
  static const String routeName = '/admin/manage-finance';

  @override
  State<ManageFinanceScreen> createState() => _ManageFinanceScreenState();
}

class _ManageFinanceScreenState extends State<ManageFinanceScreen> {
  final CollectionReference ordersCollection = FirebaseFirestore.instance
      .collection('orders');

  final CollectionReference transactionsCollection = FirebaseFirestore.instance
      .collection('transactions');

  // ================= SEARCH & BATCHING =================
  final TextEditingController _itemSearchController = TextEditingController();
  final TextEditingController _txnSearchController = TextEditingController();

  String _itemSearchQuery = '';
  String _txnSearchQuery = '';

  int _itemBatch = 0;
  int _txnBatch = 0;
  static const int batchSize = 10;

  final Map<String, bool> _selectedItems = {};
  final Map<String, bool> _selectedTxns = {};

  @override
  void dispose() {
    _itemSearchController.dispose();
    _txnSearchController.dispose();
    super.dispose();
  }

  // ================= CALCULATIONS =================
  num _calculateSubtotal(Map<String, dynamic> item) {
    final price = (item['price'] as num?) ?? 0;
    final quantity = (item['quantity'] as num?) ?? 1;
    return price * quantity;
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.blue[50],
      appBar: AppBar(
        title: const Text('Mobi Finance'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(theme, isDark),
            const SizedBox(height: 24),
            Text('Revenue Per Item', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            _buildItemSearchBar(theme, isDark),
            const SizedBox(height: 8),
            _buildRevenueTable(theme, isDark),
            const SizedBox(height: 16),
            _buildItemBatchControls(),
            const SizedBox(height: 24),
            Text('Transactions', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            _buildTxnSearchBar(theme, isDark),
            const SizedBox(height: 8),
            _buildTransactionTable(theme, isDark),
            const SizedBox(height: 16),
            _buildTxnBatchControls(),
          ],
        ),
      ),
    );
  }

  // ================= SUMMARY =================
  Widget _buildSummaryCard(ThemeData theme, bool isDark) {
    return FutureBuilder<QuerySnapshot>(
      future: ordersCollection.get(),
      builder: (context, snapshot) {
        double totalRevenue = 0;
        int totalOrders = 0;

        if (snapshot.hasData) {
          totalOrders = snapshot.data!.docs.length;
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final items = (data['items'] as List<dynamic>? ?? []);
            for (var item in items) {
              totalRevenue += _calculateSubtotal(item as Map<String, dynamic>);
            }
          }
        }

        return Row(
          children: [
            Expanded(
              child: Card(
                color: isDark ? Colors.orange[700] : Colors.orange[100],
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        color: isDark ? Colors.orange[200] : Colors.orange,
                        size: 36,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Orders',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge!.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalOrders',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge!.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                color: isDark ? Colors.green[700] : Colors.green[100],
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.wallet,
                        color: isDark ? Colors.green[200] : Colors.green,
                        size: 36,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Revenue',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge!.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'KSh ${totalRevenue.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge!.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ================= ITEM SEARCH =================
  Widget _buildItemSearchBar(ThemeData theme, bool isDark) {
    return TextField(
      controller: _itemSearchController,
      decoration: InputDecoration(
        hintText: 'Search items...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: isDark ? Colors.grey[800] : Colors.white,
      ),
      style: TextStyle(color: theme.textTheme.bodyLarge!.color),
      onChanged: (value) {
        setState(() {
          _itemSearchQuery = value.toLowerCase();
          _itemBatch = 0;
        });
      },
    );
  }

  // ================= TRANSACTION SEARCH =================
  Widget _buildTxnSearchBar(ThemeData theme, bool isDark) {
    return TextField(
      controller: _txnSearchController,
      decoration: InputDecoration(
        hintText: 'Search by transaction ID, customer or status...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: isDark ? Colors.grey[800] : Colors.white,
      ),
      style: TextStyle(color: theme.textTheme.bodyLarge!.color),
      onChanged: (value) {
        setState(() {
          _txnSearchQuery = value.toLowerCase();
          _txnBatch = 0;
        });
      },
    );
  }

  // ================= REVENUE TABLE =================
  Widget _buildRevenueTable(ThemeData theme, bool isDark) {
    return FutureBuilder<QuerySnapshot>(
      future: ordersCollection.get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final Map<String, Map<String, dynamic>> itemMap = {};
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final items = (data['items'] as List<dynamic>? ?? []);
          for (var item in items) {
            final itemData = item as Map<String, dynamic>;
            final name = itemData['name'] ?? 'Unknown';
            final price = (itemData['price'] as num?) ?? 0;
            final quantity = (itemData['quantity'] as num?) ?? 1;

            if (!itemMap.containsKey(name)) {
              itemMap[name] = {'quantity': 0, 'revenue': 0.0};
            }
            itemMap[name]!['quantity'] += quantity;
            itemMap[name]!['revenue'] += price * quantity;
          }
        }

        final itemsList = itemMap.entries
            .where((e) => e.key.toLowerCase().contains(_itemSearchQuery))
            .toList();

        final start = _itemBatch * batchSize;
        final end = (start + batchSize).clamp(0, itemsList.length);
        final batchItems = itemsList.sublist(start, end);

        return Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: batchItems.length,
              itemBuilder: (context, index) {
                final entry = batchItems[index];
                final selected = _selectedItems[entry.key] ?? false;
                return Card(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  child: ListTile(
                    leading: Checkbox(
                      value: selected,
                      onChanged: (val) {
                        setState(() {
                          _selectedItems[entry.key] = val ?? false;
                        });
                      },
                    ),
                    title: Text(
                      entry.key,
                      style: TextStyle(color: theme.textTheme.bodyLarge!.color),
                    ),
                    subtitle: Text(
                      'Quantity Sold: ${entry.value['quantity']}',
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium!.color,
                      ),
                    ),
                    trailing: Flexible(
                      child: Text(
                        'Revenue: KSh ${entry.value['revenue'].toStringAsFixed(0)}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium!.color,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _itemBatch > 0
                      ? () => setState(() => _itemBatch--)
                      : null,
                  icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: batchItems.isNotEmpty
                      ? () => _downloadItemPdf(batchItems)
                      : null,
                  child: const Text('Selected'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: itemsList.isNotEmpty
                      ? () => _downloadItemPdf(itemsList)
                      : null,
                  child: const Text('All'),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: end < itemsList.length
                      ? () => setState(() => _itemBatch++)
                      : null,
                  icon: Icon(Icons.arrow_forward, color: theme.iconTheme.color),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ================= TRANSACTION TABLE =================
  Widget _buildTransactionTable(ThemeData theme, bool isDark) {
    return FutureBuilder<QuerySnapshot>(
      future: transactionsCollection.get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final txnsList = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final customer = (data['customerName'] ?? '')
              .toString()
              .toLowerCase();
          final txnId = doc.id.toLowerCase();
          final status = (data['status'] ?? '').toString().toLowerCase();
          final date =
              (data['date'] as Timestamp?)?.toDate().toString().toLowerCase() ??
              '';
          return _txnSearchQuery.isEmpty ||
              customer.contains(_txnSearchQuery) ||
              txnId.contains(_txnSearchQuery) ||
              status.contains(_txnSearchQuery) ||
              date.contains(_txnSearchQuery);
        }).toList();

        final start = _txnBatch * batchSize;
        final end = (start + batchSize).clamp(0, txnsList.length);
        final batchTxns = txnsList.sublist(start, end);

        return Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: batchTxns.length,
              itemBuilder: (context, index) {
                final doc = batchTxns[index];
                final data = doc.data() as Map<String, dynamic>;
                final selected = _selectedTxns[doc.id] ?? false;

                return Card(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  child: ListTile(
                    leading: Checkbox(
                      value: selected,
                      onChanged: (val) {
                        setState(() {
                          _selectedTxns[doc.id] = val ?? false;
                        });
                      },
                    ),
                    title: Text(
                      'Transaction: ${doc.id}',
                      style: TextStyle(color: theme.textTheme.bodyLarge!.color),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer: ${data['customerName'] ?? 'Unknown'}',
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium!.color,
                          ),
                        ),
                        Text(
                          'Status: ${data['status'] ?? 'Pending'}',
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium!.color,
                          ),
                        ),
                        Text(
                          'Date: ${(data['date'] as Timestamp?)?.toDate().toString().split(' ')[0] ?? ''}',
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium!.color,
                          ),
                        ),
                      ],
                    ),
                    trailing: Flexible(
                      child: Text(
                        'KSh ${(data['amount'] as num?)?.toStringAsFixed(0) ?? '0'}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium!.color,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _txnBatch > 0
                      ? () => setState(() => _txnBatch--)
                      : null,
                  icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: batchTxns.isNotEmpty
                      ? () => _downloadTransactionPdf(batchTxns)
                      : null,
                  child: const Text('Selected'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: txnsList.isNotEmpty
                      ? () => _downloadTransactionPdf(txnsList)
                      : null,
                  child: const Text('All'),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: end < txnsList.length
                      ? () => setState(() => _txnBatch++)
                      : null,
                  icon: Icon(Icons.arrow_forward, color: theme.iconTheme.color),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ================= PDF DOWNLOAD =================
  Future<void> _downloadItemPdf(List items) async {
    final pdf = pw.Document();
    final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Center(
            child: pw.Text(
              ' Mobi Finance Official Receipt',
              style: pw.TextStyle(font: boldFont, fontSize: 24),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Item', 'Quantity Sold', 'Revenue'],
            data: items.map((e) {
              final entry = e is MapEntry ? e : e;
              if (entry is MapEntry) {
                return [
                  entry.key,
                  entry.value['quantity'],
                  'KSh ${entry.value['revenue'].toStringAsFixed(0)}',
                ];
              } else if (entry is Map<String, dynamic>) {
                return [
                  entry['name'],
                  entry['quantity'],
                  'KSh ${entry['revenue'].toStringAsFixed(0)}',
                ];
              }
              return [];
            }).toList(),
            headerStyle: pw.TextStyle(font: boldFont),
            cellStyle: pw.TextStyle(font: regularFont),
            cellAlignment: pw.Alignment.centerRight,
          ),
        ],
      ),
    );

    await _savePdf(pdf, 'finance_items');
  }

  Future<void> _downloadTransactionPdf(List<QueryDocumentSnapshot> txns) async {
    final pdf = pw.Document();
    final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'Mobi Transaction Official Receipt',
              style: pw.TextStyle(font: boldFont, fontSize: 24),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Transaction ID', 'Customer', 'Amount', 'Status', 'Date'],
            data: txns.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return [
                doc.id,
                data['customerName'] ?? 'Unknown',
                'KSh ${(data['amount'] as num?)?.toStringAsFixed(0) ?? '0'}',
                data['status'] ?? 'Pending',
                (data['date'] as Timestamp?)?.toDate().toString().split(
                      ' ',
                    )[0] ??
                    '',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(font: boldFont),
            cellStyle: pw.TextStyle(font: regularFont),
            cellAlignment: pw.Alignment.centerRight,
          ),
        ],
      ),
    );

    await _savePdf(pdf, 'finance_transactions');
  }

  Future<void> _savePdf(pw.Document pdf, String prefix) async {
    final data = await pdf.save();
    final date = DateTime.now().toIso8601String().split('T').first;
    final fileName = '${prefix}_$date.pdf';

    if (kIsWeb) {
      await Printing.sharePdf(bytes: data, filename: fileName);
    } else {
      final dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) await dir.create(recursive: true);
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(data);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF file saved to ${file.path}')));
    }
  }

  // ================= BATCH CONTROLS =================
  Widget _buildItemBatchControls() => const SizedBox.shrink();
  Widget _buildTxnBatchControls() => const SizedBox.shrink();
}

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PaymentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isProcessing = false;
  String? _error;

  bool get isProcessing => _isProcessing;
  String? get error => _error;

  /// ================= INITIATE MPESA PAYMENT =================
  Future<String?> initiateDarajaPayment({
    required String userId,
    required String phone,
    required double amount,
    required List<Map<String, dynamic>> cartItems,
  }) async {
    try {
      _isProcessing = true;
      _error = null;
      notifyListeners();

      // 1️⃣ Create transaction
      final txRef = _firestore.collection('transactions').doc();

      await txRef.set({
        'userId': userId,
        'phone': phone,
        'amount': amount,
        'items': cartItems,
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      // 2️⃣ Call backend
      final response = await http.post(
        Uri.parse('https://supercultivated-limonitic-adelia.ngrok-free.dev/stkpush'), // 🔁 replace in production
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'transactionId': txRef.id,
          'userId': userId,
          'phone': phone,
          'amount': amount,
        }),
      );

      if (response.statusCode != 200) {
        throw 'STK push failed';
      }

      final data = jsonDecode(response.body);

      if (data['CheckoutRequestID'] != null) {
        await txRef.update({
          'checkoutRequestId': data['CheckoutRequestID'],
        });
      }

      return txRef.id;
    } catch (e) {
      _error = 'Payment initiation failed';
      debugPrint('Payment error: $e');
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// ================= CLEAR CART AFTER SUCCESS =================
  Future<void> clearUserCart(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'cart': [],
    });
  }
}
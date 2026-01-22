import 'package:flutter/material.dart';

class PaymentProvider extends ChangeNotifier {
  double _amount = 0.0;
  bool _isProcessing = false;

  // Getters
  double get amount => _amount;
  bool get isProcessing => _isProcessing;

  // Set the payment amount
  void setAmount(double value) {
    _amount = value;
    notifyListeners();
  }

  // Simulate payment processing
  Future<bool> processPayment() async {
    _isProcessing = true;
    notifyListeners();

    try {
      // Simulate a network/payment delay
      await Future.delayed(const Duration(seconds: 2));

      _isProcessing = false;
      notifyListeners();
      return true; // Payment successful
    } catch (e) {
      _isProcessing = false;
      notifyListeners();
      return false; // Payment failed
    }
  }

  // Reset payment state
  void reset() {
    _amount = 0.0;
    _isProcessing = false;
    notifyListeners();
  }
}

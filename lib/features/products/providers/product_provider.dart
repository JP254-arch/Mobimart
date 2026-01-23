// lib/features/products/providers/product_provider.dart

import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();

  /// Stream of products from the service
  Stream<List<ProductModel>> get products => _service.getProducts();
}

import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';


class ProductProvider extends ChangeNotifier {
final ProductService _service = ProductService();


Stream<List<Product>> get products => _service.getProducts();
}
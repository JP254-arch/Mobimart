import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobimart_app/features/models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();
  StreamSubscription? _subscription;

  final List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];

  String _selectedCategory = 'all';
  String _searchQuery = '';

  List<ProductModel> get filteredProducts => _filteredProducts;
  String get selectedCategory => _selectedCategory;

  ProductProvider() {
    _listenToProducts();
  }

  void _listenToProducts() {
    _subscription = _service.getProducts().listen((products) {
      _allProducts
        ..clear()
        ..addAll(products);
      _applyFilters();
    });
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  void clearFilters() {
    _selectedCategory = 'all';
    _searchQuery = '';
    _applyFilters();
  }

  void _applyFilters() {
    _filteredProducts = _allProducts.where((product) {
      final matchesCategory = _selectedCategory == 'all'
          ? true
          : product.category.toLowerCase() == _selectedCategory;

      final matchesSearch = _searchQuery.isEmpty
          ? true
          : product.name.toLowerCase().contains(_searchQuery) ||
              product.category.toLowerCase().contains(_searchQuery);

      return matchesCategory && matchesSearch;
    }).toList();

    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

import 'package:flutter/material.dart';


class CartProvider extends ChangeNotifier {
final Map<String, int> _items = {};


Map<String, int> get items => _items;


void addItem(String productId) {
_items.update(productId, (value) => value + 1, ifAbsent: () => 1);
notifyListeners();
}


void clear() {
_items.clear();
notifyListeners();
}
}
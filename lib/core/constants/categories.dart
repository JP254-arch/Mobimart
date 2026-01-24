import 'package:flutter/material.dart';

class CategoryItem {
  final String key;
  final String label;
  final IconData icon;

  const CategoryItem({
    required this.key,
    required this.label,
    required this.icon,
  });
}

const List<CategoryItem> categories = [
  CategoryItem(key: 'all', label: 'All', icon: Icons.apps),
  CategoryItem(key: 'electronics', label: 'Electronics', icon: Icons.devices),
  CategoryItem(key: 'laptops', label: 'Laptops', icon: Icons.laptop_mac),
  CategoryItem(key: 'phones', label: 'Phones', icon: Icons.phone_android),
  CategoryItem(key: 'watches', label: 'Watches', icon: Icons.watch),
  CategoryItem(key: 'clothes', label: 'Clothes', icon: Icons.checkroom),
  CategoryItem(key: 'shoes', label: 'Shoes', icon: Icons.directions_run),
  CategoryItem(key: 'books', label: 'Books', icon: Icons.menu_book),
  CategoryItem(key: 'cosmetics', label: 'Cosmetics', icon: Icons.brush),
];

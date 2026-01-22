// lib/features/orders/models/product_model.dart

class ProductModel {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String category;
  final String description;

  ProductModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.category,
    required this.description,
  });

  // Convert from Map (Firestore or mock data)
  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] ?? '',
      description: map['description'] ?? '',
    );
  }

  // Convert to Map (for Firestore or storage)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'category': category,
      'description': description,
    };
  }
}

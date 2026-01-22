class CartItem {
  final String id;         // Unique ID for this cart item
  final String productId;  // ID of the product
  final String name;
  final double price;
  final String imageUrl;
  final int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      productId: productId,
      name: name,
      price: price,
      imageUrl: imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }
}

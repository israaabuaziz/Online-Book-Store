class CartItem {
  final String productId;
  final String name;
  final String category;
  final double price;
  final String description;
  final int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.quantity,
  });

  // Convert CartItem to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'quantity': quantity,
    };
  }

  // Factory method to create CartItem from Firestore data
  factory CartItem.fromFirestore(String productId, Map<String, dynamic> data) {
    return CartItem(
      productId: productId,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] as num).toDouble(),
      description: data['description'] ?? '',
      quantity: (data['quantity'] as num).toInt(),
    );
  }

  // Add copyWith method to create a copy with updated fields
  CartItem copyWith({
    String? productId,
    String? name,
    String? category,
    double? price,
    String? description,
    int? quantity,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
    );
  }
}

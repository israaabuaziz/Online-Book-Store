import 'CartItem.dart';

class Cart {
  final Map<String, CartItem> items;

  Cart({required this.items});

  // Convert Cart to Map for Firestore
  Map<String, dynamic> toMap() {
    return items.map((productId, item) => MapEntry(productId, item.toMap()));
  }

  // Factory method to create Cart from Firestore data
  factory Cart.fromFirestore(Map<String, dynamic> data) {
    final items = data.map((productId, itemData) {
      return MapEntry(
        productId,
        CartItem.fromFirestore(productId, itemData),
      );
    });
    return Cart(items: items);
  }

  // Calculate total price
  double get totalPrice {
    return items.values.fold(
        0.0, (total, item) => total + (item.price * item.quantity));
  }

  // Get total number of items in the cart
  int get totalItems {
    return items.values.fold(0, (total, item) => total + item.quantity);
  }
}

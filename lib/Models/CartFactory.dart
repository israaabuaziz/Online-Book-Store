import 'Cart.dart';
import 'CartItem.dart';

class CartFactory {
  // Create a CartItem from Firestore data
  static CartItem createCartItem(String productId, Map<String, dynamic> data) {
    return CartItem.fromFirestore(productId, data);
  }

  // Create a Cart from Firestore data
  static Cart createCart(Map<String, dynamic> data) {
    return Cart.fromFirestore(data);
  }

  // Create an empty Cart
  static Cart createEmptyCart() {
    return Cart(items: {});
  }
}

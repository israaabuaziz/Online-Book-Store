import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Models/Cart.dart';
import '../Models/CartFactory.dart';
import '../Models/CartItem.dart';
import '../Models/Product.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveUserInfo({
    required String userId,
    required String id,
    required String name,
    required String email,
    required String gender,
    required String phone,
    required DateTime birthday,
    required String address,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'id': id,
        'name': name,
        'email': email,
        'gender': gender,
        'phone': phone,
        'birthday': birthday,
        'address': address,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Fetch user information
  Future<Map<String, dynamic>> fetchUserInfo(String userId) async {
    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(userId).get();

      if (!userSnapshot.exists) {
        throw Exception('User not found');
      }

      return userSnapshot.data() as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // Add a product& Prototype desgin pattern
  Future<void> addProduct(Product product) async {
    try {
      // Clone the product to set createdAt and updatedAt timestamps
      final newProduct = product.clone(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef =
      await _firestore.collection('products').add(newProduct.toMap());
      await _firestore
          .collection('products')
          .doc(docRef.id)
          .update({'id': docRef.id}); // Save the ID in the document
    } catch (e) {
      print('Error adding product: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _firestore
          .collection('products')
          .doc(product.id)
          .update(product.toMap());
      print('Product updated successfully');
    } catch (e) {
      print('Error updating product: $e');
    }
  }

  // Get products as a stream
  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              Product.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Delete a product by ID
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      print('Product deleted successfully');
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  Future<void> addToCart(String productId, Map<String, dynamic> productData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User is not logged in.');
      }

      final cartRef = _firestore.collection('cart').doc(user.uid);
      final cartSnapshot = await cartRef.get();

      if (cartSnapshot.exists && cartSnapshot.data()!.containsKey(productId)) {
        final currentItem = CartFactory.createCartItem(
            productId, cartSnapshot.data()![productId]);

        final updatedItem = currentItem.copyWith(
          quantity: currentItem.quantity + 1,
        );

        await cartRef.update({productId: updatedItem.toMap()});
      } else {
        final newItem = CartItem(
          productId: productId,
          name: productData['name'],
          category: productData['category'],
          price: (productData['price'] as num).toDouble(),
          description: productData['description'],
          quantity: 1,
        );

        await cartRef.set({productId: newItem.toMap()}, SetOptions(merge: true));
      }

      print('Product added to cart successfully!');
    } catch (e) {
      print('Error adding product to cart: $e');
      rethrow;
    }
  }


  Future<Map<String, dynamic>> fetchCartItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final cartRef = FirebaseFirestore.instance.collection('cart').doc(user.uid);
    final cartSnapshot = await cartRef.get();

    if (!cartSnapshot.exists) {
      return {};
    }

    return cartSnapshot.data() ?? {};
  }



  // Add item to cart
  Future<void> increaseItemToCart(String productId) async {
    final user = _auth.currentUser;

    try {
      final userId = user!.uid; // Replace with actual user ID
      final cartRef = _firestore.collection('cart').doc(userId);
      final cartSnapshot = await cartRef.get();
      if (cartSnapshot.exists) {
        final cartData = cartSnapshot.data() ?? {};
        if (cartData.containsKey(productId)) {
          // Increase quantity if the product already exists
          cartData[productId]['quantity']++;
        } else {
          // Add new product to the cart
          cartData[productId] = {
            'name': 'Product Name', // Replace with actual data
            'price': 10.0, // Replace with actual price
            'quantity': 1,
          };
        }
        await cartRef.update(cartData);
      } else {
        // Create a new cart if it doesn't exist
        await cartRef.set({
          productId: {
            'name': 'Product Name', // Replace with actual data
            'price': 10.0, // Replace with actual price
            'quantity': 1,
          }
        });
      }
    } catch (e) {
      throw Exception('Error adding item to cart: $e');
    }
  }

  // Decrease item quantity in cart
  Future<void> decreaseItemQuantity(String productId) async {
    final user = _auth.currentUser;

    try {
      final userId = user!.uid; // Replace with actual user ID
      final cartRef = _firestore.collection('cart').doc(userId);
      final cartSnapshot = await cartRef.get();
      if (cartSnapshot.exists) {
        final cartData = cartSnapshot.data() ?? {};
        if (cartData.containsKey(productId) &&
            cartData[productId]['quantity'] > 1) {
          cartData[productId]['quantity']--;
          await cartRef.update(cartData);
        } else {
          throw Exception('Product quantity is already 1 or does not exist');
        }
      } else {
        throw Exception('Cart does not exist');
      }
    } catch (e) {
      throw Exception('Error decreasing item quantity: $e');
    }
  }

  // Remove item from cart
  Future<void> removeItemFromCart(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final cartRef = FirebaseFirestore.instance.collection('cart').doc(user.uid);
    await cartRef.update({
      productId: FieldValue.delete(),
    });
  }
  Future<void> updateStock(Map<String, int> items) async {
    try {
      for (var productId in items.keys) {
        final quantityToReduce = items[productId] ?? 0;

        // Get the product document reference
        final productRef = _firestore.collection('products').doc(productId);

        // Fetch the current stock data
        final productSnapshot = await productRef.get();
        if (!productSnapshot.exists) {
          throw Exception('Product with ID $productId does not exist.');
        }

        final currentStock = (productSnapshot.data()?['numStock'] as int?) ?? 0;

        // Check if the stock is sufficient
        if (currentStock < quantityToReduce) {
          throw Exception(
              'Insufficient stock for product $productId. Available: $currentStock, Required: $quantityToReduce');
        }

        // Update the stock in Firestore
        await productRef.update({'numStock': currentStock - quantityToReduce});
      }
    } catch (e) {
      // Handle errors (log them or rethrow)
      throw Exception('Error updating stock: $e');
    }
  }

  Future<void> checkoutCart(String userName,String userEmail) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in.');

    final cartRef = _firestore.collection('cart').doc(userId);
    final cartSnapshot = await cartRef.get();
    final cartItems = cartSnapshot.data() ?? {};

    if (cartItems.isEmpty) {
      throw Exception('Cart is empty.');
    }
    // Prepare items to update stock
    final itemsToUpdate = <String, int>{};
    cartItems.forEach((key, value) {
      final itemData = Map<String, dynamic>.from(value as Map);
      final quantity = (itemData['quantity'] as int?) ?? 0;
      itemsToUpdate[key] = quantity;
    });

    // Update stock
    await updateStock(itemsToUpdate);

    final orderRef = _firestore.collection('orders').doc(userId);
    final orderSnapshot = await orderRef.get();

    if (orderSnapshot.exists) {
      // If the order already exists, merge new cart items into existing items
      final existingData = orderSnapshot.data()!;
      final existingItems =
          Map<String, dynamic>.from(existingData['items'] ?? {});
      final updatedItems = {...existingItems};

      cartItems.forEach((key, value) {
        final itemData =
            Map<String, dynamic>.from(value as Map); // Cast value to Map
        if (updatedItems.containsKey(key)) {
          // If item exists, update quantity
          final existingItem = Map<String, dynamic>.from(updatedItems[key]);
          final newQuantity = (existingItem['quantity'] as int? ?? 0) +
              (itemData['quantity'] as int? ?? 0);
          updatedItems[key] = {
            ...existingItem,
            'quantity': newQuantity,
          };
        } else {
          // If item doesn't exist, add it
          updatedItems[key] = itemData;
        }
      });

      // Update the document with new items and recalculated total price
      await orderRef.update({
        'items': updatedItems,
        'totalPrice': updatedItems.values.fold(0.0, (total, item) {
          final itemData = Map<String, dynamic>.from(item as Map);
          final price = (itemData['price'] as double?) ?? 0.0;
          final quantity = (itemData['quantity'] as int?) ?? 1;
        }),
        'timestamp': FieldValue.serverTimestamp(),
        'name':userName,
        'email':userEmail
      });
    } else {
      // If the order doesn't exist, create a new one
      await orderRef.set({
        'items': cartItems,
        'totalPrice': cartItems.values.fold(0.0, (total, item) {
          final itemData = Map<String, dynamic>.from(item as Map);
          final price = (itemData['price'] as double?) ?? 0.0;
          final quantity = (itemData['quantity'] as int?) ?? 1;
          return total + (price * quantity);
        }),
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    // Clear the cart after updating the order
    await cartRef.delete();
  }

  Future<List<Map<String, dynamic>>> fetchOrderHistory() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in.');
    }

    // Reference to the orders collection
    final ordersRef = _firestore.collection('orders').doc(userId);
    final orderSnapshot = await ordersRef.get();

    if (!orderSnapshot.exists) {
      return []; // Return an empty list if no orders exist
    }

    final data = orderSnapshot.data() ?? {};
    final items = data['items'] as Map<String, dynamic>;
    final totalPrice = data['totalPrice'];
    final timestamp = data['timestamp'];

    // Prepare the list for display
    return items.entries.map((entry) {
      final itemData = entry.value as Map<String, dynamic>;
      return {
        'name': itemData['name'] ?? 'Unknown',
        'price': itemData['price'] ?? 0.0,
        'quantity': itemData['quantity'] ?? 0,
        'total': (itemData['price'] ?? 0.0) * (itemData['quantity'] ?? 1),
        'timestamp': timestamp, // Use the timestamp for display
        'orderTotal': totalPrice,
      };
    }).toList();
  }
  Future<List<Map<String, dynamic>>> fetchOrderForAdmin(String id) async {
    final userId =id;
    if (userId == null) {
      throw Exception('User not logged in.');
    }

    // Reference to the orders collection
    final ordersRef = _firestore.collection('orders').doc(userId);
    final orderSnapshot = await ordersRef.get();

    if (!orderSnapshot.exists) {
      return []; // Return an empty list if no orders exist
    }

    final data = orderSnapshot.data() ?? {};
    final items = data['items'] as Map<String, dynamic>;
    final totalPrice = data['totalPrice'];
    final timestamp = data['timestamp'];

    // Prepare the list for display
    return items.entries.map((entry) {
      final itemData = entry.value as Map<String, dynamic>;
      return {
        'name': itemData['name'] ?? 'Unknown',
        'price': itemData['price'] ?? 0.0,
        'quantity': itemData['quantity'] ?? 0,
        'total': (itemData['price'] ?? 0.0) * (itemData['quantity'] ?? 1),
        'timestamp': timestamp, // Use the timestamp for display
        'orderTotal': totalPrice,
      };
    }).toList();
  }

Future<void> saveFeedback({
    required String userId,
    required String username,
    required String email,
    required String productName,
    required String productCategory,
    required String feedback,
    required String rating,
  })
  async {
    try {
      // Define the feedback document structure
      final feedbackData = {
        'userId': userId,
        'username': username,
        'email': email,
        'productName': productName,
        'productCategory': productCategory,
        'feedback': feedback,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Save feedback in the 'feedbacks' collection
      await _firestore.collection('feedbacks').add(feedbackData);
      print('Feedback saved successfully');
    } catch (e) {
      print('Error saving feedback: $e');
      rethrow;
    }
  }

  Future<Map<String, int>> fetchOrderData() async {
    // Fetch the orders collection from Firestore
    final orderRef = FirebaseFirestore.instance.collection('orders');
    final orderSnapshot = await orderRef.get();

    // Create a map to store the aggregated data (product name -> total quantity sold)
    Map<String, int> aggregatedData = {};

    // Iterate through each order
    for (var orderDoc in orderSnapshot.docs) {
      final orderData = orderDoc.data();
      final items = Map<String, dynamic>.from(orderData['items'] ?? {});

      // Iterate through each item in the order
      items.forEach((key, itemData) {
        final itemName = itemData['name'] ?? '';
        final itemQuantity = itemData['quantity'] as int? ?? 0;

        // Aggregate the data by product name
        if (aggregatedData.containsKey(itemName)) {
          aggregatedData[itemName] = aggregatedData[itemName]! + itemQuantity;
        } else {
          aggregatedData[itemName] = itemQuantity;
        }
      });
    }

    return aggregatedData;
  }
  Future<List<String>> getAllCategories() async {
    try {
      // Fetch all products from the 'products' collection
      QuerySnapshot querySnapshot = await _firestore.collection('products').get();

      // Extract unique categories
      final categories = querySnapshot.docs
          .map((doc) => doc['category'] as String)
          .toSet()
          .toList();

      return categories;
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  /// Fetch all products for a specific category
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      // Query Firestore for products matching the category
      QuerySnapshot querySnapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .get();

      // Map Firestore documents to Product instances
      final products = querySnapshot.docs.map((doc) {
        return Product.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();

      return products;
    } catch (e) {
      print('Error fetching products by category: $e');
      return [];
    }
  }
}

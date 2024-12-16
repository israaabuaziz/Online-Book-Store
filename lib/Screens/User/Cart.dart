// cart.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Fire_Services/FireStoreService.dart';

class Cart extends StatefulWidget {
  Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _authService = FirebaseAuth.instance;

  String userId = ''; // Store userId

  // User data variables
  String name = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    userId = _authService.currentUser?.uid ?? '';
    if (userId.isNotEmpty) {
      fetchUserInfo();
    }
  }
  Future<void> fetchUserInfo() async {
    if (userId.isEmpty) {
      print("User ID is empty.");
      return;
    }
    try {
      Map<String, dynamic> data = await _firestoreService.fetchUserInfo(userId);

      setState(() {
        name = data['name'] ?? '';
        email = data['email'] ?? '';

      });
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.shopping_cart, color: Colors.grey),
        title: const Text(
          'Your Cart',
          style: TextStyle(color: Colors.grey),
        ),
        backgroundColor: const Color(0xff8042E1),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _firestoreService.fetchCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final cartItems = snapshot.data ?? {};

          if (cartItems.isEmpty) {
            return const Center(
              child: Text('Your cart is empty.'),
            );
          }

          double totalPrice = 0.0;
          cartItems.forEach((key, item) {
            totalPrice += (item['price'] ?? 0.0) * (item['quantity'] ?? 1);
          });

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final productId = cartItems.keys.elementAt(index);
                    final product = cartItems[productId];
                    return _buildCartItemCard(product, productId);
                  },
                ),
              ),
              const Divider(height: 2, color: Colors.grey),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff8042E1)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await _firestoreService.checkoutCart(name,email);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Purchase successful!')),
                      );
                      setState(() {}); // Refresh the UI to reflect the empty cart.
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff8042E1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        'Buy Now',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),

            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItemCard(Map<String, dynamic> product, String productId) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    '\$${product['price'] ?? 0.0} x ${product['quantity'] ?? 1}',
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Total: \$${((product['price'] ?? 0.0) * (product['quantity'] ?? 1)).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                await _firestoreService.increaseItemToCart(productId);
                setState(() {});
              },
              icon: Icon(Icons.add_box),
            ),
            IconButton(
              onPressed: () async {
                await _firestoreService.decreaseItemQuantity(productId);
                setState(() {});
              },
              icon: Icon(Icons.indeterminate_check_box_sharp),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await _firestoreService.removeItemFromCart(productId);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}

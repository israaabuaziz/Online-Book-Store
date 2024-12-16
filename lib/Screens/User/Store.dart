import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';

import '../../Fire_Services/FireStoreService.dart';
import '../../Models/Product.dart';

class Store extends StatefulWidget {
  const Store({super.key});

  @override
  State<Store> createState() => _StoreState();
}

class _StoreState extends State<Store> {
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  String _searchQuery = '';
  final FirebaseAuth _authService = FirebaseAuth.instance;

  String userId = ''; // Store userId
  String name = '';
  String email = '';
  String gender = '';
  String phone = '';
  DateTime? birthday;
  String address = '';

  // Voice recognition
  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _voiceSearchQuery = '';
  String _selectedCategory = '';
  @override
  void initState() {
    super.initState();
    userId = _authService.currentUser?.uid ?? '';
    if (userId.isNotEmpty) {
      fetchUserInfo();
    }
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
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
        gender = data['gender'] ?? '';
        phone = data['phone'] ?? '';
        birthday = (data['birthday'] as Timestamp).toDate();
        address = data['address'] ?? '';
      });
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // QR Code Scanning function
  Future<void> _scanQRCode() async {
    var result = await BarcodeScanner.scan();
    if (result.rawContent.isNotEmpty) {
      setState(() {
        _searchQuery = result.rawContent;
        _searchController.text = _searchQuery;
      });
    }
  }

  // Start/Stop listening for voice input
  void _toggleListening() async {
    if (_isListening) {
      _speechToText.stop();
    } else {
      bool available = await _speechToText.initialize();
      if (available) {
        _speechToText.listen(onResult: (result) {
          setState(() {
            _voiceSearchQuery = result.recognizedWords;
            _searchController.text = _voiceSearchQuery;
          });
        });
      }
    }
    setState(() {
      _isListening = !_isListening;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),

            // Category Selection Bar
            FutureBuilder<List<String>>(
              future: _firestoreService.getAllCategories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No categories found.'));
                }

                final categories = snapshot.data!;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategory = category; // Update selected category
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedCategory == category
                                ? Colors.purple[700]
                                : const Color(0xff8042E1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            // Product List
            Expanded(
              child: StreamBuilder<List<Product>>(
                stream: _firestoreService.getProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text('No products found.'),
                    );
                  }

                  // Filter products by search query and category
                  final filteredProducts = snapshot.data!
                      .where((product) =>
                  (_selectedCategory == null || product.category == _selectedCategory) &&
                      product.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                      .toList();

                  if (filteredProducts.isEmpty) {
                    return Center(
                      child: Text(
                        'No products match your search.',
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _buildProductCard(product);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        controller: _searchController,
        cursorColor: const Color(0xff8042E1),
        style: Theme.of(context).textTheme.labelLarge,
        decoration: InputDecoration(
          hintText: 'Search Product or items...',
          hintStyle: const TextStyle(
            color: Color(0xff434343),
            fontFamily: 'boahmed',
          ),
          labelStyle: const TextStyle(
            fontFamily: 'boahmed',
          ),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(_isListening ? Icons.mic_off : Icons.keyboard_voice),
                onPressed: _toggleListening,
              ),
              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _scanQRCode,
              ),
            ],
          ),
          filled: true,
          fillColor: Colors.grey[200],
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xff8042E1), width: 2.0),
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Name
            Row(
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Text(
                  '\$${product.price}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),

            // Product Price
            Text(
              product.category,
              style: const TextStyle(
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 10.0),

            // Add to Cart Button
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showFeedbackDialog(product.name, product.category);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.feedback_sharp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5.0),
                      Text(
                        'Feedback',
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff8042E1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await _firestoreService.addToCart(
                          product.id, // Assuming product has an `id` field
                          {
                            'name': product.name,
                            'price': product.price,
                            'quantity': 1,
                            'category': product.category,
                            'description': product.description,
                          },
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} added to cart!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to add to cart: $e'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff8042E1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_shopping_cart_outlined,
                          color: Colors.white,
                        ),
                        SizedBox(width: 5.0),
                        Text(
                          'Add to Cart',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFeedbackDialog(String productName, String productCategory) {
    final TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Leave Feedback'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Product: $productName',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Category: $productCategory',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: feedbackController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Enter your feedback here...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (feedbackController.text.isNotEmpty) {
                  try {
                    // Save feedback to Firebase
                    await _firestoreService.saveFeedback(
                      userId: userId,
                      // Replace with current user ID
                      username: name ?? 'Anonymous',
                      // Replace with user's name
                      email: email ?? '',
                      // Replace with user's email
                      productName: productName,
                      productCategory: productCategory,
                      feedback: feedbackController.text,
                    );

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Feedback submitted successfully!'),
                      ),
                    );
                  } catch (e) {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to submit feedback: $e'),
                      ),
                    );
                  }
                  Navigator.of(context).pop(); // Close the dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Feedback cannot be empty!'),
                    ),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}

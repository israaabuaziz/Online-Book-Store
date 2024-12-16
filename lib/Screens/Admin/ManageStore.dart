import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Fire_Services/FireStoreService.dart';
import '../../Models/Product.dart';
import '../Auth/User_Login.dart';

class ManageStore extends StatefulWidget {
  const ManageStore({Key? key}) : super(key: key);

  @override
  _ManageStoreState createState() => _ManageStoreState();
}

class _ManageStoreState extends State<ManageStore> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _numStockController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  // Show dialog to add product
  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: _categoryController, decoration: const InputDecoration(labelText: 'Category')),
                TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price')),
                TextField(controller: _numStockController, decoration: const InputDecoration(labelText: 'Stock')),
                TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                final product = Product(
                  id: '', // Temporary placeholder, will be updated in Firestore
                  name: _nameController.text,
                  category: _categoryController.text,
                  numStock: int.parse(_numStockController.text),
                  price: double.parse(_priceController.text),
                  description: _descriptionController.text,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                _firestoreService.addProduct(product);
                Navigator.pop(context);
                setState(() {}); // Refresh UI
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Show dialog to edit product
  void _showEditProductDialog(Product product) {
    // Pre-fill the fields with the current product values
    _nameController.text = product.name;
    _categoryController.text = product.category;
   _priceController.text = product.price.toString();
    _numStockController.text = product.numStock.toString();
    _descriptionController.text = product.description;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: _categoryController, decoration: const InputDecoration(labelText: 'Category')),
                TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price')),
                TextField(controller: _numStockController, decoration: const InputDecoration(labelText: 'Stock')),
                TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                final updatedProduct = Product(
                  id: product.id, // Keep the original ID to update the correct product
                  name: _nameController.text,
                  category: _categoryController.text,
                  price: double.parse(_priceController.text),
                  numStock: int.parse(_numStockController.text),
                  description: _descriptionController.text,
                  createdAt: product.createdAt, // Keep the original creation date
                  updatedAt: DateTime.now(), // Update the modified timestamp
                );
                _firestoreService.updateProduct(updatedProduct);
                Navigator.pop(context);
                setState(() {}); // Refresh the UI
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Build product card with edit and delete buttons
  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading:Text(product.category) ,
        title: Text("${product.name} "),
        subtitle: Text("Price:${product.price}, Stock:${product.numStock} "),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: () {
              _showEditProductDialog(product);
            }),
            IconButton(
              icon: const Icon(Icons.delete,color: Colors.red,),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                  title: Text("Delete Product"),
                  content: Text("Are you sure you want to delete '${product.name}'?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Cancel",style: TextStyle(color: Colors.blue),),
                    ),
                    TextButton(
                      onPressed: () {
                        _firestoreService.deleteProduct(product.id);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Product deleted successfully!"),backgroundColor: Colors.red,),
                        );
                      },
                      child: Text("Delete", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                );
    },
    );
                // Refresh UI
              },
            ),
          ],
        ),
      ),
    );
  }
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                signOut(context); // Call signOut function from FireAuthService
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      // Navigate to the login screen
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => UserLogin(

          ), // Replace with your target screen
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          },
        ),
      );
    } catch (e) {
      print('Logout failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.store,color: Colors.grey,),
        title: const Text('Manage Store',style: TextStyle(color: Colors.grey),),
        actions: [
          // Logout Button
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.grey),
            onPressed: () {
              _showLogoutDialog(context); // Show confirmation dialog
            },
          ),
        ],
        backgroundColor: const Color(0xff8042E1),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add,color: Colors.grey,),
        backgroundColor: const Color(0xff8042E1),
      ),
      body: StreamBuilder<List<Product>>(
        stream: _firestoreService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final products = snapshot.data ?? [];
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) => _buildProductCard(products[index]),
          );
        },
      ),
    );
  }
}

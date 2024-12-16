import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:online_book_store/Screens/Auth/User_Login.dart';

import '../../Fire_Services/FireStoreService.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _authService = FirebaseAuth.instance;

  String userId = ''; // Store userId

  // User data variables
  String name = '';
  String email = '';
  String gender = '';
  String phone = '';
  DateTime? birthday;
  String address = '';

  @override
  void initState() {
    super.initState();
    // Set the userId before calling fetchUserInfo
    userId = _authService.currentUser?.uid ?? '';
    if (userId.isNotEmpty) {
      fetchUserInfo();
    }
  }

  // Fetch user information using FirestoreService
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


  // Show confirmation dialog before logging out
  // Show logout dialog
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.person, color: Colors.grey),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.grey),
        ),
        backgroundColor: Colors.deepPurple, // Custom AppBar color
        actions: [
          // Logout Button
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.grey),
            onPressed: () {
              _showLogoutDialog(context); // Show confirmation dialog
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: name.isEmpty
            ? const Center(child: CircularProgressIndicator()) // Show loading spinner if user data is not loaded yet
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            Center(
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Color(0xff8042E1),
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Name
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Name: $name',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Email
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Email: $email',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Gender
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Gender: $gender',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Phone
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Phone: $phone',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Birthday
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Birthday: ${birthday != null ? '${birthday!.day}/${birthday!.month}/${birthday!.year}' : ''}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Address
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Address: $address',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
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
}

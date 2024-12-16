import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:online_book_store/Screens/Auth/User_Login.dart';

class FirebaseAuthService {
  // Private constructor
  FirebaseAuthService._internal();

  // Static instance
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();

  // Factory constructor
  factory FirebaseAuthService() {
    return _instance;
  }

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      return user;
    } on FirebaseAuthException catch (e) {
      throw e; // Rethrow the exception to handle it in the calling function
    } catch (e) {
      print(e.toString());
      throw Exception('An unexpected error occurred.'); // Handle general exceptions
    }
  }

  Future<User?> signInWithAdminCredentials(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        DocumentSnapshot adminSnapshot =
        await _firestore.collection('admins').doc(user.uid).get();
        if (adminSnapshot.exists) {
          return user;
        } else {
          throw Exception('User is not an admin.');
        }
      } else {
        throw Exception('User not found');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception('FirebaseAuthException: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signInWithUserCredentials(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(user.uid).get();
        if (userSnapshot.exists) {
          return user;
        }
      } else {
        throw Exception('User not found');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception('FirebaseAuthException: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => UserLogin()),
      );
    } catch (e) {
      print('Logout failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout failed. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw 'Failed to send password reset email: ${e.message}';
    }
  }
}

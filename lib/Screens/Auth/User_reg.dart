import 'package:flutter/material.dart';
import '../../Components/birthday.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Components/selectgender.dart';  // Import the Selectgender widget

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();  // Gender controller
  DateTime? _birthday;
  String _errorMessage = '';
  bool _obscureText = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showErrorDialog(String message) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: Material(
            type: MaterialType.transparency,
            child: AlertDialog(
              title: const Text('Error'),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Color(0xff12082A2)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(anim1),
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _registerUser() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String name = _nameController.text.trim();
    final String phone = _phoneController.text.trim();
    final String address = _addressController.text.trim();
    final String gender = _genderController.text.trim();  // Get the gender

    if (email.isEmpty ||
        password.isEmpty ||
        name.isEmpty ||
        phone.isEmpty ||
        _birthday == null ||
        gender.isEmpty) {  // Make sure gender is selected
      _showErrorDialog('All fields are required.');
      return;
    }

    try {
      // Register user
      User? user = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).then((value) => value.user);

      if (user != null) {
        // Save user info
        await _firestore.collection('users').doc(user.uid).set({
          'id': user.uid,
          'name': name,
          'email': email,
          'gender': gender,
          'phone': phone,
          'birthday': _birthday,
          'address': address,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Navigate to the next screen or show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful!')),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showErrorDialog('The email is already in use.');
      } else if (e.code == 'weak-password') {
        _showErrorDialog('The password is too weak.');
      } else {
        _showErrorDialog(e.message ?? 'An unexpected error occurred.');
      }
    } catch (e) {
      _showErrorDialog('An unexpected error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff8042E1),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          title: const Text(
            'Register For User',
            style: TextStyle(color: Colors.white, fontFamily: 'boahmed'),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWideScreen ? screenWidth * 0.1 : 14.0,
            vertical: 14.0,
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Email TextField
                  TextField(
                    controller: _emailController,
                    decoration: _inputDecoration('Email', Icons.email),
                  ),
                  const SizedBox(height: 10),

                  // Password TextField
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: _inputDecoration('Password', Icons.lock)
                        .copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Full Name TextField
                  TextField(
                    controller: _nameController,
                    decoration: _inputDecoration('Full Name', Icons.person),
                  ),
                  const SizedBox(height: 20),

                  // Phone TextField
                  TextField(
                    controller: _phoneController,
                    decoration: _inputDecoration('Phone', Icons.phone),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _addressController,
                    decoration: _inputDecoration('Address', Icons.home),
                  ),
                  const SizedBox(height: 20),
                  // Birthday Picker
                  Birthday(
                    onDateSelected: (date) {
                      setState(() {
                        _birthday = date;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Gender Selection
                  Selectgender(
                    title: 'Select Gender',
                    options: ['Male', 'Female'],
                    groupValue: _genderController.text,
                    onChanged: (value) {
                      setState(() {
                        _genderController.text = value ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Register Button
                  ElevatedButton(
                    onPressed: _registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff8042E1),
                      padding: EdgeInsets.symmetric(
                        horizontal: isWideScreen ? 100.0 : 50.0,
                        vertical: 15,
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        'Register',
                        style: TextStyle(
                          fontFamily: 'boahmed',
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xff8042E1)),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xff8042E1), width: 2.0),
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xff8042E1), width: 2.0),
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
    );
  }
}

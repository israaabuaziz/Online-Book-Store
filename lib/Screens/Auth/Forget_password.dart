import 'package:flutter/material.dart';

import '../../Fire_Services/Auth_Service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();

  String _errorMessage = '';
  void _resetPassword() async {
    setState(() {
      _errorMessage = ''; // Clear any previous error message
    });

    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage =
        'Please enter your email address to reset your password.';
      });
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(_emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
            Text('Password reset email sent to ${_emailController.text}')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);

        // Return false to prevent the default back action
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
          title: Text(
            'Reset Password',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'boahmed',
            ),
          ),
        ),
        body: Padding(
          padding:
          EdgeInsets.symmetric(horizontal: isWideScreen ? 100.0 : 16.0),
          // Adjust padding for wide screens
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Email TextField
                TextField(
                  controller: _emailController,
                  cursorColor: const Color(0xff8042E1),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email, color: Color(0xff8042E1)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xff8042E1), width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xff8042E1), width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                  ),
                ),
                const SizedBox(height: 20),

                // Reset Password Button
                ElevatedButton(
                  onPressed: (){
                    _resetPassword();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff8042E1),
                    padding: EdgeInsets.symmetric(
                        horizontal: isWideScreen ? 100.0 : 50.0, vertical: 15),
                    textStyle: TextStyle(fontSize: isWideScreen ? 24 : 20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(

                            'Reset Password',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'boahmed',
                        )),
                  ),
                ),

                const SizedBox(height: 20),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: TextStyle(
                        fontFamily: 'boahmed',
                        color: Colors.red,
                        fontSize: isWideScreen
                            ? 18
                            : 16), // Adjust font size for error messages
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

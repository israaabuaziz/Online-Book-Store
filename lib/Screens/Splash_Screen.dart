import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Auth/User_Login.dart';


class SplashScreen1 extends StatefulWidget {

  const SplashScreen1({super.key});

  @override
  _SplashScreen1State createState() => _SplashScreen1State();
}

class _SplashScreen1State extends State<SplashScreen1>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController and Animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Duration of the animation
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    // Start the fade-in animation
    _controller.forward();

    // Navigate to the next screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: Duration(seconds: 1),
          // Duration of the transition animation
          pageBuilder: (context, animation, secondaryAnimation) {
            return UserLogin(

            );
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final Size screenSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xffCBD2FF),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/3934.jpg',
                // Make sure to add your logo image to the assets folder and update the path
                height: screenSize.height *
                    0.2, // Adjust height based on screen size
              ),
              SizedBox(height: screenSize.height * 0.02),
              FadeTransition(
                opacity: _fadeAnimation, // Apply the fade animation to the text
                child: Center(
                  child: Text(
                    textAlign: TextAlign.center,
                    'Online Book Store',
                    style: TextStyle(
                        fontSize: screenSize.width * 0.06,
                        // Adjust font size based on screen width
                        color: Color(0xffC53D2C),
                        fontFamily: 'boahmed'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

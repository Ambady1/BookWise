import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookwise/functions/homepage/screens/homepage.dart';
import 'package:bookwise/functions/loginandsignup/screens/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Add a delay to show the splash screen for a few seconds
    await Future.delayed(const Duration(seconds: 2)); // Adjust the duration as needed

    // Check authentication state
    if (FirebaseAuth.instance.currentUser != null) {
      // User is authenticated, navigate to home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      // User is not authenticated, navigate to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: FlutterLogo(size: 200.0), // Your splash screen content
      ),
    );
  }
}

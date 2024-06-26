
import 'package:bookwise/functions/admin/mainpage/adminMainscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookwise/functions/loginandsignup/screens/login.dart';
import 'package:bookwise/functions/mainscreen/mainscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen(context , FirebaseAuth.instance.currentUser);
  }

  void _navigateToNextScreen(BuildContext context, User? user) async {
  if (user != null) {
    // Check if the user is in the 'libraries' collection using the user ID
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('libraries')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      // User is in the 'libraries' collection, navigate to AdminMainScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminMainScreen()),
      );
    } else {
      // User is not in the 'libraries' collection, navigate to MainScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  } else {
    // User is not authenticated, navigate to LoginPage
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
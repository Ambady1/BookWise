// logout.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookwise/functions/loginandsignup/screens/login.dart';

Future<void> logout(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  } catch (e) {
    print('Error logging out: $e');
    // Handle error if needed
  }
}

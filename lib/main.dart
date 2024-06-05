import 'package:bookwise/functions/Profile/screens/profile.dart';
import 'package:bookwise/functions/admin/adminsighnup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Adjust the import path if necessary

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    return MaterialApp(
      home: currentUser != null ? MyProfile(uid: currentUser.uid) : AdminSignUp(),
    );
  }
}

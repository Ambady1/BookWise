import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookwise/common/toast.dart';
import 'package:bookwise/functions/admin/adminhomepage.dart';
import 'package:bookwise/functions/loginandsignup/firebase_auth_ser.dart';
import 'package:bookwise/functions/admin/adminlogin.dart';
import 'package:bookwise/widgets/form_container_widget.dart';

class AdminSignUp extends StatefulWidget {
  const AdminSignUp({Key? key});

  @override
  State<AdminSignUp> createState() => _AdminSignUpState();
}

class _AdminSignUpState extends State<AdminSignUp> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? selectedCity; // Add selectedCity variable
  List<String> cities = [
    'Thiruvananthapuram',
    'Kochi',
    'Kozhikode',
    'Kollam',
    'Thrissur',
    'Alappuzha',
    'Palakkad',
    'Kannur',
    'Kottayam',
    'Malappuram',
    'Kasaragod',
    'Pathanamthitta',
    'Idukki',
    'Ernakulam',
    'Wayanad'
  ];

  bool isSigningUp = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Register"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Register",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 30,
              ),
              FormContainerWidget(
                controller: _usernameController,
                hintText: "Library name",
                isPasswordField: false,
              ),
              const SizedBox(
                height: 10,
              ),
              DropdownButtonFormField<String>(
                value: selectedCity,
                hint: Text('Select City'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCity = newValue;
                  });
                },
                items: cities.map<DropdownMenuItem<String>>((String city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
              ),
              const SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                controller: _emailController,
                hintText: "Email",
                isPasswordField: false,
              ),
              const SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                controller: _passwordController,
                hintText: "Password",
                isPasswordField: true,
              ),
              const SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () {
                  _register();
                },
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: isSigningUp
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Register",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already registered?"),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AdminLoginPage()),
                          (route) => false);
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _register() async {
    setState(() {
      isSigningUp = true;
    });

    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signUpWithEmailAndPassword(email, password);

    setState(() {
      isSigningUp = false;
    });
    if (user != null) {
      await addUserDetails(username, email, selectedCity, user.uid); // Pass selectedCity here
      showToast(message: "Library is successfully registered");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const AdminHomePage()));
    } else {
      showToast(message: "Some error happened");
    }
  }
}

Future<void> addUserDetails(String username, String email, String? cityname, String uid) async {
  try {
    await FirebaseFirestore.instance.collection('libraries').doc(uid).set({
      'username': username,
      'email': email,
      'cityname': cityname,
      'uid': uid,
    });
  } catch (e) {
    print('Error adding user details: $e');
    throw e; // Rethrow the error to handle it where addUserDetails is called
  }
}

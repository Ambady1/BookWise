import 'package:bookwise/common/constants/colors_and_fonts.dart';
import 'package:bookwise/common/constants/colors_and_fonts.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookwise/common/randomname.dart';
import 'package:bookwise/common/assignAvatar.dart';
import 'package:bookwise/functions/admin/adminsighnup.dart';
import 'package:bookwise/functions/loginandsignup/firebase_auth_ser.dart';
import 'package:bookwise/functions/loginandsignup/screens/login.dart';
import 'package:bookwise/functions/mainscreen/mainscreen.dart';
import 'package:bookwise/common/toast.dart';
import 'package:bookwise/widgets/form_container_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isSigningUp = false;
  String? selectedCity; // Declare selectedCity here
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
      backgroundColor: AppColors.blackbg,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/final.png",
                      width: 80,
                      height: 80,
                    ),
                    Image.asset(
                      "assets/textwhite.png",
                      width: 170.w,
                      height: 300,
                    )
                  ]),
              const SizedBox(height: 30),
              FormContainerWidget(
                controller: _usernameController,
                hintText: "Username",
                isPasswordField: false,
              ),
              const SizedBox(height: 10),
              FormContainerWidget(
                controller: _emailController,
                hintText: "Email",
                isPasswordField: false,
              ),
              const SizedBox(height: 10),
              FormContainerWidget(
                controller: _passwordController,
                hintText: "Password",
                isPasswordField: true,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedCity,
                hint: const Text('Select City',
                    style: TextStyle(color: Colors.white)),
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
                selectedItemBuilder: (BuildContext context) {
                  return cities.map<Widget>((String city) {
                    return Text(
                      city,
                      style: TextStyle(color: Colors.white),
                    );
                  }).toList();
                },
                dropdownColor: Colors
                    .black, // Optional: To set the dropdown menu background color
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: TextStyle(
                    color: Colors
                        .white), // To change the color of the dropdown items
              ),

              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  _signUp();
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
                            "Sign Up",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?",
                      style: TextStyle(color: Colors.white)),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
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
              const SizedBox(height: 20),
              GestureDetector(
                child: Container(
                  width: double.infinity,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 23, 98, 173),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      "Register as a library",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminSignUp()),
                      (route) => false);
                },
              ),
              const SizedBox(height: 20), // Add some space at the bottom
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  void _signUp() async {
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
      await addUserDetails(
          username, email, user.uid, selectedCity); // Pass selectedCity here
      showToast(message: "User is successfully created");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MainScreen()));
    } else {
      showToast(message: "Some error happened");
    }
  }
}

Future<void> addUserDetails(
    String username, String email, String uid, String? selectedCity) async {
  try {
    String profilePicture = await getAvatarUrls();

    String nickname = generateUniqueReaderName();
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'username': username,
      'email': email,
      'uid': uid,
      'nickname': nickname,
      'followers': [],
      'following': [],
      'profilePicture': profilePicture,
      'city': selectedCity, // Use selectedCity directly
    });
  } catch (e) {
    print('Error adding user details: $e');
    throw e;
  }
}

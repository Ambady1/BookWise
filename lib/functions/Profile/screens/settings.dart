import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      // Get the current user's UID
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Fetch the user document from Firestore
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      // Update the text controllers with the fetched data
      if (userSnapshot.exists) {
        setState(() {
          _nameController.text = userSnapshot['username'] ?? '';
          _usernameController.text = userSnapshot['nickname'] ?? '';
          _emailController.text = userSnapshot['email'] ?? '';
          // Password is not fetched for security reasons
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Account',
          style: TextStyle(
            color: Colors.black87.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _saveSettings();
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ListTile(
              title: Text(
                'Name',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  fillColor: Colors.white70,
                  hintText:
                      _nameController.text.isNotEmpty ? null : 'Enter your name',
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text(
                'Username',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  fillColor: Colors.white70,
                  hintText: _usernameController.text.isNotEmpty
                      ? null
                      : 'Enter your username',
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text(
                'Email',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  fillColor: Colors.white70,
                  hintText: _emailController.text.isNotEmpty
                      ? null
                      : 'Enter your email',
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text(
                'Password',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  fillColor: Colors.white70,
                  hintText: '******', // Displaying placeholder for password
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                obscureText: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveSettings() {
    // Implement your save logic here
    String name = _nameController.text.trim();
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Print the values for demonstration (replace with your logic)
    print('Name: $name');
    print('Username: $username');
    print('Email: $email');
    print('Password: $password');
  }
}

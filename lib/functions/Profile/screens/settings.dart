import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _descriptionController.dispose();
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
          _nicknameController.text = userSnapshot['nickname'] ?? '';
          _descriptionController.text = userSnapshot['description'] ?? '';
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
                'Username',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  fillColor: Colors.white70,
                  hintText: _nicknameController.text.isNotEmpty
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
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  fillColor: Colors.white70,
                  hintText: _descriptionController.text.isNotEmpty
                      ? null
                      : 'Enter a description',
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                maxLines: null, // Allow multiple lines
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    // Implement your save logic here
    String nickname = _nicknameController.text.trim();
    String description = _descriptionController.text.trim();

    // Save to Firestore
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'nickname': nickname,
        'description': description,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Settings saved successfully')),
      );
    } catch (e) {
      print('Error saving settings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving settings')),
      );
    }
  }
}

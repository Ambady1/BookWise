import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:bookwise/functions/loginandsignup/screens/login.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String? _fileContent;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String csvData = await file.readAsString();
      setState(() {
        _fileContent = csvData;
      });
      await _processCsvData(csvData);
    } else {
      // User canceled the file picker
    }
  }

  Future<void> _processCsvData(String csvData) async {
    List<List<dynamic>> csvTable = CsvToListConverter().convert(csvData);

    CollectionReference collectionRef = FirebaseFirestore.instance.collection('books');
    QuerySnapshot booksSnapshot = await collectionRef.get();
    if (booksSnapshot.docs.isEmpty) {
      // Collection doesn't exist, create a sample document (optional)
      await collectionRef.doc().set({
        'title': 'Sample Book',
        'libraries': [
          {'libraryName': 'Default Library', 'copyCount': 1},
        ],
      });
    }

    // Get current user information
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User is not authenticated.');
      return;
    }

    String? currentUserName;
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('libraries').doc(user.uid);

    try {
      DocumentSnapshot userSnapshot = await userDocRef.get();
      if (userSnapshot.exists) {
        var data = userSnapshot.data() as Map<String, dynamic>?; // Type casting
        if (data != null && data.containsKey('username')) {
          currentUserName = data['username'];
        } else {
          print('Username not found in the user document.');
        }
      } else {
        print('User document not found in Firestore.');
      }
    } catch (e) {
      print('Error getting user document: $e');
    }

    if (currentUserName == null) {
      print('Current user name is null.');
      return;
    }

    for (var row in csvTable) {
      if (row.length < 2) {
        print('Invalid row format: $row');
        continue;
      }

      String title = row[0].toString();
      int copyCount = int.tryParse(row[1].toString()) ?? 0;

      // Check if the book exists
      QuerySnapshot titleSnapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('title', isEqualTo: title)
          .get();

      if (titleSnapshot.docs.isNotEmpty) {
        // Book exists, update the copy count
        DocumentSnapshot document = titleSnapshot.docs.first;
        List<dynamic> libraries = document['libraries'];

        bool libraryExists = false;
        for (var library in libraries) {
          if (library is Map && library['username'] == currentUserName) {
            library['copyCount'] += copyCount;
            libraryExists = true;
            break;
          }
        }

        if (!libraryExists) {
          libraries.add({
            'libraryName': currentUserName,
            'copyCount': copyCount,
          });
        }

        await document.reference.update({'libraries': libraries});
      } else {
        // Book does not exist, create a new document
        await FirebaseFirestore.instance.collection('books').add({
          'title': title,
          'libraries': [
            {
              'libraryName': currentUserName,
              'copyCount': copyCount,
            }
          ],
        });
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: _pickFile,
                child: const Text('Add a new file'),
              ),
              const SizedBox(height: 20),
              _fileContent != null
                  ? Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          _fileContent!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

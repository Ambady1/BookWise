import 'dart:async';
import 'dart:io';
import 'package:bookwise/common/constants/colors_and_fonts.dart';
import 'package:bookwise/functions/admin/listBooks.dart';
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
  Future<String> _getCurrentUsername() async {
    // Get current user information
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated.');
    }
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('libraries').doc(user.uid);
    try {
      DocumentSnapshot userSnapshot = await userDocRef.get();
      if (userSnapshot.exists) {
        var data = userSnapshot.data() as Map<String, dynamic>?; // Type casting
        if (data != null && data.containsKey('username')) {
          return data['username'] as String;
        } else {
          throw Exception('Username not found in the user document.');
        }
      } else {
        throw Exception('User document not found in Firestore.');
      }
    } catch (e) {
      throw Exception('Error getting user document: $e');
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String csvData = await file.readAsString();
      await _processCsvData(csvData);
    } else {
      // User canceled the file picker
    }
  }

  Future<void> _processCsvData(String csvData) async {
    String currentUserName = await _getCurrentUsername();
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvData);

    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('books');
    QuerySnapshot booksSnapshot = await collectionRef.get();
    if (booksSnapshot.docs.isEmpty) {
      print("No Collection named books");
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
          if (library is Map && library['libraryName'] == currentUserName) {
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

      // Create or update the user's library collection
      DocumentReference userLibraryDocRef =
          FirebaseFirestore.instance.collection(currentUserName).doc(title);

      try {
        DocumentSnapshot userLibrarySnapshot = await userLibraryDocRef.get();
        if (userLibrarySnapshot.exists) {
          // Update existing document
          await userLibraryDocRef.update({
            'copyCount': FieldValue.increment(copyCount),
          });
        } else {
          // Create new document
          await userLibraryDocRef.set({
            'title': title,
            'copyCount': copyCount,
          });
        }
      } catch (e) {
        print('Error updating user library document: $e');
      }
    }
  }

  Future<Map<String, dynamic>?> fetchLibraryDetails() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('User not authenticated');
        return null;
      }

      final collection = FirebaseFirestore.instance.collection('libraries');
      final userDoc = await collection.doc(currentUser.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data();
        return data;
      } else {
        print('Document does not exist');
        return null;
      }
    } catch (e) {
      print('Error fetching library details: $e');
      return null;
    }
  }

  // Future<void> _logout(BuildContext context) async {
  //   try {
  //     await FirebaseAuth.instance.signOut();
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => const LoginPage(),
  //       ),
  //     );
  //   } catch (e) {
  //     print('Error logging out: $e');
  //     // Handle error if needed
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchLibraryDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While fetching data, show a loading indicator or placeholder
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          if (snapshot.hasError) {
            // If there's an error fetching data, display an error message
            return Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            // If no data is available, handle it accordingly
            return const Scaffold(
              body: Center(
                child: Text('No data available'),
              ),
            );
          } else {
            // Data fetched successfully, display the UI with fetched data
            final data = snapshot.data!;
            return Scaffold(
              backgroundColor: AppColors.blackbg,
              body: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height / 5,
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(45),
                              bottomRight: Radius.circular(45),
                            ),
                          ),
                          child: SafeArea(
                            minimum: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Spacer(),
                                Text(
                                  '${data['username'] ?? 'Admin'}',
                                  style:
                                      Theme.of(context).textTheme.displayLarge,
                                ),
                                const Spacer(
                                  flex: 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 4,
                                  child: InkWell(
                                    onTap: () {
                                      _pickFile();
                                    },
                                    borderRadius: BorderRadius.circular(15),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.upload_file,
                                            size: 50,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Add Book (csv)',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 4,
                                  child: InkWell(
                                    onTap: () async {
                                      try {
                                        String username =
                                            await _getCurrentUsername();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ListBooks(username: username),
                                          ),
                                        );
                                      } catch (e) {
                                        print('Error: $e');
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(15),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.info,
                                            size: 50,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'List Books',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 4,
                                  child: InkWell(
                                    onTap: () {
                                      // Dummy option logic
                                    },
                                    borderRadius: BorderRadius.circular(15),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.settings,
                                            size: 50,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Edit Data',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        }
      },
    );
  }
}

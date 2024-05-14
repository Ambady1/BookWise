import 'dart:async';

import 'package:bookwise/functions/Profile/screens/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController _searchController = TextEditingController();
  StreamController<String> _queryController = StreamController<String>();

  Future<String?> getClickedUserUidFromUsername(String username) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final userDoc = snapshot.docs.first;
        return userDoc.id; // Assuming UID is stored as the document ID
      } else {
        return null; // Username not found
      }
    } catch (error) {
      // Handle any errors during Firestore interactions
      print('Error fetching UID: $error');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _queryController = StreamController<String>.broadcast();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _queryController.close();
    super.dispose();
  }

  void _onSearchChanged() {
    _queryController.add(_searchController.text);
  }

  Widget _buildSuggestions(BuildContext context, String query) {
    if (query.isEmpty) {
      return SizedBox.shrink(); // Return an empty widget if query is empty
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThan: query + 'z')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final List<String> suggestions = snapshot.data!.docs.map((doc) {
          return doc['username'] as String;
        }).toList();

        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            // Access the document ID
            return ListTile(
              title: Text(suggestion), // Use the suggestion variable here
              onTap: () async {
                final currentUser = FirebaseAuth.instance.currentUser;

                if (currentUser != null) {
                  final clickedUsername = suggestion; // Use the suggestion variable here
                  final clickedUid =
                      await getClickedUserUidFromUsername(clickedUsername);

                  if (clickedUid != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MyProfile(
                          uid: clickedUid,
                        ),
                      ),
                    );
                  } else {
                    // Handle case where UID is not found (e.g., show error message)
                    print('Username not found');
                  }
                } else {
                  // Handle case where no user is logged in (e.g., prompt for login)
                  print('Please log in to search users');
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.withOpacity(0.5),
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Search for users',
            border: InputBorder.none,
          ),
        ),
      ),
      body: StreamBuilder<String>(
        stream: _queryController.stream,
        initialData: '',
        builder: (context, snapshot) {
          return _buildSuggestions(context, snapshot.data!);
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookwise/functions/community/repositories/firebasecall.dart';
import 'package:bookwise/functions/Profile/screens/profile.dart';

class SearchScreen extends SearchDelegate<String> {
  FirebaseCall _firebaseCall = FirebaseCall();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context, query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context, query);
  }

  Widget _buildSearchResults(BuildContext context, String query) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThan: query + 'z')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final List<String> suggestions = snapshot.data!.docs
            .map((doc) => doc['username'] as String)
            .where((username) =>
                username.toLowerCase().contains(query.toLowerCase()))
            .toList();

        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return ListTile(
              title: Text(suggestion),
              onTap: () async {
                final currentUser = FirebaseAuth.instance.currentUser;

                if (currentUser != null) {
                  final clickedUid = await _firebaseCall
                      .getClickedUserUidFromUsername(suggestion);

                  if (clickedUid != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MyProfile(
                          uid: clickedUid,
                        ),
                      ),
                    );
                  } else {
                    print('Username not found');
                  }
                } else {
                  print('Please log in to search users');
                }
              },
            );
          },
        );
      },
    );
  }
}

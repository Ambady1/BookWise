import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookwise/functions/community/widgets/postwidget.dart';

class UserPostFeedScreen extends StatelessWidget {
  final String uid;

  const UserPostFeedScreen({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Posts'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('userId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var posts = snapshot.data!.docs;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var post = posts[index];
              return PostWidget(post.data());
            },
          );
        },
      ),
    );
  }
}

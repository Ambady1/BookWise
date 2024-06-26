import 'package:bookwise/functions/community/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class FireServices {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel> getUser() async {
    try {
      final userDoc = await _firebaseFirestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data();
        // Convert Firestore data to UserModel
        return UserModel.fromMap(userData!);
      } else {
        throw Exception('User document does not exist');
      }
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  Future<bool> createPost({
    required String? postId,
    required String? title,
    required String? description,
    required String? postImage,
    required List<String>? likes,
    required List<String>? comments,
    required String? username,
    required DateTime? createdAt,
  }) async {
    var uid = Uuid().v4();
    UserModel user = await getUser();
    await _firebaseFirestore.collection('posts').doc(uid).set({
      'postId': postId,
      'title': title,
      'description': description,
      'postImage': postImage,
      'likes': likes,
      'comments': comments,
      'username': username,
      'userId': user.uid,
      'createdAt': createdAt
    });
    return true;
  }
}

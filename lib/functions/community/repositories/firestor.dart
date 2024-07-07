import 'package:bookwise/functions/community/core/utils.dart';
import 'package:bookwise/functions/community/models/user_model.dart';
import 'package:bookwise/functions/community/repositories/storage.dart';
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

  Future<bool> createPost(
      {required String? postType,
      required String? title,
      String? postImageId,
      String? postImage,
      String? description,
      String? link}) async {
    var uid = Uuid().v4();
    DateTime createdAt = DateTime.now();
    UserModel user = await getUser();
    print(
        "UserModel in createPost: ${user.profilePic}"); // Debug: Check the profilePic

    // Handle null values and provide defaults where necessary
    await _firebaseFirestore.collection('posts').doc(uid).set({
      'postType': postType ?? '',
      'postId': uid,
      'title': title ?? '',
      'postImageId': postImageId ?? '',
      'postImage': postImage ?? '',
      'description': description ?? '',
      'link': link ?? '',
      'likes': [],
      'comments': [],
      'username': user.username,
      'userId': user.uid,
      'nickname': user.nickname,
      'createdAt': createdAt,
      'profilePicture':
          user.profilePic ?? '' // Provide a default empty string if null
    });
    return true;
  }

  Future<bool> isMyPost({required String userId}) async {
    try {
      UserModel user = await getUser();
      return user.uid == userId;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteMyPost(String postId, String? postImage) async {
    try {
      // First, attempt to delete the image if postImage is not null
      if (postImage != null) {
        bool imageDeleted =
            await StorageMethod().deleteImagefromStorage(postImage);
        if (!imageDeleted) {
          // If the image deletion failed, return false
          return false;
        }
      }

      // If image deletion was successful or if there was no image, delete the post
      await _firebaseFirestore.collection('posts').doc(postId).delete();
      return true;
    } catch (e) {
      print('Error deleting post: $e');
      return false;
    }
  }

  Future<bool> likePost(String postId) async {
    try {
      UserModel user = await getUser();
      String userId = user.uid;

      DocumentReference postRef =
          _firebaseFirestore.collection('posts').doc(postId);

      await _firebaseFirestore.runTransaction((transaction) async {
        DocumentSnapshot postSnapshot = await transaction.get(postRef);

        if (postSnapshot.exists) {
          List likes = postSnapshot['likes'] ?? [];

          if (likes.contains(userId)) {
            // If user already liked the post, remove the like
            transaction.update(postRef, {
              'likes': FieldValue.arrayRemove([userId])
            });
          } else {
            // Otherwise, add the like
            transaction.update(postRef, {
              'likes': FieldValue.arrayUnion([userId])
            });
          }
        }
      });

      return true;
    } catch (e) {
      print("Error liking post: $e");
      return false;
    }
  }

  Future<bool> isPostLikedByuser(String postId) async {
    try {
      UserModel user = await getUser();
      String userId = user.uid;
      DocumentSnapshot postDoc =
          await _firebaseFirestore.collection('posts').doc(postId).get();
      // Check if the 'likes' field contains the current user's UID
      List<dynamic> likes = postDoc.get('likes');
      return likes.contains(userId);
    } catch (e) {
      return false;
    }
  }

  Future<bool> commentPost(String postId, String content) async {
    try {
      var uid = Uuid().v4();
      UserModel user = await getUser();
      String userId = user.uid;
      String username = user.username;
      String? profilePic = user.profilePic;
      // Reference to the specific post document
      DocumentReference postRef =
          _firebaseFirestore.collection('posts').doc(postId);

      // Create a new comment
      Map<String, dynamic> newComment = {
        'commentId': uid,
        'content': content,
        'postedBy': userId,
        'username': username,
        'profilePicture': profilePic
      };

      // Update the post document by adding the new comment to the 'comments' array field
      await postRef.update({
        'comments': FieldValue.arrayUnion([newComment])
      });

      return true;
    } catch (e) {
      print('Error adding comment: $e');
      return false;
    }
  }

  Future<bool> deleteComment(String postId, String commentId) async {
    try {
      // Get the reference to the specific post document
      DocumentReference postRef =
          _firebaseFirestore.collection('posts').doc(postId);

      // Get the current post data
      DocumentSnapshot postSnapshot = await postRef.get();
      Map<String, dynamic> postData =
          postSnapshot.data() as Map<String, dynamic>;

      // Remove the comment with the specified commentId
      List comments = List.from(postData['comments']);
      comments.removeWhere((comment) => comment['commentId'] == commentId);

      // Update the post document with the updated comments array
      await postRef.update({
        'comments': comments,
      });

      return true;
    } catch (e) {
      print('Error deleting comment: $e');
      return false;
    }
  }
}

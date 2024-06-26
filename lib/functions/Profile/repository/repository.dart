// repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

bool isLoading = false;
Map<String, dynamic> userDetails = {};
int followers = 0;
int following = 0;
bool isFollowing = false;

Future<void> loadUserData(String uid, Function setState, bool mounted) async {
  setState(() {
    isLoading = true;
  });
  try {
    var snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (snap.data() != null) {
      userDetails = snap.data()!;
      followers = snap.data()!['followers']?.length ?? 0;
      following = snap.data()!['following']?.length ?? 0;

      isFollowing = snap.data()!['followers'] == null
          ? false
          : snap.data()!['followers'].contains(FirebaseAuth.instance.currentUser!.uid);
    }
  } catch (e) {
    print('Error in loading user data: $e');
  } finally {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

Future<void> updateFollowStatus(String uid, bool isFollowing) async {
  // Update followers list for the user being followed
  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .update({
    'followers': isFollowing
        ? FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
        : FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
  });

  // Update following list for the current user
  await FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .update({
    'following': isFollowing
        ? FieldValue.arrayUnion([uid])
        : FieldValue.arrayRemove([uid]),
  });
}

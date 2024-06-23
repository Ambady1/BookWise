import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseCall {
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
}

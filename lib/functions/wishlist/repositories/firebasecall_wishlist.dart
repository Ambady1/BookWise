import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<bool> addToWishlist(String id, String title) async {
  try {
    // Get the current user
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print("No user logged in");
      return false; // Return false if no user is logged in
    }

    // Reference to the user's document in the "users" collection
    DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

    // Data to be added to the wishlist
    Map<String, String> wishlistItem = {
      'id': id,
      'title': title,
    };

    // Run a transaction to ensure atomic operations
    bool success = await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userDoc);

      // Cast snapshot.data() to Map<String, dynamic>
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      // Retrieve the wishlist or initialize it if it doesn't exist
      List<dynamic> wishlist = data?['wishlist'] ?? [];

      // Check if the item already exists in the wishlist
      bool itemExists = wishlist.any((item) => item['id'] == id);

      if (itemExists) {
        print("Book already in wishlist");
        return true; // Return true indicating success
      } else {
        // Append the new item to the wishlist
        wishlist.add(wishlistItem);

        // Update the user document with the new wishlist
        transaction.update(userDoc, {'wishlist': wishlist});
        print("Book added to wishlist");
        return true; // Return true indicating success
      }
    });

    return success; // Return the transaction result
  } catch (e) {
    print("Failed to add to wishlist: $e");
    return false; // Return false indicating failure
  }
}

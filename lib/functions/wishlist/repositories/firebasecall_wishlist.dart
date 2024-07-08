import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String> addToWishlist(String id, String title, String imageURL) async {
  try {
    // Get the current user
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print("No user logged in");
      return "No user logged in"; // Return message if no user is logged in
    }

    // Reference to the user's document in the "users" collection
    DocumentReference userDoc =
        FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

    // Data to be added to the wishlist
    Map<String, String> wishlistItem = {
      'id': id,
      'title': title,
      'imageUrl': imageURL,
    };

    // Run a transaction to ensure atomic operations
    String result =
        await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userDoc);

      // Cast snapshot.data() to Map<String, dynamic>
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      // Retrieve the wishlist or initialize it if it doesn't exist
      List<dynamic> wishlist = data?['wishlist'] ?? [];

      // Check if the item already exists in the wishlist
      bool itemExists = wishlist.any((item) => item['id'] == id);

      if (itemExists) {
        // Remove the item from the wishlist
        wishlist.removeWhere((item) => item['id'] == id);

        // Update the user document with the new wishlist
        transaction.update(userDoc, {'wishlist': wishlist});
        print("Book removed from wishlist");
        return "removed"; // Return message indicating the book was removed
      } else {
        // Append the new item to the wishlist
        wishlist.add(wishlistItem);

        // Update the user document with the new wishlist
        transaction.update(userDoc, {'wishlist': wishlist});
        print("Book added to wishlist");
        return "added"; // Return message indicating the book was added
      }
    });

    return result; // Return the transaction result
  } catch (e) {
    print("Failed to add/remove to/from wishlist: $e");
    return "Failed"; // Return message indicating failure
  }
}



Stream<List<Map<String, dynamic>>> streamWishlist() async* {
  try {
    // Get the current user
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // print("No user logged in");
      yield []; // Yield an empty list if no user is logged in
      return;
    }

    // Reference to the user's document in the "users" collection
    DocumentReference userDoc =
        FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

    // Listen to changes on the user document
    Stream<DocumentSnapshot> snapshotStream = userDoc.snapshots();

    await for (DocumentSnapshot snapshot in snapshotStream) {
      // Check if the document exists and has a wishlist
      if (!snapshot.exists) {
        // print("No wishlist found");
        yield []; // Yield an empty list if no wishlist is found
        continue;
      }

      // Retrieve the data and cast it to Map<String, dynamic>
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      if (data == null || !data.containsKey('wishlist')) {
        //print("No wishlist found");
        yield []; // Yield an empty list if no wishlist is found
        continue;
      }

      // Retrieve the wishlist from the document data
      List<dynamic> wishlistData = data['wishlist'];
      List<Map<String, dynamic>> wishlist =
          List<Map<String, dynamic>>.from(wishlistData);

      yield wishlist; // Yield the current wishlist
      //print( wishlist);
    }
  } catch (e) {
    // print("Failed to stream wishlist: $e");
    yield []; // Yield an empty list on error
  }
}

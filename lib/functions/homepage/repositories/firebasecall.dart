import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<List<String>> updateNotifierWithBooks() async {
  List<String> zoneBooks = [];


  // Get the current user's ID
  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    print("No user is signed in.");
    throw Error(); // Handle the case where the user is not signed in
  }

  String userId = currentUser.uid;
  print("Current user ID: $userId");

  // Fetch user data to get the city name
  DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

  if (!userSnapshot.exists) {
    print("User document does not exist.");
    throw Error();
  }

  String userCity = userSnapshot['city'];
  print("User city: $userCity");

  // Fetch libraries with the same city name
  QuerySnapshot librariesSnapshot = await FirebaseFirestore.instance
      .collection('libraries')
      .where('cityname', isEqualTo: userCity)
      .get();

  if (librariesSnapshot.docs.isEmpty) {
    print("No libraries found in the user's city.");

    throw Error();
  }

  print("Number of libraries found: ${librariesSnapshot.docs.length}");

  // For each library, fetch the books
  for (var libraryDoc in librariesSnapshot.docs) {
    String libraryName = libraryDoc['username'];
    print("Fetching books from library: $libraryName");
    
    QuerySnapshot booksSnapshot =
        await FirebaseFirestore.instance.collection(libraryName).get();

    for (var bookDoc in booksSnapshot.docs) {
      zoneBooks.add(bookDoc['title'].toString());
      print("Added book: ${bookDoc['title']}");
    }
  }

  print("Total books found: ${zoneBooks.length}");
  return zoneBooks;
}

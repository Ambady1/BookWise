import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<String>> updateNotifierWithBooks() async {
  List<String> zoneBooks = [];

  // Fetch book data from Firestore
  QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('library 1').get();
  if (querySnapshot.docs.isEmpty) {
    throw Error();
  }

  for (var doc in querySnapshot.docs) {
    zoneBooks.add(doc['Title'].toString());
  }
  return zoneBooks;
}

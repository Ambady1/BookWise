import 'package:bookwise/functions/booking/libraryviewwidget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> fetchLibrariesWithBook(
    String bookName) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('books')
        .where('title', isEqualTo: bookName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot bookDoc = querySnapshot.docs.first;
      Map<String, dynamic> bookData = bookDoc.data() as Map<String, dynamic>;

      // Check if 'libraries' field exists and is a List
      if (bookData.containsKey('libraries') &&
          bookData['libraries'] is List<dynamic>) {
        List<dynamic> libraries = bookData['libraries'];
        List<Map<String, dynamic>> librariesList = [];

        libraries.forEach((libraryData) {
          // Validate each libraryData object before adding to the list
          if (libraryData is Map<String, dynamic> &&
              libraryData.containsKey('libraryName') &&
              libraryData.containsKey('copyCount')) {
            librariesList.add({
              'libraryName': libraryData['libraryName'],
              'copyCount': libraryData['copyCount'],
              'bookingStatus': "not_confirmed",
            });
          } else {
            print(
                'Invalid library data found in Firestore for book: $bookName');
          }
        });

        return librariesList;
      } else {
        // print('No or invalid libraries found in Firestore for book: $bookName');
        return [];
      }
    } else {
      // print('No book found with the name: $bookName');
      return [];
    }
  } catch (e) {
    //  print('Error fetching libraries: $e');
    return [];
  }
}

void showLibraries(BuildContext context, String bookName) async {
  try {
    List<Map<String, dynamic>> libraries =
        await fetchLibrariesWithBook(bookName);

    // Debugging print statements
    // print('Fetched libraries for bookId $bookName: $libraries');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LibraryListPage(libraries: libraries, bookName: bookName),
      ),
    );
  } catch (e) {
    // print('Error fetching libraries: $e');
    // Handle error appropriately
  }
}

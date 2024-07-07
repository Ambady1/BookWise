import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LibraryListPage extends StatefulWidget {
  final List<Map<String, dynamic>> libraries;
  final String bookName;
  LibraryListPage({required this.libraries, required this.bookName});

  @override
  _LibraryListPageState createState() => _LibraryListPageState();
}

class _LibraryListPageState extends State<LibraryListPage> {
  late List<Map<String, dynamic>> libraries;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    libraries = widget.libraries.map((library) => {
      ...library,
      'isBooked': false,
    }).toList();
    _getCurrentUser();
    _fetchBookingStatus();
  }

  void _getCurrentUser() {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Handle user not logged in
      print('No user logged in');
    }
  }

 void _fetchBookingStatus() async {
  if (currentUser == null) return;

  final userRef = FirebaseFirestore.instance.collection('users').doc(currentUser?.uid);
  final userSnapshot = await userRef.get();

  if (userSnapshot.exists) {
    final bookings = List<Map<String, dynamic>>.from(userSnapshot.data()?['bookings'] ?? []);

    setState(() {
      libraries = widget.libraries.map((library) {
        final isBooked = bookings.any((booking) => booking['libraryName'] == library['libraryName'] && booking['bookName'] == widget.bookName);
        return {
          ...library,
          'isBooked': isBooked,
        };
      }).toList();
    });
  }
}



  void _bookLibrary(int index) async {
    final library = libraries[index];
    setState(() {
      libraries[index]['isBooked'] = true;
      libraries[index]['copyCount'] -= 1;
    });

    await _updateLibraryCopies(widget.bookName, library['libraryName']);
    await _storeBookingDetails(index);
  }

  Future<void> _updateLibraryCopies(String bookName, String libraryName) async {
    print('Updating library copies for book: $bookName, library: $libraryName');

    final bookQuery = FirebaseFirestore.instance
        .collection('books')
        .where('title', isEqualTo: bookName)
        .limit(1);

    final querySnapshot = await bookQuery.get();

    if (querySnapshot.docs.isEmpty) {
      print('No document found for book title: $bookName');
      return;
    }

    final bookRef = querySnapshot.docs.first.reference;

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(bookRef);

      if (!snapshot.exists) {
        print('Document does not exist!');
        return;
      }

      final libraries = List<Map<String, dynamic>>.from(snapshot.data()?['libraries'] ?? []);
      final libraryIndex = libraries.indexWhere((lib) => lib['libraryName'] == libraryName);

      if (libraryIndex == -1) {
        print('Library not found in the list!');
        return;
      }

      print('Current copy count: ${libraries[libraryIndex]['copyCount']}');

      libraries[libraryIndex]['copyCount'] = libraries[libraryIndex]['copyCount'] - 1;

      if (libraries[libraryIndex]['copyCount'] < 0) {
        print('Copy count cannot be negative!');
        return;
      }

      print('New copy count: ${libraries[libraryIndex]['copyCount']}');

      transaction.update(bookRef, {'libraries': libraries});
      print('Transaction update completed');
    }).catchError((error) {
      print('Transaction failed: $error');
    });
  }

 Future<void> _storeBookingDetails(int index) async {
  final library = libraries[index];
  final userRef = FirebaseFirestore.instance.collection('users').doc(currentUser?.uid);

  await FirebaseFirestore.instance.runTransaction((transaction) async {
    final snapshot = await transaction.get(userRef);

    if (!snapshot.exists) {
      transaction.set(userRef, {
        'bookings': [{
          'libraryName': library['libraryName'],
          'bookName': widget.bookName,
          'bookedAt': Timestamp.now(),
        }]
      });
    } else {
      final currentBookings = List<Map<String, dynamic>>.from(snapshot.data()?['bookings'] ?? []);
      currentBookings.add({
        'libraryName': library['libraryName'],
        'bookName': widget.bookName,
        'status':'not confirmed',
        'bookedAt': Timestamp.now(),
      });

      transaction.update(userRef, {'bookings': currentBookings});
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Libraries'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: libraries.length,
          itemBuilder: (context, index) {
            final library = libraries[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                title: Text(
                  library['libraryName'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Text(
                  'Available copies: ${library['copyCount']}',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: library['isBooked']
                    ? ElevatedButton.icon(
                        onPressed: null,
                        icon: Icon(Icons.check),
                        label: Text('Booked'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          textStyle: TextStyle(fontSize: 16),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: library['copyCount'] > 0
                            ? () => _bookLibrary(index)
                            : null,
                        icon: Icon(Icons.book),
                        label: Text('Book'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: library['copyCount'] > 0
                              ? Colors.blue
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          textStyle: TextStyle(fontSize: 16),
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}

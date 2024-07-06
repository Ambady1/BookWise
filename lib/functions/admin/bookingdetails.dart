import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Bookings extends StatefulWidget {
  const Bookings({super.key});

  @override
  State<Bookings> createState() => _BookingsState();
}

Future<List<Map<String, dynamic>>> fetchBookingDetails() async {
  var currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    print('No user is currently signed in.');
    return [];
  }
  var uid = currentUser.uid;

  var libraryRef = FirebaseFirestore.instance.collection('libraries').doc(uid);
  var librarySnapshot = await libraryRef.get();
  if (!librarySnapshot.exists) {
    print('No library document found for the current user.');
    return [];
  }
  var currentLibraryName = librarySnapshot.data()?['username'];
  if (currentLibraryName == null) {
    print('Library name not found for the current user.');
    return [];
  }

  var usersRef = FirebaseFirestore.instance.collection('users');
  var usersSnapshot = await usersRef.get();
  var matchingUsers = usersSnapshot.docs
      .where((doc) {
        var bookings = doc.data()['bookings'] as List<dynamic>? ?? [];
        return bookings
            .any((booking) => booking['libraryName'] == currentLibraryName);
      })
      .map((doc) {
        var userName = doc.data()['username'] ?? 'Unknown';
        var bookings = (doc.data()['bookings'] as List<dynamic>)
            .where((booking) => booking['libraryName'] == currentLibraryName)
            .map((booking) {
          var bookingTime = booking['bookedAt'] as Timestamp;
          var formattedTime =
              DateFormat('yyyy-MM-dd – kk:mm').format(bookingTime.toDate());
          return {
            'userName': userName,
            'bookingTime': formattedTime,
            'bookingStatus': booking['status'] ?? 'not_confirmed',
            'userId': doc.id,
            'libraryName': currentLibraryName,
            'bookId': booking['bookId'], // Make sure you have this field
          };
        }).toList();
        return bookings;
      })
      .expand((x) => x)
      .toList();

  return matchingUsers;
}

Future<void> handleReturn(String userId, Map<String, dynamic> booking) async {
  try {
    // Extract libraryName from the booking
    String libraryName = booking['libraryName'];

    // Remove the booking from the user's bookings
    var userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    var userSnapshot = await userRef.get();
    if (!userSnapshot.exists) {
      print('User document does not exist.');
      return;
    }
    var bookings = (userSnapshot.data()?['bookings'] as List<dynamic>?) ?? [];
    bookings.removeWhere((b) =>
        b['libraryName'] == booking['libraryName'] &&
        b['bookedAt'] == booking['bookedAt']);
    await userRef.update({'bookings': bookings});

    // Increment the copyCount in the book's library data
    final bookQuery = FirebaseFirestore.instance
        .collection('books')
        .where('title', isEqualTo: booking['bookName'])
        .limit(1);
    final querySnapshot = await bookQuery.get();

    if (querySnapshot.docs.isEmpty) {
      print('No document found for book title: ${booking['bookName']}');
      return;
    }

    final bookRef = querySnapshot.docs.first.reference;

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(bookRef);

      if (!snapshot.exists) {
        print('Document does not exist!');
        return;
      }

      final libraries =
          List<Map<String, dynamic>>.from(snapshot.data()?['libraries'] ?? []);
      final libraryIndex =
          libraries.indexWhere((lib) => lib['libraryName'] == libraryName);

      if (libraryIndex == -1) {
        print('Library not found in the list!');
        return;
      }

      print('Current copy count: ${libraries[libraryIndex]['copyCount']}');

      libraries[libraryIndex]['copyCount'] =
          libraries[libraryIndex]['copyCount'] + 1;

      print('New copy count: ${libraries[libraryIndex]['copyCount']}');

      transaction.update(bookRef, {'libraries': libraries});
      print('Transaction update completed');
    }).catchError((error) {
      print('Transaction failed: $error');
    });

    // Add the booking data along with the returned time to the library's bookingHistory
    var libraryRef = FirebaseFirestore.instance
        .collection('libraries')
        .where('username', isEqualTo: libraryName)
        .limit(1);
    var librarySnapshot = await libraryRef.get();
    if (librarySnapshot.docs.isEmpty) {
      print('No document found for library name: $libraryName');
      return;
    }

    var libraryDocRef = librarySnapshot.docs.first.reference;
    var returnedTime = DateTime.now();
    var bookingHistory = {
      ...booking,
      'returnedAt': returnedTime,
    };
    await libraryDocRef.update({
      'bookingHistory': FieldValue.arrayUnion([bookingHistory])
    });

    print('Return handled successfully.');
  } catch (e) {
    print('Error handling return: $e');
  }
}

class _BookingsState extends State<Bookings> {
  late Future<List<Map<String, dynamic>>> futureBookingDetails;

  @override
  void initState() {
    super.initState();
    futureBookingDetails = fetchBookingDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 5,
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(45),
                    bottomRight: Radius.circular(45),
                  ),
                ),
                child: SafeArea(
                  minimum: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Text(
                        'Bookings',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      const Spacer(
                        flex: 5,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: futureBookingDetails,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No bookings found.'));
                    } else {
                      var bookingDetails = snapshot.data!;
                      return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: bookingDetails.length,
                        itemBuilder: (context, index) {
                          var booking = bookingDetails[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(
                                        '${booking['userName']}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 4),
                                          Text(
                                            'Booking Time: ${booking['bookingTime']}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Booking Status: ${booking['bookingStatus']}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (booking['bookingStatus'] !=
                                      'confirmed') ...[
                                    ElevatedButton(
                                      onPressed: () async {
                                        await updateBookingStatus(
                                            booking['userId'],
                                            booking['libraryName'],
                                            'confirmed');
                                        setState(() {
                                          booking['bookingStatus'] =
                                              'confirmed';
                                        });
                                      },
                                      child: Text('Confirm'),
                                    ),
                                  ] else ...[
                                    ElevatedButton(
                                      onPressed: null,
                                      child: Text('Confirmed'),
                                    ),
                                  ],
                                  SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await handleReturn(
                                          booking['userId'], booking);
                                      setState(() {
                                        bookingDetails.removeAt(index);
                                      });
                                    },
                                    child: Text('Return'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> updateBookingStatus(
    String userId, String libraryName, String newStatus) async {
  var userRef = FirebaseFirestore.instance.collection('users').doc(userId);
  var userSnapshot = await userRef.get();
  if (!userSnapshot.exists) {
    print('User document does not exist.');
    return;
  }
  var bookings = (userSnapshot.data()?['bookings'] as List<dynamic>?) ?? [];
  for (var booking in bookings) {
    if (booking['libraryName'] == libraryName) {
      booking['status'] = newStatus;
    }
  }
  await userRef.update({'bookings': bookings});
}

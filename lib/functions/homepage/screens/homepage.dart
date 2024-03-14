import 'package:bookwise/functions/Profile/screens/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:csv/csv.dart';
//import 'package:flutter/services.dart' show rootBundle;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    // Handle navigation to different screens based on index
    setState(() {
      _currentIndex = index;
    });
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyProfile()),
      );
    }
  }

  // void exportData() async {
  //   final CollectionReference library =
  //       FirebaseFirestore.instance.collection("library1");
  //   final myData = await rootBundle.loadString('assets/booksdata/books.csv');
  //   List<List<dynamic>> csvTable = CsvToListConverter().convert(myData);
  //   List<List<dynamic>> data = [];
  //   data = csvTable;
  //   for (var i = 0; i < data.length; i++) {
  //     var record = {
  //       "Title": data[i][0].toString(), // Cast to string explicitly
  //       "Author": data[i][1].toString(), // Cast to string explicitly
  //       "Genre": data[i][2].toString() // Cast to string explicitly
  //     };
  //     library.add(record);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomePage'),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            // ElevatedButton(onPressed:() => exportData(), child: Text('store csv')),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('library1').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                final books = snapshot.data!.docs;
                List<String> bookTitles = [];
                for (var book in books) {
                  bookTitles.add(
                      book['Title'].toString()); // Cast to string explicitly
                }
                return _buildBookRow(bookTitles);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        unselectedItemColor: const Color.fromARGB(255, 203, 125, 120),
        selectedItemColor: Color.fromARGB(255, 84, 10, 5),
        backgroundColor: Colors.black,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _onItemTapped(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_sharp),
              label: 'BookClub',
              backgroundColor: Colors.black),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: 'Bookshelf'),
          BottomNavigationBarItem(icon: Icon(Icons.person_2), label: 'Profile')
        ],
      ),
    );
  }

  Widget _buildBookRow(List<String> bookTitles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Books',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var bookTitle in bookTitles)
                FutureBuilder<dynamic>(
                  future: fetchBookData(bookTitle),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        width: 150,
                        height: 300,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      var imageUrl = snapshot.data!['coverUrl'];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 150,
                          height: 300,
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<dynamic> fetchBookData(String bookTitle) async {
    var url = 'http://openlibrary.org/search.json?title=$bookTitle';

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var docs = data['docs'];
      if (docs != null && docs.isNotEmpty) {
        var coverId = docs[0]['cover_i'];
        var coverUrl = 'https://covers.openlibrary.org/b/id/$coverId-L.jpg';
        return {'coverUrl': coverUrl};
      }
    }
    // Return a default cover URL if no data is found
    return {'coverUrl': 'https://via.placeholder.com/150'};
  }
}

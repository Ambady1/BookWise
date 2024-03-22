import 'package:bookwise/functions/Profile/screens/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Define bookTitles as a global variable
List<String> bookTitles = [];

void main() => runApp(const MaterialApp(home: HomePage()));

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.withOpacity(0.5),
        leading: SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: DataSearch());
            },
          ),
        ),
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search here',
            border: InputBorder.none,
          ),
          onTap: () {
            showSearch(context: context, delegate: DataSearch());
          },
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('library1').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                final books = snapshot.data!.docs;
                bookTitles.clear(); // Clear the list before adding new titles
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
        unselectedItemColor: Color.fromARGB(255, 203, 125, 120),
        selectedItemColor: Color.fromARGB(255, 84, 10, 5),
        backgroundColor: Colors.black,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (_currentIndex == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyProfile()),
              );
            }
          });
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
              color: Colors.black,
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
                      return const SizedBox(
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
                        child: Column(
                          children: [
                            SizedBox(
                              width: 150,
                              height: 300,
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              bookTitle,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
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

// SEARCH FEATURE
class DataSearch extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Filter the bookTitles list to find matches
    final List<String> matchingBooks = bookTitles.where((title) {
      return title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    // Display the search results
    return ListView.builder(
      itemCount: matchingBooks.length,
      itemBuilder: (context, index) {
        final String bookTitle = matchingBooks[index];
        return ListTile(
          title: Text(bookTitle),
          onTap: () {
            // You can implement what to do when a search result is tapped
            // For example, you can close the search and navigate to a detailed view of the selected book
            close(context, bookTitle);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Check if the query is empty or null
    if (query.isEmpty) {
      return Container(); // Return an empty container if query is empty
    }

    // Filter the bookTitles list to find suggestions based on the query
    final List<String> suggestions = bookTitles.where((title) {
      return title.toLowerCase().startsWith(query.toLowerCase());
    }).toList();

    // Display the suggestions
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final String suggestion = suggestions[index];
        return ListTile(
          title: Text(suggestion),
          onTap: () {
            // You can implement what to do when a suggestion is tapped
            // For example, you can update the search query with the selected suggestion
            query = suggestion;
          },
        );
      },
    );
  }
}

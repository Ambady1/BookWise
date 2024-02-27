import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        title: const Text('Firestore JSON Upload'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: ListView(
            children: [
              const Text(
                'Search for a book',
                style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.start,
              ),
              const SizedBox(
                height: 20.0,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 1; i <= 4; i++)
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('library1')
                            .doc('book$i')
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            var imageUrl = snapshot.data!['coverUrl'];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal:8.0,vertical:18.0),
                              child: Image.network(
                                imageUrl,
                                height: 300,
                                width: 150,
                                fit: BoxFit.contain,
                              ),
                            );
                          }
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              // Bottom navigation bar
            ],
          ),
        ),
      ),
      backgroundColor: Color.fromARGB(255, 2, 14, 39),
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
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookwise/functions/loginandsignup/screens/login.dart';

class MyProfile extends StatefulWidget {
  final String uid;
  const MyProfile({Key? key, required this.uid}) : super(key: key);

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  var userDetails = {};
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    } catch (e) {
      print('Error logging out: $e');
      // Handle error if needed
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didUpdateWidget(covariant MyProfile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uid != widget.uid) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      if (snap.data() != null) {
        userDetails = snap.data()!;
        followers = snap.data()!['followers'].length;
        following = snap.data()!['following'].length;

        // Update isFollowing state based on fetched followers list
       isFollowing = snap.data()!['followers'] == null
          ? false
          : snap.data()!['followers'].contains(FirebaseAuth.instance.currentUser!.uid);

      }
    } catch (e) {
      print('Error in loading user data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              title: const Text(
                'Profile',
                style: TextStyle(color: Colors.black87),
              ),
              leading: Builder(
                builder: (context) => PopupMenuButton(
                  icon: Icon(Icons.menu, color: Colors.black87),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: ListTile(
                        title: Text('Logout'),
                        leading: Icon(Icons.exit_to_app),
                        onTap: () {
                          _logout(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
              backgroundColor: Colors.white,
            ),
            body: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          // backgroundImage: AssetImage('49457.jpg'),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userDetails['username'],
                                style: TextStyle(
                                  color: Color.fromARGB(255, 1, 29, 46),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '@vaiz',
                                style: TextStyle(
                                  color: Colors.blueGrey[400],
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '$followers Followers',
                          style: TextStyle(
                            color: Color.fromARGB(255, 13, 134, 204),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 20),
                        Text(
                          '$following Following',
                          style: TextStyle(
                            color: Color.fromARGB(255, 13, 134, 204),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                     onPressed: () async {
  if (FirebaseAuth.instance.currentUser!.uid == widget.uid) {
    setState(() {
      following = followers; // If viewing own profile, set following count equal to followers count
    });
    return;
  }

  setState(() {
    isFollowing = !isFollowing; // Toggle follow/unfollow status
    followers += isFollowing ? 1 : -1; // Increment/decrement followers count based on follow/unfollow
  });

  // Update followers list for the user being followed
  await FirebaseFirestore.instance
    .collection('users')
    .doc(widget.uid)
    .update({
      'followers': isFollowing
          ? FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
          : FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
    });

  // Update following list for the current user
  await FirebaseFirestore.instance
    .collection('users')
    .doc(FirebaseAuth.instance.currentUser!.uid)
    .update({
      'following': isFollowing
          ? FieldValue.arrayUnion([widget.uid])
          : FieldValue.arrayRemove([widget.uid]),
    });
},

                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(30.0), // Adjust as needed
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        backgroundColor:
                            FirebaseAuth.instance.currentUser!.uid == widget.uid
                                ? Colors.grey // Disabled state color (optional)
                                : (isFollowing
                                    ? Colors.blueAccent
                                    : Color.fromARGB(255, 13, 134,
                                        204)), // Following/Unfollow colors
                        foregroundColor: Colors.white, // Text color
                        textStyle: TextStyle(
                            fontSize: 16.0), // Text style customization
                      ),
                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min, // Center content horizontally
                        children: [
                          FirebaseAuth.instance.currentUser!.uid == widget.uid
                              ? Icon(Icons.person_add,
                                  size: 18.0) // "Add friend" icon
                              : (isFollowing
                                  ? Icon(Icons.check, size: 18.0)
                                  : Icon(Icons.add, size: 18.0)),
                          SizedBox(width: 8.0), // Spacing between icon and text
                          Text(
                            FirebaseAuth.instance.currentUser!.uid == widget.uid
                                ? 'Add Friend' // "Add friend" text
                                : (isFollowing ? 'Following' : 'Follow'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

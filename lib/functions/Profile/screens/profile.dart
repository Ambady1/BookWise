import 'package:bookwise/functions/Profile/widgets/profile_widget.dart';
import 'package:bookwise/functions/Profile/widgets/app_drawer.dart';
import 'package:bookwise/functions/Profile/repository/repository.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyProfile extends StatefulWidget {
  final String uid;
  const MyProfile({Key? key, required this.uid}) : super(key: key);

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  @override
  void initState() {
    super.initState();
    loadUserData(widget.uid, setState, mounted);
  }

  @override
  void didUpdateWidget(covariant MyProfile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uid != widget.uid) {
      loadUserData(widget.uid, setState, mounted);
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
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black87),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
              backgroundColor: Colors.white,
            ),
            drawer: AppDrawer(userDetails: userDetails), // Use the AppDrawer
            body: SingleChildScrollView(
              child: ProfileWidget(
                userDetails: userDetails,
                followers: followers,
                following: following,
                isFollowing: isFollowing,
                onFollowButtonPressed: () {
                  if (FirebaseAuth.instance.currentUser!.uid != widget.uid) {
                    updateFollowStatus(widget.uid, !isFollowing).then((_) {
                      setState(() {
                        isFollowing = !isFollowing;
                        followers = isFollowing ? followers + 1 : followers - 1;
                      });
                    });
                  }
                },
              ),
            ),
          );
  }
}

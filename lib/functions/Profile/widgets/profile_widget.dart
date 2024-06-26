import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileWidget extends StatelessWidget {
  final Map<String, dynamic> userDetails;
  final int followers;
  final int following;
  final bool isFollowing;
  final VoidCallback onFollowButtonPressed;

  const ProfileWidget({
    Key? key,
    required this.userDetails,
    required this.followers,
    required this.following,
    required this.isFollowing,
    required this.onFollowButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
                      '@${userDetails['nickname']}',
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
            onPressed: onFollowButtonPressed,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              backgroundColor: FirebaseAuth.instance.currentUser!.uid == userDetails['uid']
                  ? Colors.grey
                  : (isFollowing ? Colors.blueAccent : Color.fromARGB(255, 13, 134, 204)),
              foregroundColor: Colors.white,
              textStyle: TextStyle(fontSize: 16.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FirebaseAuth.instance.currentUser!.uid == userDetails['uid']
                    ? Icon(Icons.person_add, size: 18.0)
                    : (isFollowing ? Icon(Icons.check, size: 18.0) : Icon(Icons.add, size: 18.0)),
                SizedBox(width: 8.0),
                Text(
                  FirebaseAuth.instance.currentUser!.uid == userDetails['uid']
                      ? 'Add Friend'
                      : (isFollowing ? 'Following' : 'Follow'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:bookwise/functions/Profile/screens/UserPostFeedScreen.dart';
import 'package:bookwise/functions/Profile/screens/chatpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userDetails['uid'])
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var updatedUserDetails =
              snapshot.data!.data() as Map<String, dynamic>;
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          NetworkImage(userDetails['profilePicture']),
                      radius: 40,
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userDetails['username'],
                            style: const TextStyle(
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                     children: [const SizedBox(height: 20),
                      ..._buildDescription(updatedUserDetails['description'] ?? '')],
                  
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '$followers Followers',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 13, 134, 204),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      '$following Following',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 13, 134, 204),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: onFollowButtonPressed,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        backgroundColor: FirebaseAuth.instance.currentUser!.uid ==
                                userDetails['uid']
                            ? Colors.grey
                            : (isFollowing
                                ? Colors.blueAccent
                                : const Color.fromARGB(255, 13, 134, 204)),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 16.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FirebaseAuth.instance.currentUser!.uid ==
                                  userDetails['uid']
                              ? const Icon(Icons.person_add, size: 18.0)
                              : (isFollowing
                                  ? const Icon(Icons.check, size: 18.0)
                                  : const Icon(Icons.add, size: 18.0)),
                          const SizedBox(width: 8.0),
                          Text(
                            FirebaseAuth.instance.currentUser!.uid ==
                                    userDetails['uid']
                                ? 'Add Friend'
                                : (isFollowing ? 'Following' : 'Follow'),
                          ),
                        ],
                        
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          
                        ),
                            padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                      ),
                  

                      onPressed: () {
                        Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          chatUserId: userDetails['uid'],
          chatUserName: userDetails['username'],
        chatUserProfilePic: userDetails['profilePicture'],
        ),
      ),
    );
                       }, 
                    child: const Text('Message',
                    style: TextStyle(
                      color: Colors.white,
                    ),),)
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Posts',
                  style: TextStyle(
                    color: Color.fromARGB(255, 13, 134, 204),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .where('userId', isEqualTo: userDetails['uid'])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var posts = snapshot.data!.docs;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                      ),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        var post = posts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserPostFeedScreen(uid: userDetails['uid']),
                              ),
                            );
                          },
                          child: Image.network(post['postImage'],
                              fit: BoxFit.cover),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        });
  }

  List<Widget> _buildDescription(String description) {
    return description.split('\n').map((line) {
      return Text(
        line,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),
      );
    }).toList();
  }
}

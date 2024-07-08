import 'package:bookwise/functions/Profile/screens/chatpage.dart';
import 'package:bookwise/common/constants/colors_and_fonts.dart'; // Ensure this import is correct
import 'package:bookwise/functions/community/screens/searchscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookwise/functions/community/widgets/postwidget.dart'; // Add this import

class ProfileWidget extends StatefulWidget {
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
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  bool _showPosts = false;

  void _toggleShowPosts() {
    setState(() {
      _showPosts = !_showPosts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userDetails['uid'])
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var updatedUserDetails = snapshot.data!.data() as Map<String, dynamic>;
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          NetworkImage(updatedUserDetails['profilePicture']),
                      radius: 40,
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            updatedUserDetails['username'],
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '@${updatedUserDetails['nickname']}',
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
                  children: [
                    const SizedBox(height: 20),
                    ..._buildDescription(updatedUserDetails['description'] ?? '')
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.followers} Followers',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 13, 134, 204),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      '${widget.following} Following',
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
                      onPressed: () {
                        showSearch(
                          context: context,
                          delegate: SearchScreen(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        backgroundColor: FirebaseAuth.instance.currentUser!.uid ==
                                widget.userDetails['uid']
                            ? Colors.blueAccent
                            : (widget.isFollowing
                                ? Colors.blueAccent
                                : const Color.fromARGB(255, 13, 134, 204)),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 16.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FirebaseAuth.instance.currentUser!.uid ==
                                  widget.userDetails['uid']
                              ? const Icon(Icons.person_add, size: 18.0)
                              : (widget.isFollowing
                                  ? const Icon(Icons.check, size: 18.0)
                                  : const Icon(Icons.add, size: 18.0)),
                          const SizedBox(width: 8.0),
                          Text(
                            FirebaseAuth.instance.currentUser!.uid ==
                                    widget.userDetails['uid']
                                ? 'Add Friend'
                                : (widget.isFollowing ? 'Following' : 'Follow'),
                          ),
                        ],
                      ),
                    ),
                    if (FirebaseAuth.instance.currentUser!.uid !=
                        widget.userDetails['uid'])
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
                                chatUserId: widget.userDetails['uid'],
                                chatUserName: widget.userDetails['username'],
                                chatUserProfilePic:
                                    widget.userDetails['profilePicture'],
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Message',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // background color
                    foregroundColor: Colors.white, // text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _toggleShowPosts,
                  child: Text(
                    _showPosts ? 'Hide Posts' : 'Show Posts',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                _showPosts
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('posts')
                                .where('userId', isEqualTo: widget.userDetails['uid'])
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              var posts = snapshot.data!.docs;
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: posts.length,
                                itemBuilder: (context, index) {
                                  var post = posts[index];
                                  return PostWidget(post.data());
                                },
                              );
                            },
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildDescription(String description) {
    return description.split('\n').map((line) {
      return Text(
        line,
        style: TextStyle(
          color: AppColors.textColor,
          fontSize: 14,
        ),
      );
    }).toList();
  }
}

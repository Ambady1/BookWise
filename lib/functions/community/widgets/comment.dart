import 'package:bookwise/common/constants/colors_and_fonts.dart';
import 'package:bookwise/functions/community/core/image_cached.dart';
import 'package:bookwise/functions/community/models/user_model.dart';
import 'package:bookwise/functions/community/repositories/firestor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommentWidget extends StatefulWidget {
  final String postId;
  CommentWidget(this.postId, {Key? key}) : super(key: key);

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  final comment = TextEditingController();
  bool isloading = false;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String defaultProfile =
      "https://img.freepik.com/free-vector/funny-error-404-background-design_1167-219.jpg?w=740&t=st=1658904599~exp=1658905199~hmac=131d690585e96267bbc45ca0978a85a2f256c7354ce0f18461cd030c5968011c";

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(25.r),
        topRight: Radius.circular(25.r),
      ),
      child: Container(
        color: Colors.black,
        height: 200.h,
        child: Stack(
          children: [
            Positioned(
              top: 8.h,
              left: 140.w,
              child: Container(
                width: 100.w,
                height: 3.h,
                color: AppColors.white,
              ),
            ),
            StreamBuilder(
              stream:
                  firestore.collection('posts').doc(widget.postId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var docData = snapshot.data!.data() as Map<String, dynamic>;
                var comments = docData['comments'];
                if (comments == null || comments.isEmpty) {
                  return Center(
                    child: Text(
                      'Oopsiee, nothing here',
                      style: TextStyle(color: AppColors.textColor),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    var commentData = comments[index];
                    return GestureDetector(
                      onLongPress: () {
                        _showDeleteDialog(
                            context, commentData, commentData['commentId']);
                      },
                      child: commentItem(commentData),
                    );
                  },
                );
              },
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                height: 60.h,
                width: double.infinity,
                color: AppColors.blackbg,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 62.h,
                      width: 260.w,
                      child: TextField(
                        style: TextStyle(color: AppColors.textColor),
                        controller: comment,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Add an opinion...',
                          hintStyle: TextStyle(color: AppColors.textColor),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isloading = true;
                        });
                        if (comment.text.isNotEmpty) {
                          FireServices().commentPost(
                            widget.postId,
                            comment.text,
                          );
                        }
                        setState(() {
                          isloading = false;
                          comment.clear();
                        });
                      },
                      child: isloading
                          ? SizedBox(
                              width: 10.w,
                              height: 10.h,
                              child: const CircularProgressIndicator(),
                            )
                          : Icon(Icons.send, color: AppColors.white),
                    ),
                    // Add any additional widgets or buttons here if needed
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget commentItem(Map<String, dynamic> commentData) {
    return ListTile(
      leading: ClipOval(
        child: SizedBox(
          height: 35,
          width: 35,
          child: CachedImage(
            commentData['profilePicture'] ?? defaultProfile,
          ),
        ),
      ),
      title: Text(
        commentData['username'] ?? 'Unknown',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.textColor,
        ),
      ),
      subtitle: Text(
        commentData['content'] ?? 'No content',
        style: TextStyle(
          fontSize: 13,
          color: AppColors.textColor,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> commentData,
      String commentId) async {
    // Get the current user ID
    UserModel user = await FireServices().getUser();
    String userId = user.uid;

    // Check if the comment was posted by the current user
    if (commentData['postedBy'] == userId) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete Comment'),
            content: Text('Do you want to delete your comment?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  // Delete the comment
                  bool success = await FireServices()
                      .deleteComment(widget.postId, commentId);
                  if (success) {
                    // Show a success message or handle accordingly
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Comment deleted successfully'),
                    ));
                  } else {
                    // Show an error message or handle accordingly
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Failed to delete comment'),
                    ));
                  }
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Yes'),
              ),
            ],
          );
        },
      );
    }
  }
}

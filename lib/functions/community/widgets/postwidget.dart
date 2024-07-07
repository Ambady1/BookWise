import 'package:bookwise/common/constants/colors_and_fonts.dart';
import 'package:bookwise/functions/community/core/image_cached.dart';
import 'package:bookwise/functions/community/core/utils.dart';
import 'package:bookwise/functions/community/repositories/firestor.dart';
import 'package:bookwise/functions/community/widgets/comment.dart';
import 'package:bookwise/functions/community/widgets/like_animation.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class PostWidget extends StatefulWidget {
  final snapshot;
  final String defaultProfile =
      "https://img.freepik.com/free-vector/funny-error-404-background-design_1167-219.jpg?w=740&t=st=1658904599~exp=1658905199~hmac=131d690585e96267bbc45ca0978a85a2f256c7354ce0f18461cd030c5968011c";

  PostWidget(this.snapshot, {super.key});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isLiked = false;
  bool animate = false;
  String userId = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    checkPostLiked();
    userId = _auth.currentUser!.uid;
  }

  void checkPostLiked() async {
    final isLikedByUser =
        await FireServices().isPostLikedByuser(widget.snapshot['postId']);
    if (isLikedByUser) {
      setState(() {
        isLiked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          width: 375.w,
          color: AppColors.blackbg,
          child: Center(
              child: ListTile(
            leading: ClipOval(
              child: SizedBox(
                width: 35.w,
                height: 35.h,
                child: CachedImage(widget.snapshot['profilePicture']),
              ),
            ),
            title: Text(
              widget.snapshot['username'] ??
                  'Unknown', // Use 'Unknown' if 'username' is null
              style: TextStyle(fontSize: 15.sp, color: AppColors.textColor),
            ),
            subtitle: Text(
              widget.snapshot['nickname'] ?? 'jumboJet12#',
              style: TextStyle(fontSize: 11.sp, color: AppColors.textColor),
            ),
            trailing: FutureBuilder<bool>(
              future:
                  FireServices().isMyPost(userId: widget.snapshot['userId']),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  return PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete Post'),
                              content: const Text(
                                  'Are you sure that you are deleting this post? This action cannot be reversed.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    // Close the dialog
                                    Navigator.of(context).pop();

                                    // Perform the delete action
                                    bool success =
                                        await FireServices().deleteMyPost(
                                      widget.snapshot['postId'],
                                      widget.snapshot['postImage'],
                                    );

                                    if (success) {
                                      // Show a success message or perform other actions if needed
                                      showToast('Post deleted successfully');
                                    } else {
                                      // Show an error message or perform other actions if needed
                                      showToast('Error deleting post');
                                    }
                                  },
                                  child: Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Delete My Post'),
                        ),
                      ];
                    },
                    icon: Icon(Icons.more_horiz, color: AppColors.white),
                  );
                } else {
                  return SizedBox();
                }
              },
            ),
          )),
        ),
        Container(
          width: width,
          color: AppColors.blackbg,
          padding: EdgeInsets.all(10.0), // Adding padding for better spacing
          child: Text(
            widget.snapshot['title'] ??
                'No Title', // Provide a fallback if the title is null
            style: TextStyle(
                fontSize: 22.sp, // Standard size for titles
                fontWeight: FontWeight.bold,
                color: AppColors.textColor // Making the text bold
                ),
          ),
        ),
        if (widget.snapshot['postType'] == 'ImagePost')
          Container(
            width: width,
            height: 375.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: width,
                  height: 375.h,
                  child: CachedImage(widget.snapshot['postImage']),
                ),
              ],
            ),
          ),
        if (widget.snapshot['postType'] == 'TextPost')
          Container(
            width: width,
            constraints: BoxConstraints(
              minHeight: 100.0.h,
            ),
            color: AppColors.blackbg,
            padding: EdgeInsets.all(10.0),
            child: Text(
              widget.snapshot['description'] ?? 'NO DESCRIPTION AVAILABLE',
              style: TextStyle(fontSize: 18.sp, color: AppColors.textColor),
            ),
          ),
        if (widget.snapshot['postType'] == 'LinkPost')
          Container(
            width: width,
            constraints: BoxConstraints(
              minHeight: 100.0.h,
            ),
            color: AppColors.blackbg,
            padding: EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () {
                Uri? link = widget.snapshot['link'];
                if (link != null) {
                  launchUrl(link);
                }
              },
              child: Text(
                widget.snapshot['link'] ?? 'NO LINK AVAILABLE',
                style: TextStyle(
                    fontSize: 18.sp,
                    decoration: TextDecoration.underline,
                    color: Colors.blue),
              ),
            ),
          ),
        Container(
          width: width,
          color: AppColors.blackbg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 14.h),
              Row(
                children: [
                  SizedBox(width: 18.w),
                  BounceAnimation(
                    animate: widget.snapshot['likes'].contains(userId),
                    child: IconButton(
                      onPressed: () async {
                        bool liked = await FireServices()
                            .likePost(widget.snapshot['postId']);
                        setState(() {
                          isLiked = liked ? !isLiked : isLiked;
                        });
                      },
                      icon: Icon(
                        Icons.thumb_up,
                        size: 25.h,
                        color:
                            isLiked ? AppColors.reactionBlue : AppColors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 25.w),
                  GestureDetector(
                    onTap: () {
                      showBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: DraggableScrollableSheet(
                              maxChildSize: 0.6,
                              initialChildSize: 0.6,
                              minChildSize: 0.2,
                              builder: (context, scrollController) {
                                return CommentWidget(widget.snapshot['postId']);
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: Icon(
                      Icons.comment,
                      size: 25.h,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 18.w,
                      top: 4.h,
                      bottom: 8.h,
                    ),
                    child: Text(
                      '${widget.snapshot['likes'].length} likes',
                      style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 15.w,
                      top: 4.h,
                      bottom: 8.h,
                    ),
                    child: Text(
                      '${widget.snapshot['comments'].length} comments',
                      style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.w, top: 20.h, bottom: 8.h),
                child: Text(
                  formatDate(
                    widget.snapshot['createdAt']?.toDate() ??
                        DateTime
                            .now(), // Use current time if 'createdAt' is null
                    [yyyy, '-', mm, '-', dd],
                  ),
                  style: TextStyle(fontSize: 11.sp, color: AppColors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

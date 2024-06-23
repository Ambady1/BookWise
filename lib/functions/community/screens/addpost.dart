import 'package:bookwise/common/constants/colors_and_fonts.dart';
import 'package:bookwise/functions/community/screens/addpost_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddPostScreen extends ConsumerWidget {
  const AddPostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double cardHeight = 150;
    double cardWidth = double.infinity;
    double iconSize = 60;
    Color iconColor = Colors.white30;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 46, 42, 42),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: double
                          .infinity, // Ensure the container takes full width
                      height: height / 5,
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(45),
                          bottomRight: Radius.circular(45),
                        ),
                      ),
                      child: SafeArea(
                        minimum: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Spacer(),
                            Text("Add a Post",
                                style:
                                    Theme.of(context).textTheme.displayLarge),
                            const Spacer(
                              flex: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AddPostType(type: 'Image')));
                        },
                        child: Wrap(
                          children: [
                            SizedBox(
                              height: cardHeight,
                              width: cardWidth,
                              child: Card(
                                color: Colors.white.withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 16,
                                child: Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: iconSize,
                                    color: iconColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AddPostType(type: 'Text')));
                        },
                        child: Wrap(
                          children: [
                            SizedBox(
                              height: cardHeight,
                              width: cardWidth,
                              child: Card(
                                color: Colors.white.withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 16,
                                child: Center(
                                  child: Icon(
                                    Icons.font_download_outlined,
                                    size: iconSize,
                                    color: iconColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AddPostType(type: 'Link')));
                        },
                        child: Wrap(
                          children: [
                            SizedBox(
                              height: cardHeight,
                              width: cardWidth,
                              child: Card(
                                color: Colors.white.withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 16,
                                child: Center(
                                  child: Icon(
                                    Icons.link_outlined,
                                    size: iconSize,
                                    color: iconColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

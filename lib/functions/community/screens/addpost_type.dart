import 'dart:io';
import 'package:bookwise/functions/community/core/utils.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:bookwise/common/constants/colors_and_fonts.dart';
import 'package:flutter/material.dart';

class AddPostType extends StatefulWidget {
  final String type;
  const AddPostType({super.key, required this.type});

  @override
  State<AddPostType> createState() => _AddPostTypeState();
}

class _AddPostTypeState extends State<AddPostType> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();

  File? bannerFile;

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
  }

  void selectBannerImage() async {
    final res = await pickImage();

    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
        print("Banner file selected: ${bannerFile!.path}");
      });
    } else {
      print("No image selected.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTypeImage = widget.type == 'Image';
    final isTypeText = widget.type == 'Text';
    final isTypeLink = widget.type == 'Link';
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
                      width: double.infinity,
                      height: height / 5,
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(45),
                          bottomRight: Radius.circular(45),
                        ),
                      ),
                      child: SafeArea(
                        minimum: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Spacer(),
                            Text(
                              "Add ${widget.type}",
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                            const Spacer(
                              flex: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          fillColor: Colors.white.withOpacity(0.4),
                          filled: true,
                          hintText: "Enter Title Here",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(18),
                        ),
                        maxLength: 30,
                      ),
                      const SizedBox(height: 10),
                      if (isTypeImage)
                        GestureDetector(
                          onTap: selectBannerImage,
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(10),
                            dashPattern: const [10, 4],
                            strokeCap: StrokeCap.round,
                            color: Colors.white.withOpacity(0.4),
                            child: Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: bannerFile != null
                                  ? Image.file(
                                      bannerFile!,
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.camera_alt_outlined,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      if (isTypeText)
                        TextField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            fillColor: Colors.white.withOpacity(0.4),
                            filled: true,
                            hintText: "Enter Description Here",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(18),
                          ),
                          maxLines: 5,
                        ),
                      if (isTypeLink)
                        TextField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            fillColor: Colors.white.withOpacity(0.4),
                            filled: true,
                            hintText: "Enter Link Here",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(18),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

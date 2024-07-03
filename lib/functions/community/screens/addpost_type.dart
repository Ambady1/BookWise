import 'dart:io';
import 'package:bookwise/common/constants/colors_and_fonts.dart';
import 'package:bookwise/functions/community/core/utils.dart';
import 'package:bookwise/functions/community/repositories/firestor.dart';
import 'package:bookwise/functions/community/repositories/storage.dart';
import 'package:dotted_border/dotted_border.dart';
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
  bool isloading = false;
  File? bannerFile;

  bool get isFormValid {
    if (widget.type == 'Image') {
      return titleController.text.isNotEmpty && bannerFile != null;
    } else if (widget.type == 'Text') {
      return titleController.text.isNotEmpty &&
          descriptionController.text.isNotEmpty;
    } else if (widget.type == 'Link') {
      return titleController.text.isNotEmpty && linkController.text.isNotEmpty;
    }
    return false;
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
  }

  void selectBannerImage() async {
    // Simulated function for picking image
    final res = await pickImage();

    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
        showSnackBar(context, 'Image Selected');
      });
    } else {
      showSnackBar(context, 'Error Importing Image!');
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
                        minimum: const EdgeInsets.all(16),
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
                if (!isloading)
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
                          onChanged: (value) {
                            setState(() {});
                          },
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
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        if (isTypeLink)
                          TextField(
                            controller:
                                linkController, // Use linkController here
                            decoration: InputDecoration(
                              fillColor: Colors.white.withOpacity(0.4),
                              filled: true,
                              hintText: "Enter Link Here",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(18),
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        const SizedBox(height: 20),
                        if (isFormValid)
                          ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                isloading = true;
                              });
                              if (isTypeImage) {
                                try {
                                  List<String> result = await StorageMethod()
                                      .uploadImagetoStorage(
                                          'posts', bannerFile!);
                                  await FireServices().createPost(
                                      postType: 'ImagePost',
                                      postImageId: result[0],
                                      postImage: result[1],
                                      title: titleController.text);
                                } catch (e) {
                                  showSnackBar(
                                      context, "Error uploading image");
                                }
                              } else if (isTypeText) {
                                try {
                                  await FireServices().createPost(
                                      postType: 'TextPost',
                                      title: titleController.text,
                                      description: descriptionController.text);
                                } catch (e) {
                                  showSnackBar(context, "Error uploading post");
                                }
                              } else if (isTypeLink) {
                                try {
                                  await FireServices().createPost(
                                      postType: 'LinkPost',
                                      title: titleController.text,
                                      link: linkController.text);
                                } catch (e) {
                                  showSnackBar(context, "Error uploading post");
                                }
                              }
                              setState(() {
                                isloading = false;
                              });
                              Navigator.of(context).pop();
                              showSnackBar(
                                  context, "Suceesfully added you post");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.black,
                            ),
                            child: Text(
                              "POST",
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(fontSize: 18, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  )
                else
                  Center(
                    child: CircularProgressIndicator(
                      color: AppColors.white,
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

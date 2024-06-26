import 'package:bookwise/common/constants/colors_and_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

//Show messages to user as snackbar
void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
}

//Pick an Image
Future<FilePickerResult?> pickImage() async {
  final image = await FilePicker.platform.pickFiles(type: FileType.image);

  return image;
}

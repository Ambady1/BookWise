import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

//Show toast message
void showToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

//Pick an Image
Future<FilePickerResult?> pickImage() async {
  final image = await FilePicker.platform.pickFiles(type: FileType.image);

  return image;
}

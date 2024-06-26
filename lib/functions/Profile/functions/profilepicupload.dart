// lib/functions/Profile/functions/upload_profile_image.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import
import 'dart:io';

Future<void> uploadProfileImage(BuildContext context) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    File file = File(pickedFile.path);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${user.uid}.jpg');
        UploadTask uploadTask = ref.putFile(file);
        await uploadTask.whenComplete(() async {
          String downloadURL = await ref.getDownloadURL();
          // Update the Firestore document with the new image URL
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'photoURL': downloadURL});
          // Show a snackbar or update the state to show the new image
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile image updated successfully!')),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }
}

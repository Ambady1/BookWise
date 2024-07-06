import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';

Future<String> getAvatarUrls() async {
  try {
    final ListResult result = await FirebaseStorage.instance.ref('avatars').listAll();
    print(result);

    if (result.items.isEmpty) {
      throw Exception('No avatars found');
    }

    final List<String> urls = [];
    for (var ref in result.items) {
      final String url = await ref.getDownloadURL();
      urls.add(url);
    }
    
    final random = Random();
    int index = random.nextInt(urls.length);
    print("random url ${urls[index]}");
    return urls[index];
  } catch (e) {
    print('Error fetching avatar URLs: $e');
    throw e; // Rethrow the error to handle it where getAvatarUrls is called
  }
}

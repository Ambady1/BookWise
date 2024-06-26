import 'package:bookwise/functions/community/core/failure.dart';
import 'package:bookwise/functions/community/core/firebase_constants.dart';
import 'package:bookwise/functions/community/core/type_defs.dart';
import 'package:bookwise/functions/community/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);
//Method to add posts
  FutureVoid addPost(Post post) async {
    try {
      return right(_posts.doc(post.id).set(post.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}

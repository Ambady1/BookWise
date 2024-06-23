import 'package:bookwise/functions/community/repositories/post_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  PostController({required PostRepository postRepository, required Ref ref})
      : _postRepository = postRepository,
        _ref = ref,
        super(false);

  void shareTextPost({
    required BuildContext context,
    required String title,
    required String description,
  }) async {
    state = true;
    String postid = Uuid().v1();
  }
}

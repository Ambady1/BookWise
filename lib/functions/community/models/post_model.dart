class Post {
  final String? postId;
  final String? title;
  final String? description;
  final String? postImage;
  final List<String>? likes;
  final List<String>? comments;
  final String? username;
  final String? userId;
  final DateTime? createdAt;
  Post({
    this.postId,
    this.title,
    this.description,
    this.postImage,
    this.likes,
    this.comments,
    this.username,
    this.userId,
    this.createdAt,
  });

  Post copyWith({
    String? postId,
    String? title,
    String? description,
    String? postImage,
    List<String>? likes,
    List<String>? comments,
    String? username,
    String? userId,
    DateTime? createdAt,
  }) {
    return Post(
      postId: postId ?? this.postId,
      title: title ?? this.title,
      description: description ?? this.description,
      postImage: postImage ?? this.postImage,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      username: username ?? this.username,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'postId': postId,
      'title': title,
      'description': description,
      'postImage': postImage,
      'likes': likes,
      'comments': comments,
      'username': username,
      'userId': userId,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      postId: map['postId'] as String,
      title: map['title'] as String,
      description:
          map['description'] != null ? map['description'] as String : null,
      postImage: map['postImage'] != null ? map['postImage'] as String : null,
      likes: List<String>.from(map['likes'] as List),
      comments: List<String>.from(map['comments'] as List),
      username: map['username'] as String,
      userId: map['userId'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }
}

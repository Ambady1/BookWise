import 'package:collection/collection.dart';

class Post {
  final String id;
  final String title;
  final String? description;
  final String? link;
  final List<String> likes;
  final List<String> commentcount;
  final String username;
  final String uid;
  final DateTime createdAt;
  Post({
    required this.id,
    required this.title,
    this.description,
    this.link,
    required this.likes,
    required this.commentcount,
    required this.username,
    required this.uid,
    required this.createdAt,
  });

  Post copyWith({
    String? id,
    String? title,
    String? description,
    String? link,
    List<String>? likes,
    List<String>? commentcount,
    String? username,
    String? uid,
    DateTime? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      link: link ?? this.link,
      likes: likes ?? this.likes,
      commentcount: commentcount ?? this.commentcount,
      username: username ?? this.username,
      uid: uid ?? this.uid,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'link': link,
      'likes': likes,
      'commentcount': commentcount,
      'username': username,
      'uid': uid,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as String,
      title: map['title'] as String,
      description:
          map['description'] != null ? map['description'] as String : null,
      link: map['link'] != null ? map['link'] as String : null,
      likes: List<String>.from(map['likes'] as List),
      commentcount: List<String>.from(map['commentcount'] as List),
      username: map['username'] as String,
      uid: map['uid'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  @override
  bool operator ==(covariant Post other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.id == id &&
        other.title == title &&
        other.description == description &&
        other.link == link &&
        listEquals(other.likes, likes) &&
        listEquals(other.commentcount, commentcount) &&
        other.username == username &&
        other.uid == uid &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        link.hashCode ^
        likes.hashCode ^
        commentcount.hashCode ^
        username.hashCode ^
        uid.hashCode ^
        createdAt.hashCode;
  }
}

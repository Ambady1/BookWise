class UserModel {
  final String email;
  final String username;
  final String? profilePic;
  final String uid;
  final String nickname;
  List<dynamic>? following;
  List<dynamic>? followers;
  List<dynamic>? wishlist;
  UserModel(
      {required this.email,
      required this.username,
      this.profilePic,
      required this.uid,
      required this.nickname,
      this.following,
      this.followers,
      this.wishlist});

  UserModel copyWith(
      {String? email,
      String? username,
      String? profilePic,
      String? uid,
      String? nickname,
      List<dynamic>? following,
      List<dynamic>? followers,
      List<dynamic>? wishlist}) {
    return UserModel(
        email: email ?? this.email,
        username: username ?? this.username,
        profilePic: profilePic ?? this.profilePic,
        uid: uid ?? this.uid,
        nickname: nickname ?? this.nickname,
        following: following ?? this.following,
        followers: followers ?? this.followers,
        wishlist: wishlist ?? this.wishlist);
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] as String,
      username: map['username'] as String,
      profilePic: map['profilePic'] as String?,
      uid: map['uid'] as String,
      nickname: map['nickname'] as String,
      following: List<dynamic>.from(map['following'] as List<dynamic>? ?? []),
      followers: List<dynamic>.from(map['followers'] as List<dynamic>? ?? []),
      wishlist: List<dynamic>.from(map['wishlist'] as List<dynamic>? ?? []),
    );
  }
}

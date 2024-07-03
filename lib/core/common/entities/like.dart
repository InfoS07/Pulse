class Like {
  final String profileImageUrl;
  final String username;
  final String createdAt;

  Like({
    required this.profileImageUrl,
    required this.username,
    required this.createdAt,
  });

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      profileImageUrl: json['user']['profile_photo'],
      username: json['user']['username'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileImageUrl': profileImageUrl,
      'username': username,
      'createdAt': createdAt,
    };
  }
}

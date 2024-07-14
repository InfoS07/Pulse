class Like {
  final String profileImageUrl;
  final String createdAt;

  Like({
    required this.profileImageUrl,
    required this.createdAt,
  });

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      profileImageUrl: json['user']['profile_photo'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
    };
  }
}

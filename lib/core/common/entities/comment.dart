class Comment {
  final String profileImageUrl;
  final String username;
  final String createdAt;
  final String content;

  Comment({
    required this.profileImageUrl,
    required this.username,
    required this.createdAt,
    required this.content,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      profileImageUrl: json['user']['profile_photo'],
      username: json['user']['username'],
      createdAt: json['created_at'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileImageUrl': profileImageUrl,
      'username': username,
      'timestamp': createdAt,
      'content': content,
    };
  }
}

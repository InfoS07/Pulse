import 'package:pulse/core/common/entities/comment.dart';
import 'package:pulse/core/common/entities/exercice.dart';

class SocialMediaPost {
  final int id;
  final String profileImageUrl;
  final String username;
  final String timestamp;
  final DateTime startAt;
  final DateTime endAt;
  final String title;
  final String description;
  final Exercice exercice;
  final List<String> postImageUrls;
  final int likes;
  final List<Comment> comments;
  final bool isLiked;

  SocialMediaPost({
    required this.id,
    required this.title,
    required this.description,
    required this.profileImageUrl,
    required this.username,
    required this.timestamp,
    required this.startAt,
    required this.endAt,
    required this.postImageUrls,
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.exercice,
  });

  SocialMediaPost copyWith({
    int? id,
    String? profileImageUrl,
    String? username,
    String? timestamp,
    DateTime? startAt,
    DateTime? endAt,
    String? title,
    String? description,
    List<String>? postImageUrls,
    int? likes,
    List<Comment>? comments,
    bool? isLiked,
    Exercice? exercice,
  }) {
    return SocialMediaPost(
      id: id ?? this.id,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      username: username ?? this.username,
      timestamp: timestamp ?? this.timestamp,
      title: title ?? this.title,
      description: description ?? this.description,
      postImageUrls: postImageUrls ?? this.postImageUrls,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      exercice: exercice ?? this.exercice,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
    );
  }
}

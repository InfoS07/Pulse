import 'package:pulse/core/common/entities/comment.dart';
import 'package:pulse/core/common/entities/like.dart';

class SocialMediaPost {
  final int id;
  final String profileImageUrl;
  final String username;
  final String timestamp;
  final String title;
  final String description;
  final String postImageUrl;
  final String uid;
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
    required this.postImageUrl,
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.uid,
    
  });

  SocialMediaPost copyWith({
    int? id,
    String? profileImageUrl,
    String? username,
    String? timestamp,
    String? title,
    String? description,
    String? postImageUrl,
    int? likes,
    List<Comment>? comments,
    bool? isLiked,
    String? uid,

  }) {
    return SocialMediaPost(
      id: id ?? this.id,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      username: username ?? this.username,
      timestamp: timestamp ?? this.timestamp,
      title: title ?? this.title,
      description: description ?? this.description,
      postImageUrl: postImageUrl ?? this.postImageUrl,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      uid: uid ?? this.uid,

    );
  }
}

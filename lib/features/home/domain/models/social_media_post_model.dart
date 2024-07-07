import 'package:pulse/core/common/entities/comment.dart';
import 'package:pulse/core/common/entities/like.dart';
import 'package:pulse/core/common/entities/social_media_post.dart';

class SocialMediaPostModel extends SocialMediaPost {
  SocialMediaPostModel({
    required int id,
    required String title,
    required String description,
    required String profileImageUrl,
    required String username,
    required String timestamp,
    required String postImageUrl,
    required int likes,
    required List<Comment> comments,
    required bool isLiked,
    required String uid,
  }) : super(
          id: id,
          profileImageUrl: profileImageUrl,
          username: username,
          timestamp: timestamp,
          title: title,
          description: description,
          postImageUrl: postImageUrl,
          likes: likes,
          comments: comments,
          isLiked: isLiked,
          uid: uid,
        );

  factory SocialMediaPostModel.fromJson(Map<String, dynamic> json) {
    return SocialMediaPostModel(
      id: json['id'] ?? 0,
      uid: json['author_id'] ?? "",
      profileImageUrl: json['user']?['profile_photo'] ??
          'https://image-uniservice.linternaute.com/image/450/4/1708793598/8469657.jpg',
      username: json['user']?['username'] ?? '',
      timestamp: json['created_at'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      postImageUrl: json['postImageUrl'] ?? '',
      likes: json['likes'].length,
      comments: (json['comments'] as List)
          .map((comment) => Comment.fromJson(comment))
          .toList(),
      isLiked: json['isLiked'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_id': id,
      'profileImageUrl': profileImageUrl,
      'username': username,
      'timestamp': timestamp,
      'title': title,
      'description': description,
      'postImageUrl': postImageUrl,
      'likes': likes,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }
}

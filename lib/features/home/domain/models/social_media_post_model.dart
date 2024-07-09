import 'package:pulse/core/common/entities/social_media_post.dart';
import 'package:pulse/features/comments/domain/models/comment_model.dart';
import 'package:pulse/features/exercices/domain/models/exercices_model.dart';

class SocialMediaPostModel extends SocialMediaPost {
  SocialMediaPostModel({
    required super.id,
    required super.title,
    required super.description,
    required super.profileImageUrl,
    required super.username,
    required super.userUid,
    required super.timestamp,
    required super.startAt,
    required super.endAt,
    required super.photos,
    required super.likes,
    required super.comments,
    required super.isLiked,
    required super.exercice,
  });

  factory SocialMediaPostModel.fromJson(Map<String, dynamic> json) {
    return SocialMediaPostModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      profileImageUrl: json['author']?['profile_photo'],
      username: json['author']?['username'] ?? '',
      userUid: json['author']?['uid'] ?? '',
      timestamp: json['created_at'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      photos: (json['photos'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          [],
      likes: json['likes'].length,
      comments: (json['comments'] as List<dynamic>?)
              ?.map((comment) => CommentModel.fromJson(comment))
              .toList() ??
          [],
      isLiked: json['isLiked'],
      exercice: ExercicesModel.fromJson(json['exercise']),
      startAt: DateTime.parse(json['start_at']),
      endAt: DateTime.parse(json['end_at']),
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
      'photos': photos,
      'likes': likes,
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'isLiked': isLiked,
    };
  }
}

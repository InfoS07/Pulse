import 'package:pulse/core/common/entities/comment.dart';
import 'package:pulse/core/common/entities/social_media_post.dart';
import 'package:pulse/features/exercices/domain/models/exercices_model.dart';

class SocialMediaPostModel extends SocialMediaPost {
  SocialMediaPostModel({
    required super.id,
    required super.title,
    required super.description,
    required super.profileImageUrl,
    required super.username,
    required super.timestamp,
    required super.startAt,
    required super.endAt,
    required super.postImageUrls,
    required super.likes,
    required super.comments,
    required super.isLiked,
    required super.exercice,
  });

  factory SocialMediaPostModel.fromJson(Map<String, dynamic> json) {
    return SocialMediaPostModel(
      id: json['id'] ?? 0,
      profileImageUrl: json['user']?['profile_photo'] ??
          'https://image-uniservice.linternaute.com/image/450/4/1708793598/8469657.jpg',
      username: json['user']?['username'] ?? '',
      timestamp: json['created_at'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      postImageUrls: json['postImageUrls'] ?? [],
      likes: json['likes'].length,
      comments: (json['comments'] as List)
          .map((comment) => Comment.fromJson(comment))
          .toList(),
      isLiked: json['isLiked'],
      exercice: ExercicesModel.fromJson(json['exercice']),
      startAt: DateTime.parse(json['start_at']),
      endAt: DateTime.parse(json['end_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profileImageUrl': profileImageUrl,
      'username': username,
      'timestamp': timestamp,
      'title': title,
      'description': description,
      'postImageUrl': postImageUrls,
      'likes': likes,
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'isLiked': isLiked,
    };
  }
}

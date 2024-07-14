import 'package:pulse/core/common/entities/activity.dart';
import 'package:pulse/core/common/entities/social_media_post.dart';
import 'package:pulse/features/auth/domain/models/user_model.dart';
import 'package:pulse/features/comments/domain/models/comment_model.dart';
import 'package:pulse/features/exercices/domain/models/exercices_model.dart';
import 'package:pulse/features/home/domain/models/activity_stats_model.dart';

class SocialMediaPostModel extends SocialMediaPost {
  SocialMediaPostModel({
    required super.id,
    required super.title,
    required super.description,
    required super.user,
    required super.timestamp,
    required super.startAt,
    required super.endAt,
    required super.photos,
    required super.likes,
    required super.comments,
    required super.isLiked,
    required super.exercice,
    required super.repetitions,
    required super.missedRepetitions,
    required super.moyenneReactionTime,
    required super.stats,
  });

  factory SocialMediaPostModel.fromJson(Map<String, dynamic> json) {
    findMissingRepetitionsInStats(List<dynamic> stats) {
      int missedRepetitions = 0;
      for (var stat in stats) {
        if (stat['buzzer_expected'] != stat['buzzer_pressed']) {
          missedRepetitions++;
        }
      }
      return missedRepetitions;
    }

    double calculateMoyenneReactionTime(List<dynamic> stats) {
      double moyenne = 0;
      if (stats.isEmpty) return 0;
      for (var stat in stats) {
        moyenne += stat['reaction_time'];
      }
      return (moyenne / 1000) / stats.length;
    }

    return SocialMediaPostModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      user: UserModel.fromJson(json['author']),
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
      repetitions: json['repetitions'] ?? 0,
      missedRepetitions:
          findMissingRepetitionsInStats(json['stats'] as List<dynamic>) ?? 0,
      moyenneReactionTime:
          calculateMoyenneReactionTime(json['stats'] as List<dynamic>),
      stats: (json['stats'] as List<dynamic>?)
              ?.map((item) => ActivityStatsModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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

import 'package:pulse/core/common/entities/activity.dart';
import 'package:pulse/core/common/entities/comment.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/common/entities/user.dart';

class SocialMediaPost {
  final int id;
  final User user;
  final String timestamp;
  final DateTime startAt;
  final DateTime endAt;
  final String title;
  final String description;
  final Exercice exercice;
  final List<String> photos;
  final int likes;
  final List<Comment> comments;
  final bool isLiked;
  final int repetitions;
  final int missedRepetitions;
  final double moyenneReactionTime;
  final List<ActivityStats> stats;

  SocialMediaPost({
    required this.id,
    required this.title,
    required this.description,
    required this.user,
    required this.timestamp,
    required this.startAt,
    required this.endAt,
    required this.photos,
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.exercice,
    required this.repetitions,
    required this.missedRepetitions,
    required this.moyenneReactionTime,
    required this.stats,
  });

  SocialMediaPost copyWith({
    int? id,
    User? user,
    String? timestamp,
    DateTime? startAt,
    DateTime? endAt,
    String? title,
    String? description,
    List<String>? photos,
    int? likes,
    List<Comment>? comments,
    bool? isLiked,
    Exercice? exercice,
    int? repetitions,
    int? missedRepetitions,
    double? moyenneReactionTime,
    List<ActivityStats>? stats,
  }) {
    return SocialMediaPost(
      id: id ?? this.id,
      user: user ?? this.user,
      timestamp: timestamp ?? this.timestamp,
      title: title ?? this.title,
      description: description ?? this.description,
      photos: photos ?? this.photos,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      exercice: exercice ?? this.exercice,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      repetitions: repetitions ?? this.repetitions,
      missedRepetitions: missedRepetitions ?? this.missedRepetitions,
      moyenneReactionTime: moyenneReactionTime ?? this.moyenneReactionTime,
      stats: stats ?? this.stats,
    );
  }
}

import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/common/entities/training.dart';
import 'package:pulse/core/common/entities/user.dart';
import 'package:pulse/features/auth/domain/models/user_model.dart';
import 'package:pulse/features/exercices/domain/models/exercices_model.dart';

class TrainingChallenge {
  final int id;
  final String title;
  final String description;
  final String startAt;
  final String endAt;
  final User author;
  final int repetitions;
  final List<TrainingStats> stats;
  final Exercice exercice;

  TrainingChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.startAt,
    required this.endAt,
    required this.repetitions,
    required this.stats,
    required this.exercice,
    required this.author,
  });

  /*factory TrainingChallenge.fromTraining(
      Training training, String authorId, List<String> photosFileName) {
    return TrainingChallenge(
      id: training.id,
      title: training.title,
      description: training.description,
      exerciseId: training.activity.exercise.id,
      startAt: training.activity.startAt.toIso8601String(),
      endAt: training.activity.endAt.toIso8601String(),
      authorId: authorId,
      repetitions: training.activity.touches,
      exercice: "",
      stats: training.activity.stats
          .map((e) => TrainingStats(
                buzzerExpected: e.buzzerExpected,
                buzzerPressed: e.buzzerPressed,
                reactionTime: e.reactionTime,
                pressedAt: e.pressedAt.toIso8601String(),
              ))
          .toList(),
    );
  }*/

  factory TrainingChallenge.fromJson(Map<String, dynamic> json) {
    final stats = (json['stats'] as List)
        .map((e) => TrainingStats(
              buzzerExpected: e['buzzer_expected'],
              buzzerPressed: e['buzzer_pressed'],
              reactionTime: e['reaction_time'],
              pressedAt: e['pressed_at'],
            ))
        .toList();
    return TrainingChallenge(
        id: json['id'] is int
            ? json['id']
            : int.tryParse(json['id'].toString()) ?? 0,
        title: json['title'],
        description: json['description'],
        startAt: json['start_at'],
        endAt: json['end_at'],
        author: UserModel.fromJson(json['author']),
        repetitions: json['repetitions'],
        stats: stats,
        exercice: ExercicesModel.fromJson(json['exercise']));
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'start_at': startAt,
      'end_at': endAt,
      'author': author,
      'repetitions': repetitions,
      'stats': stats.map((e) => e.toJson()).toList(),
    };
  }
}

class TrainingStats {
  final String buzzerExpected;
  final String buzzerPressed;
  final int reactionTime;
  final String pressedAt;

  TrainingStats({
    required this.buzzerExpected,
    required this.buzzerPressed,
    required this.reactionTime,
    required this.pressedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'buzzer_expected': buzzerExpected,
      'buzzer_pressed': buzzerPressed,
      'reaction_time': reactionTime,
      'pressed_at': pressedAt,
    };
  }
}

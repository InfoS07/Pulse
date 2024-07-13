import 'package:pulse/core/common/entities/training.dart';

class TrainingChallenge {
  final int id;
  final String title;
  final String description;
  final int exerciseId;
  final String startAt;
  final String endAt;
  final String authorId;
  final int repetitions;
  final List<TrainingStats> stats;

  TrainingChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.exerciseId,
    required this.startAt,
    required this.endAt,
    required this.authorId,
    required this.repetitions,
    required this.stats,
  });

  factory TrainingChallenge.fromTraining(
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
      stats: training.activity.stats
          .map((e) => TrainingStats(
                buzzerExpected: e.buzzerExpected,
                buzzerPressed: e.buzzerPressed,
                reactionTime: e.reactionTime,
                pressedAt: e.pressedAt.toIso8601String(),
              ))
          .toList(),
    );
  }

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
      id: json['id'],
      title: json['title'],
      description: json['description'],
      exerciseId: json['exercise_id'],
      startAt: json['start_at'],
      endAt: json['end_at'],
      authorId: json['author_id'],
      repetitions: json['repetitions'],
      stats: stats,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'exercise_id': exerciseId,
      'start_at': startAt,
      'end_at': endAt,
      'author_id': authorId,
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

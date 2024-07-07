import 'package:pulse/core/common/entities/exercice.dart';

class ExercicesModel extends Exercice {
  ExercicesModel({
    required super.id,
    required super.title,
    required super.photos,
    required super.description,
    required super.duration,
    required super.sequence,
    required super.repetitions,
    required super.podCount,
    required super.playerCount,
    required super.durationOneRepetition,
    required super.caloriesBurned,
    required super.score,
    required super.level,
    required super.laps,
  });

  factory ExercicesModel.fromJson(Map<String, dynamic> map) {
    return ExercicesModel(
      id: map['id'] is int
          ? map['id']
          : int.tryParse(map['id'].toString()) ?? 0,
      title: map['title'] ?? '',
      photos: (map['photos'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          [],
      description: map['description'] ?? '',
      duration: map['duration'] ?? 0,
      sequence: (map['sequence'] as List<dynamic>?)
              ?.map((item) => item as int)
              .toList() ??
          [],
      repetitions: map['repetitions'] ?? 0,
      podCount: map['pod_count'] ?? 0,
      playerCount: map['player_count'] ?? 0,
      durationOneRepetition: map['duration_one_repetition'] ?? 0,
      caloriesBurned: map['calories_burned'] ?? 0,
      score: map['score'] ?? 0.0,
      level: map['level'] ?? '',
      laps: map['laps'] ?? 0,
    );
  }

  ExercicesModel copyWith({
    int? id,
    String? title,
    List<String>? photos,
    String? description,
    int? duration,
  }) {
    return ExercicesModel(
      id: id ?? this.id,
      title: title ?? this.title,
      photos: photos ?? this.photos,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      sequence: sequence,
      repetitions: repetitions,
      podCount: podCount,
      playerCount: playerCount,
      durationOneRepetition: durationOneRepetition,
      caloriesBurned: caloriesBurned,
      score: score,
      level: level,
      laps: laps,
    );
  }
}

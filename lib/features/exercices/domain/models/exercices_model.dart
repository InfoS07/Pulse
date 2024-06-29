import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/common/entities/user.dart';

class ExercicesModel extends Exercice {
  ExercicesModel({
    required super.id,
    required super.title,
    required super.urlPhoto,
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
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      urlPhoto: map['media'].isNotEmpty
          ? map['media'][0]['url_photo']
          : 'https://images.pexels.com/photos/28080/pexels-photo.jpg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
      description: map['description'] ?? '',
      duration: map['duration'] ?? 0,
      sequence: map['sequence'] ?? [],
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
    String? id,
    String? title,
    String? urlPhoto,
    String? description,
    int? duration,
  }) {
    return ExercicesModel(
      id: id ?? this.id,
      title: title ?? this.title,
      urlPhoto: urlPhoto ?? this.urlPhoto,
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

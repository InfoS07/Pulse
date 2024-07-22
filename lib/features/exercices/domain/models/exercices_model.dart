import 'package:pulse/core/common/entities/exercice.dart';

class ExercicesModel extends Exercice {
  ExercicesModel({
    required super.id,
    required super.title,
    required super.photos,
    required super.categories,
    required super.description,
    required super.duration,
    required super.sequence,
    required super.repetitions,
    required super.podCount,
    required super.playerCount,
    required super.durationOneRepetition,
    required super.caloriesBurned,
    required super.score,
    required super.difficulty,
    required super.laps,
    required super.hit_type,
    required super.price,
    required super.premiums,
  });

  factory ExercicesModel.fromJson(Map<String, dynamic> map) {
    final exo = ExercicesModel(
      id: map['id'] is int
          ? map['id']
          : int.tryParse(map['id'].toString()) ?? 0,
      title: map['title'] ?? '',
      photos: (map['photos'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          [],
      categories: (map['categories'] as List<dynamic>?)
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
      difficulty: map['difficulty'] ?? '',
      laps: map['laps'] ?? 0,
      hit_type: map['hit_type'] ?? '',
      price: map['price_coin'] ?? 0,
      premiums: (map['premiums'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          [],
    );
    return exo;
  }

  ExercicesModel copyWith({
    int? id,
    String? title,
    List<String>? photos,
    List<String>? categories,
    String? description,
    int? duration,
    List<int>? sequence,
    int? repetitions,
    int? podCount,
    int? playerCount,
    int? price,
    List<String>? premiums,
  }) {
    return ExercicesModel(
      id: id ?? this.id,
      title: title ?? this.title,
      photos: photos ?? this.photos,
      categories: categories ?? this.categories,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      sequence: sequence ?? this.sequence,
      repetitions: repetitions ?? this.repetitions,
      podCount: podCount ?? this.podCount,
      playerCount: playerCount ?? this.playerCount,
      durationOneRepetition: durationOneRepetition,
      caloriesBurned: caloriesBurned,
      score: score,
      difficulty: difficulty,
      laps: laps,
      hit_type: hit_type,
      price: price ?? this.price,
      premiums: premiums ?? this.premiums,
    );
  }
}

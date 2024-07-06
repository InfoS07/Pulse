import 'package:equatable/equatable.dart';
import 'package:pulse/core/common/entities/exercice.dart';

class Activity extends Equatable {
  final int id;
  final Exercice exercise;
  final int laps;
  final int caloriesBurned;
  final String status;
  final int steps;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime createdAt;
  final int avgBpm;
  final int maxBpm;
  final double avgSpeed;
  final double maxSpeed;
  final List<int> durationLaps;
  final List<int> pauseBetweenLaps;
  final Duration timer;

  const Activity({
    required this.id,
    required this.exercise,
    required this.laps,
    required this.caloriesBurned,
    required this.status,
    required this.steps,
    required this.startAt,
    required this.endAt,
    required this.createdAt,
    required this.avgBpm,
    required this.maxBpm,
    required this.avgSpeed,
    required this.maxSpeed,
    required this.durationLaps,
    required this.pauseBetweenLaps,
    required this.timer,
  });

  static Activity empty(exercice) {
    return Activity(
      id: 0,
      exercise: exercice,
      laps: 0,
      caloriesBurned: 0,
      status: 'Not Started',
      steps: 0,
      startAt: DateTime.now(),
      endAt: DateTime.now(),
      createdAt: DateTime.now(),
      avgBpm: 0,
      maxBpm: 0,
      avgSpeed: 0.0,
      maxSpeed: 0.0,
      durationLaps: const [],
      pauseBetweenLaps: const [],
      timer: Duration.zero,
    );
  }

  Activity copyWith({
    int? id,
    Exercice? exercise,
    int? laps,
    int? caloriesBurned,
    String? status,
    int? steps,
    DateTime? startAt,
    DateTime? endAt,
    DateTime? createdAt,
    int? avgBpm,
    int? maxBpm,
    double? avgSpeed,
    double? maxSpeed,
    List<int>? durationLaps,
    List<int>? pauseBetweenLaps,
    Duration? timer,
  }) {
    return Activity(
      id: id ?? this.id,
      exercise: exercise ?? this.exercise,
      laps: laps ?? this.laps,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      status: status ?? this.status,
      steps: steps ?? this.steps,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      createdAt: createdAt ?? this.createdAt,
      avgBpm: avgBpm ?? this.avgBpm,
      maxBpm: maxBpm ?? this.maxBpm,
      avgSpeed: avgSpeed ?? this.avgSpeed,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      durationLaps: durationLaps ?? this.durationLaps,
      pauseBetweenLaps: pauseBetweenLaps ?? this.pauseBetweenLaps,
      timer: timer ?? this.timer,
    );
  }

  @override
  List<Object?> get props => [
        id,
        exercise,
        laps,
        caloriesBurned,
        status,
        steps,
        startAt,
        endAt,
        createdAt,
        avgBpm,
        maxBpm,
        avgSpeed,
        maxSpeed,
        durationLaps,
        pauseBetweenLaps,
        timer,
      ];
}

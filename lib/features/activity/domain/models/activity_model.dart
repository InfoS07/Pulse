import 'package:pulse/core/common/entities/activity.dart';

class ActivityModel extends Activity {
  ActivityModel({
    required super.id,
    required super.exerciseId,
    required super.laps,
    required super.caloriesBurned,
    required super.status,
    required super.steps,
    required super.startAt,
    required super.endAt,
    required super.createdAt,
    required super.avgBpm,
    required super.maxBpm,
    required super.avgSpeed,
    required super.maxSpeed,
    required super.durationLaps,
    required super.pauseBetweenLaps,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'],
      exerciseId: json['exercise_id'],
      laps: json['laps'],
      caloriesBurned: json['calories_burned'],
      status: json['status'],
      steps: json['steps'],
      startAt: DateTime.parse(json['start_at']),
      endAt: DateTime.parse(json['end_at']),
      createdAt: DateTime.parse(json['created_at']),
      avgBpm: json['avg_bpm'],
      maxBpm: json['max_bpm'],
      avgSpeed: (json['avg_speed'] as num).toDouble(),
      maxSpeed: (json['max_speed'] as num).toDouble(),
      durationLaps: json['duration_laps'] != null
          ? (json['duration_laps'] as List).map((e) => e as int).toList()
          : [],
      pauseBetweenLaps: json['pause_between_laps'] != null
          ? (json['pause_between_laps'] as List).map((e) => e as int).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exercise_id': exerciseId,
      'laps': laps,
      'calories_burned': caloriesBurned,
      'status': status,
      'steps': steps,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'avg_bpm': avgBpm,
      'max_bpm': maxBpm,
      'avg_speed': avgSpeed,
      'max_speed': maxSpeed,
      'duration_laps': durationLaps,
      'pause_between_laps': pauseBetweenLaps,
    };
  }
}

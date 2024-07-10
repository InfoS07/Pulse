import 'package:pulse/core/common/entities/activity.dart';

class ActivityModel extends Activity {
  const ActivityModel({
    required super.id,
    required super.exercise,
    required super.laps,
    required super.caloriesBurned,
    required super.status,
    required super.startAt,
    required super.endAt,
    required super.createdAt,
    required super.avgSpeed,
    required super.maxSpeed,
    required super.durationLaps,
    required super.pauseBetweenLaps,
    required super.timer,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'],
      exercise: json['exercise_id'],
      laps: json['laps'],
      caloriesBurned: json['calories_burned'],
      status: json['status'],
      startAt: DateTime.parse(json['start_at']),
      endAt: DateTime.parse(json['end_at']),
      createdAt: DateTime.parse(json['created_at']),
      avgSpeed: (json['avg_speed'] as num).toDouble(),
      maxSpeed: (json['max_speed'] as num).toDouble(),
      durationLaps: json['duration_laps'] != null
          ? (json['duration_laps'] as List).map((e) => e as int).toList()
          : [],
      pauseBetweenLaps: json['pause_between_laps'] != null
          ? (json['pause_between_laps'] as List).map((e) => e as int).toList()
          : [],
      timer: Duration.zero,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exercise_id': exercise.toString(),
      'laps': laps,
      'calories_burned': caloriesBurned,
      'status': status,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'avg_speed': avgSpeed,
      'max_speed': maxSpeed,
      'duration_laps': durationLaps,
      'pause_between_laps': pauseBetweenLaps,
      'timer': '00:00:00',
    };
  }
}

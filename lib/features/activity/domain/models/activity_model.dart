import 'package:pulse/core/common/entities/activity.dart';

class ActivityModel extends Activity {
  const ActivityModel({
    required super.id,
    required super.exercise,
    required super.caloriesBurned,
    required super.status,
    required super.startAt,
    required super.endAt,
    required super.createdAt,
    required super.timer,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'],
      exercise: json['exercise_id'],
      caloriesBurned: json['calories_burned'],
      status: json['status'],
      startAt: DateTime.parse(json['start_at']),
      endAt: DateTime.parse(json['end_at']),
      createdAt: DateTime.parse(json['created_at']),
      timer: Duration.zero,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exercise_id': exercise.toString(),
      'calories_burned': caloriesBurned,
      'status': status,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'timer': '00:00:00',
    };
  }
}

import 'package:pulse/core/common/entities/activity.dart';

class ActivityStatsModel extends ActivityStats {
  ActivityStatsModel({
    required super.buzzerExpected,
    required super.buzzerPressed,
    required super.reactionTime,
    required super.pressedAt,
  });

  factory ActivityStatsModel.fromJson(Map<String, dynamic> json) {
    return ActivityStatsModel(
      buzzerExpected: json['buzzer_expected'],
      buzzerPressed: json['buzzer_pressed'],
      reactionTime: json['reaction_time'],
      pressedAt: DateTime.parse(json['pressed_at']),
    );
  }
}

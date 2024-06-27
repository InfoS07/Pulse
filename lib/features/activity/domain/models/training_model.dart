import 'package:pulse/core/common/entities/training.dart';

class TrainingModel extends Training {
  TrainingModel(
      {required super.id,
      required super.description,
      required super.comments,
      required super.activity});

  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(
      id: json['id'],
      description: json['description'],
      comments: json['comments'],
      activity: json['activity'],
    );
  }
}

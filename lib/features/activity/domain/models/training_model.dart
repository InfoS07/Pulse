import 'package:pulse/core/common/entities/training.dart';

class TrainingModel extends Training {
  const TrainingModel(
      {required super.id,
      required super.description,
      required super.comments,
      required super.activity,
      required super.photos});

  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(
      id: json['id'],
      description: json['description'],
      comments: json['comments'],
      activity: json['activity'],
      photos: json['photos'],
    );
  }
}

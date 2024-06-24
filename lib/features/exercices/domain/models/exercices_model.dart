import 'package:pulse/core/common/entities/exercice.dart';

class ExercicesModel extends Exercice {
  ExercicesModel({
    required super.id,
    required super.title,
    required super.description,
    required super.duration,
  });

  factory ExercicesModel.fromJson(Map<String, dynamic> map) {
    return ExercicesModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      duration: map['duration'] ?? 0,
    );
  }

  ExercicesModel copyWith({
    String? id,
    String? title,
    String? description,
    int? duration,
  }) {
    return ExercicesModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
    );
  }
}

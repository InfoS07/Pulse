import 'package:pulse/core/common/entities/exercice.dart';

class ExercicesModel extends Exercice {
  ExercicesModel({
    required super.id,
    required super.title,
    required super.urlPhoto,
    required super.description,
    required super.duration,
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
    );
  }
}

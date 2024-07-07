import 'package:pulse/core/common/entities/trainingList.dart';

class TrainingModel extends TrainingList {
  const TrainingModel({
    required super.id,
    required super.description,
    required super.title,
    //required List comments,
    required super.date,
    //required List<String> activity,
  });


  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(
      id: json['id'],
      description: json['description'],
      //comments: json['comments'],
      //activity: json["activities_list"],
      date: json["start_at"],
      title: json["title"],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      //comments: json['comments'],
      //'activity': activity,
      'start_at': date,
      'title': title,
    };
  }

  static List<TrainingModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => TrainingModel.fromJson(json)).toList();
  }
}

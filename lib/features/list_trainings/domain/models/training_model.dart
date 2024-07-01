import 'package:pulse/core/common/entities/activity.dart';
import 'package:pulse/core/common/entities/post.dart';
import 'package:pulse/core/common/entities/training.dart';
import 'package:pulse/core/common/entities/trainingList.dart';

class TrainingModel extends TrainingList {
  TrainingModel({
    required int id,
    required String description,
    required String title,
    //required List comments,
    required String date,
    //required List<String> activity,
  }) : super(
          id: id,
          description: description,
          title:title,
          //comments: comments,
          date: date,
          //activity: activity
        );


  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(
      id: json['id'],
      description: json['description'],
      //comments: json['comments'],
      //activity: json["activities_list"],
      date: json["planned_at"],
      title: json["title"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      //comments: json['comments'],
      //'activity': activity,
      'planned_at': date,
      'title': title,
    };
  }

  static List<TrainingModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => TrainingModel.fromJson(json)).toList();
  }
}

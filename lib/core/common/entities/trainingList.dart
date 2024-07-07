import 'package:equatable/equatable.dart';

class TrainingList extends Equatable {
  final int id;
  final String description;
  final String title;
  //final List comments;
  //final List<String> activity;
  final String date;

  const TrainingList({
    required this.id,
    required this.description,
    required this.title,
    //required this.comments,
    //required this.activity,
    required this.date,
  });

  @override
  List<Object?> get props => [id, description];

  static TrainingList empty(activity) {
    return const TrainingList(
      id: 0,
      description: '',
      //activity: ["",""],
      date: "",
      title: "",
    );
  }

  toJson() {
    return {
      'id': id,
      "title": description,
      'description': description,
      'planned_at' : date,
      //'activities_list' : activity
    };
  }
}

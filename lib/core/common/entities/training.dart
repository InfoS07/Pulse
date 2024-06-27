import 'package:equatable/equatable.dart';
import 'activity.dart';

class Training extends Equatable {
  final int id;
  final String description;
  final List comments;
  final Activity activity;

  Training({
    required this.id,
    required this.description,
    required this.comments,
    required this.activity,
  });

  @override
  List<Object?> get props => [id, description, comments, activity];

  static Training empty(activity) {
    return Training(
      id: 0,
      description: '',
      comments: [],
      activity: activity,
    );
  }

  toJson() {
    return {
      'id': id,
      "title": description,
      'description': description,
    };
  }
}

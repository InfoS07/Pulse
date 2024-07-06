import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'activity.dart';

class Training extends Equatable {
  final int id;
  final String description;
  final List comments;
  final Activity activity;
  final List<XFile> photos;

  const Training({
    required this.id,
    required this.description,
    required this.comments,
    required this.activity,
    required this.photos,
  });

  @override
  List<Object?> get props => [id, description, comments, activity];

  static Training empty(activity) {
    return Training(
      id: 0,
      description: '',
      comments: const [],
      activity: activity,
      photos: const [],
    );
  }

  toJson() {
    return {
      'id': id,
      "title": description,
      'description': description,
      'comments': comments,
    };
  }
}

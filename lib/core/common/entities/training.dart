import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'activity.dart';

class Training extends Equatable {
  final int id;
  final String title;
  final String description;
  final Activity activity;
  final List<XFile> photos;

  const Training({
    required this.id,
    required this.title,
    required this.description,
    required this.activity,
    required this.photos,
  });

  @override
  List<Object?> get props => [id, title, description, activity];

  static Training empty(activity) {
    return Training(
      id: 0,
      title: '',
      description: '',
      activity: activity,
      photos: const [],
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

import 'package:pulse/core/common/entities/comment.dart';
import 'package:pulse/features/auth/domain/models/user_model.dart';

class CommentModel extends Comment {
  CommentModel({
    required super.id,
    required super.user,
    required super.content,
    required super.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      user: UserModel.fromJson(json['user']),
      createdAt: json['created_at'] ?? "",
      content: json['content'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'content': content,
      'createdAt': createdAt,
    };
  }
}

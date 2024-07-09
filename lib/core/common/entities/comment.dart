import 'package:pulse/core/common/entities/user.dart';
import 'package:pulse/features/auth/domain/models/user_model.dart';

class Comment {
  final int id;
  final User user;
  final String createdAt;
  final String content;

  Comment({
    required this.id,
    required this.user,
    required this.createdAt,
    required this.content,
  });

  Comment copyWith({
    int? id,
    User? user,
    String? createdAt,
    String? content,
  }) {
    return Comment(
      id: id ?? this.id,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
      content: content ?? this.content,
    );
  }

  toJson() {
    return {
      'user': user,
      'createdAt': createdAt,
      'content': content,
    };
  }
}

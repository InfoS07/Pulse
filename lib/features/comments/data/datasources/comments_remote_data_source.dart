import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/add_comment.dart';
import 'package:pulse/core/common/entities/comment.dart';
import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/features/comments/domain/models/comment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class CommentsRemoteDataSource {
  Future<List<Comment?>> getComments();
  Future<Comment> addComment(int trainingId, AddComment addComment);
  Future<void> reportComment(int commentIndex, String reportReason);
}

class CommentsRemoteDataSourceImpl extends CommentsRemoteDataSource {
  final SupabaseClient supabaseClient;

  CommentsRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<Comment?>> getComments() async {
    try {
      final response = await supabaseClient.from('training_comments').select(
            "*, user:users(*)",
          );

      final comments = response.map((e) => CommentModel.fromJson(e)).toList();
      return comments;
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Comment> addComment(int trainingId, AddComment addComment) async {
    try {
      final response = await supabaseClient.from('training_comments').upsert({
        'user_id': supabaseClient.auth.currentSession?.user.id,
        'training_id': trainingId,
        'content': addComment.text
      }).select('*, user:users(*)');

      /* if (response.error != null) {
        throw ServerException(response.error!.message);
      } */

      final unit = CommentModel.fromJson(response.first);

      return unit;
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> reportComment(int commentIndex, String reportReason) async {
    try {
      final response = await supabaseClient.from('comment_reports').insert({
        'comment_id': commentIndex,
        'reason': reportReason,
        "user_id": supabaseClient.auth.currentSession?.user.id
      });
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

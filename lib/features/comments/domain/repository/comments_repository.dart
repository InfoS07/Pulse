import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/add_comment.dart';
import 'package:pulse/core/common/entities/comment.dart';
import 'package:pulse/core/error/failures.dart';

abstract interface class CommentsRepository {
  Future<Either<Failure, List<Comment?>>> getComments();
  Future<Either<Failure, Comment>> addComment(
      int trainingId, AddComment addComment);
}

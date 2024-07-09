import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/add_comment.dart';
import 'package:pulse/core/common/entities/comment.dart';
import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/comments/data/datasources/comments_remote_data_source.dart';
import 'package:pulse/features/comments/domain/repository/comments_repository.dart';

class CommentsRepositoryImpl implements CommentsRepository {
  final CommentsRemoteDataSource commentsDataSource;

  CommentsRepositoryImpl(this.commentsDataSource);

  @override
  Future<Either<Failure, List<Comment?>>> getComments() async {
    return _getComments(
      () async => await commentsDataSource.getComments(),
    );
  }

  Future<Either<Failure, List<Comment?>>> _getComments(
    Future<List<Comment?>> Function() fn,
  ) async {
    try {
      final comments = await fn();

      return Right(comments);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Comment>> addComment(
      int trainingId, AddComment addComment) async {
    return _addComment(
      () async => await commentsDataSource.addComment(trainingId, addComment),
    );
  }

  Future<Either<Failure, Comment>> _addComment(
    Future<Comment> Function() fn,
  ) async {
    try {
      final comment = await fn();

      return Right(comment);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }
}

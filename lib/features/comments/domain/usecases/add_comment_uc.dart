import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/add_comment.dart';
import 'package:pulse/core/common/entities/comment.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/comments/domain/repository/comments_repository.dart';

class AddCommentUc implements UseCase<Comment, AddCommentParams> {
  final CommentsRepository commentsRepository;

  const AddCommentUc(this.commentsRepository);

  @override
  Future<Either<Failure, Comment>> call(AddCommentParams params) async {
    return await commentsRepository.addComment(
        params.trainingId, params.addComment);
  }
}

class AddCommentParams {
  final AddComment addComment;
  final int trainingId;

  const AddCommentParams(this.trainingId, this.addComment);
}

import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/comment.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/comments/domain/repository/comments_repository.dart';

class GetCommentsUc implements UseCase<List<Comment?>, NoParams> {
  final CommentsRepository commentsRepository;

  const GetCommentsUc(this.commentsRepository);

  @override
  Future<Either<Failure, List<Comment?>>> call(NoParams params) async {
    return await commentsRepository.getComments();
  }
}

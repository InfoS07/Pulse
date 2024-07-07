import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/home/domain/repository/posts_repository.dart';
import 'package:pulse/core/usecase/usercase.dart';

class DeletePostUc implements UseCase<Unit, DeletePostParams> {
  final PostsRepository postsRepository;

  const DeletePostUc(this.postsRepository);

  @override
  Future<Either<Failure, Unit>> call(DeletePostParams params) async {
    return await postsRepository.deletePost(params.postId);
  }
}

class DeletePostParams {
  final int postId;

  DeletePostParams(this.postId);
}

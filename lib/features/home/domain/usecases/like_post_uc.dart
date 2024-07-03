import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/home/domain/repository/posts_repository.dart';
import 'package:pulse/core/usecase/usercase.dart';

class LikePostUc implements UseCase<Unit, LikePostParams> {
  final PostsRepository postsRepository;

  const LikePostUc(this.postsRepository);

  @override
  Future<Either<Failure, Unit>> call(LikePostParams params) async {
    return await postsRepository.likePost(params.postId);
  }
}

class LikePostParams {
  final int postId;

  LikePostParams(this.postId);
}

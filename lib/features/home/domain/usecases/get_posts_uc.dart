import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/post.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/home/domain/repository/posts_repository.dart';
import 'package:pulse/features/home/presentation/widgets/social_media_post_widget.dart';

class GetPostsUC implements UseCase<List<SocialMediaPost>, NoParams> {
  final PostsRepository postsRepository;

  const GetPostsUC(this.postsRepository);

  @override
  Future<Either<Failure, List<SocialMediaPost>>> call(NoParams params) async {
    return await postsRepository.getPosts();
  }
}

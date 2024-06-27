import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/common/entities/post.dart';
import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/exercices/data/datasources/exercices_remote_data_source.dart';
import 'package:pulse/features/home/data/datasources/posts_remote_data_source.dart';
import 'package:pulse/features/home/domain/repository/posts_repository.dart';
import 'package:pulse/features/home/presentation/widgets/social_media_post_widget.dart';

class PostsRepositoryImpl implements PostsRepository {
  final PostsRemoteDataSource postsDataSource;

  PostsRepositoryImpl(this.postsDataSource);

  @override
  Future<Either<Failure, List<SocialMediaPost>>> getPosts() async {
    return _getPosts(
      () async => await postsDataSource.getPosts(),
    );
  }

  Future<Either<Failure, List<SocialMediaPost>>> _getPosts(
    Future<List<SocialMediaPost>> Function() fn,
  ) async {
    try {
      final posts = await fn();

      return Right(posts);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }
}

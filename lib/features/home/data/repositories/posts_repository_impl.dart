import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/social_media_post.dart';
import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/home/data/datasources/posts_remote_data_source.dart';
import 'package:pulse/features/home/domain/repository/posts_repository.dart';

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

  @override
  Future<Either<Failure, Unit>> likePost(int postId) {
    return _likePost(
      postId,
      () async => await postsDataSource.likePost(postId),
    );
  }

  Future<Either<Failure, Unit>> _likePost(
    int postId,
    Future<Unit> Function() fn,
  ) async {
    try {
      await fn();

      return Right(unit);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }
}

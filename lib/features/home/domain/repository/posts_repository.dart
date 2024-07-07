import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/social_media_post.dart';
import 'package:pulse/core/error/failures.dart';

abstract interface class PostsRepository {
  Future<Either<Failure, List<SocialMediaPost>>> getPosts();
  Future<Either<Failure, Unit>> likePost(int postId);
  Future<Either<Failure, Unit>> deletePost(int postId);
}

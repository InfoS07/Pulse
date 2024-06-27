import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/common/entities/post.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/home/presentation/widgets/social_media_post_widget.dart';

abstract interface class PostsRepository {
  Future<Either<Failure, List<SocialMediaPost>>> getPosts();
}

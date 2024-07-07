import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/core/common/entities/social_media_post.dart';
import 'package:pulse/core/common/entities/user.dart';
import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/search_users/data/datasources/search_user_remote_data_source.dart';
import 'package:pulse/features/search_users/domain/repository/search_user_repository.dart';

class SearchUserRepositoryImpl implements SearchUserRepository {
  final SearchUserRemoteDataSource searchUserRemoteDataSource;

  SearchUserRepositoryImpl(this.searchUserRemoteDataSource);

  @override
  Future<Either<Failure, List<Profil?>>> searchUsers(String searchTerm) async {
    return _searchUsers(
      () async => await searchUserRemoteDataSource.searchUsers(searchTerm),
    );
  }

  Future<Either<Failure, List<Profil?>>> _searchUsers(
    Future<List<Profil?>> Function() fn,
  ) async {
    try {
      final profils = await fn();

      return Right(profils);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }
}

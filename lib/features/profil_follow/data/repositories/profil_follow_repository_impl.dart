import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/profil/data/datasources/profil_remote_data_source.dart';
import 'package:pulse/features/profil/domain/models/profil_model.dart';
import 'package:pulse/features/profil/domain/repository/profil_repository.dart';
import 'package:pulse/features/profil_follow/data/datasources/profil_follow_remote_data_source.dart';
import 'package:pulse/features/profil_follow/domain/repository/profil_follow_repository.dart';

class ProfilFollowRepositoryImpl implements ProfilFollowRepository {
  final ProfilFollowRemoteDataSource remoteDataSource;

  const ProfilFollowRepositoryImpl(
    this.remoteDataSource,
  );

  @override
  Future<Either<Failure, void>> follow(String userId,String followerId) async {
    return _follow(
      () async => await remoteDataSource.Follow(userId,followerId),
    );
  }

  Future<Either<Failure, void>> _follow(
    Future<void> Function() fn,
  ) async {
    try {
      final profil = await fn();

      return Right(profil);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }


   @override
  Future<Either<Failure, void>> unfollow(String userId,String followerId) async {
    return _unfollow(
      () async => await remoteDataSource.Unfollow(userId,followerId),
    );
  }

  Future<Either<Failure, void>> _unfollow(
    Future<void> Function() fn,
  ) async {
    try {
      final profil = await fn();

      return Right(profil);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

}

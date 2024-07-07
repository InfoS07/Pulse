import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/profil/data/datasources/profil_remote_data_source.dart';
import 'package:pulse/features/profil/domain/repository/profil_repository.dart';

class ProfilRepositoryImpl implements ProfilRepository {
  final ProfilRemoteDataSource remoteDataSource;
  //final ProfilLocalDataSource localDataSource;

  const ProfilRepositoryImpl(
    this.remoteDataSource,
    //required this.localDataSource,
  );

  @override
  Future<Either<Failure, Profil>> getProfil(String userId) async {
    return _getProfil(
      () async => await remoteDataSource.getProfil(userId),
    );
  }

  Future<Either<Failure, Profil>> _getProfil(
    Future<Profil?> Function() fn,
  ) async {
    try {
      final profil = await fn();

      return Right(profil!);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Profil>>> getFollowers(String userId) async {
    return _getFollowers(
      () async => await remoteDataSource.getFollowers(userId),
    );
  }

  Future<Either<Failure, List<Profil>>> _getFollowers(
    Future<List<Profil?>> Function() fn,
  ) async {
    try {
      final profil = await fn();
      final nonNullProfils = profil.whereType<Profil>().toList();

      return Right(nonNullProfils);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

    @override
  Future<Either<Failure, List<Profil>>> getFollowings(String userId) async {
    return _getFollowings(
      () async => await remoteDataSource.getFollowings(userId),
    );
  }

  Future<Either<Failure, List<Profil>>> _getFollowings(
    Future<List<Profil?>> Function() fn,
  ) async {
    try {
      final profil = await fn();
      final nonNullProfils = profil.whereType<Profil>().toList();

      return Right(nonNullProfils);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }
}

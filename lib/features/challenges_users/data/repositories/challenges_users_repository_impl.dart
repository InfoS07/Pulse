import 'package:fpdart/fpdart.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/challenges_users/data/datasources/challenges_users_remote_data_source.dart';
import 'package:pulse/features/challenges_users/domain/models/challenges_users_model.dart';
import 'package:pulse/features/challenges_users/domain/repository/challenges_users_repository.dart';

class ChallengeUserRepositoryImpl implements ChallengeUserRepository {
  final ChallengesUsersRemoteDataSource remoteDataSource;

  ChallengeUserRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<ChallengeUserModel?>>> getChallengeUsers() async {
    return _getUsersChallenges(
      () async => await remoteDataSource.getChallengeUsers(),
    );
  }

  Future<Either<Failure, List<ChallengeUserModel?>>> _getUsersChallenges(
    Future<List<ChallengeUserModel?>> Function() fn,
  ) async {
    try {
      final challenges = await fn();

      return Right(challenges);
    } on ServerException catch (e) {
      var message = "Erreur récupération challenges Users";
      return Left(Failure(message));
    }
  }
}

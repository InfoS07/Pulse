import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/challenges/data/datasources/challenges_remote_data_source.dart';
import 'package:pulse/features/challenges/domain/models/challenges_model.dart';
import 'package:pulse/features/challenges/domain/repository/challenges_repository.dart';
import 'package:pulse/features/exercices/data/datasources/exercices_remote_data_source.dart';
import 'package:pulse/features/exercices/domain/repository/exercices_repository.dart';

import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/challenges/data/datasources/challenges_remote_data_source.dart';
import 'package:pulse/features/challenges/domain/models/challenges_model.dart';
import 'package:pulse/features/challenges/domain/repository/challenges_repository.dart';

class ChallengesRepositoryImpl implements ChallengesRepository {
  final ChallengesRemoteDataSource challengesDataSource;

  ChallengesRepositoryImpl(this.challengesDataSource);

  @override
  Future<Either<Failure, List<ChallengesModel?>>> getChallenges() async {
    return _getChallenges(
      () async => await challengesDataSource.getChallenges(),
    );
  }

  Future<Either<Failure, List<ChallengesModel?>>>  _getChallenges(
   Future<List<ChallengesModel?>> Function() fn,
  ) async {
    try {
      final profil = await fn();
      final nonNullProfils = profil.whereType<ChallengesModel>().toList();

      return Right(nonNullProfils);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> joinChallenge(int challengeId, String userId) async {
    try {
      await challengesDataSource.joinChallenge(challengeId, userId);
      return Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> quitChallenge(int challengeId, String userId) async {
    try {
      await challengesDataSource.quitChallenge(challengeId, userId);
      return Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }
}

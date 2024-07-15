import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/challenges/domain/models/challenges_model.dart';

abstract class ChallengesRepository {
  Future<Either<Failure, List<ChallengesModel?>>> getChallenges();
  Future<Either<Failure, void>> joinChallenge(int challengeId, String userId);
  Future<Either<Failure, void>> quitChallenge(int challengeId, String userId);
  Future<Either<Failure, void>> finishChallenge(int challengeId, String userId,int pointGagnes);
}

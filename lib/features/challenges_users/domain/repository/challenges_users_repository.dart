import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/challenges/domain/models/challenges_model.dart';
import 'package:pulse/features/challenges_users/domain/models/challenges_users_model.dart';

abstract class ChallengeUserRepository {
  Future<Either<Failure, List<ChallengeUserModel?>>> getChallengeUsers();
}

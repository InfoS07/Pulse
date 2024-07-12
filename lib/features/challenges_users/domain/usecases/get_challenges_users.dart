import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/challenges/domain/models/challenges_model.dart';
import 'package:pulse/features/challenges/domain/repository/challenges_repository.dart';
import 'package:pulse/features/challenges_users/domain/models/challenges_users_model.dart';
import 'package:pulse/features/challenges_users/domain/repository/challenges_users_repository.dart';
import 'package:pulse/features/exercices/domain/repository/exercices_repository.dart';

class GetChallengeUsersUc
    implements UseCase<List<ChallengeUserModel?>, NoParams> {
  final ChallengeUserRepository repository;

  GetChallengeUsersUc(this.repository);

  @override
  Future<Either<Failure, List<ChallengeUserModel?>>> call(
      NoParams params) async {
    return await repository.getChallengeUsers();
  }
}

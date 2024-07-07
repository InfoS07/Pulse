import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/challenges/domain/models/challenges_model.dart';
import 'package:pulse/features/challenges/domain/repository/challenges_repository.dart';
import 'package:pulse/features/exercices/domain/repository/exercices_repository.dart';

class GetChallenges implements UseCase <List<ChallengesModel?> ,NoParams> {
  final ChallengesRepository challengesRepository;

  const GetChallenges(this.challengesRepository);

  @override
  Future<Either<Failure, List<ChallengesModel?>>> call(
      NoParams params) async {
    return await challengesRepository.getChallenges();
  }
}

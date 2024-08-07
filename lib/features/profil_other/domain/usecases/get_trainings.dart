//class UserLogin implements UseCase<User, UserLoginParams>

import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/trainingList.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/list_trainings/domain/repository/list_trainings_repository.dart';

class OtherGetTrainings implements UseCase<List<TrainingList>, String> {
  final ListTrainingsRepository listTrainingsRepository;

  const OtherGetTrainings(this.listTrainingsRepository);

  @override
  Future<Either<Failure, List<TrainingList>>> call(String userId) async {
    return await listTrainingsRepository.getTrainings(userId);
  }
}


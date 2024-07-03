//class UserLogin implements UseCase<User, UserLoginParams>

import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/core/common/entities/training.dart';
import 'package:pulse/core/common/entities/trainingList.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/list_trainings/domain/repository/list_trainings_repository.dart';
import 'package:pulse/features/profil/domain/repository/profil_repository.dart';

class GetTrainings implements UseCase<List<TrainingList>, String> {
  final ListTrainingsRepository listTrainingsRepository;

  const GetTrainings(this.listTrainingsRepository);

  @override
  Future<Either<Failure, List<TrainingList>>> call(String userId) async {
    return await listTrainingsRepository.getTrainings(userId);
  }
}


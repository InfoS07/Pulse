import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/activity.dart';
import 'package:pulse/core/common/entities/training.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/activity/domain/repository/activity_repository.dart';

class SaveActivityUC implements UseCase<Training, Training> {
  final ActivityRepository repository;

  SaveActivityUC(this.repository);

  @override
  Future<Either<Failure, Training>> call(Training training) async {
    return await repository.saveActivity(training);
  }
}

/* class SaveActivityUCParams {
  final Training training;

  SaveActivityUCParams(this.training);
}
 */
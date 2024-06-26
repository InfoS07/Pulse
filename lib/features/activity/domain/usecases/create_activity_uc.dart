import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/activity.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/activity/domain/repository/activity_repository.dart';

class CreateActivityUC implements UseCase<Activity, NoParams> {
  final ActivityRepository activityRepository;

  CreateActivityUC(this.activityRepository);

  @override
  Future<Either<Failure, Activity>> call(NoParams params) {
    throw UnimplementedError();
  }
}

import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/trainingList.dart';
import 'package:pulse/core/error/failures.dart';

abstract interface class ListTrainingsRepository {
  Future<Either<Failure, List<TrainingList>>> getTrainings(String userId);
}

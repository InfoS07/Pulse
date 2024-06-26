import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/activity.dart';
import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/activity/data/datasources/activity_local_data_source.dart';
import 'package:pulse/features/activity/domain/repository/activity_repository.dart';
import 'package:pulse/features/activity/domain/usecases/create_activity_uc.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityLocalDataSource localDataSource;

  ActivityRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Activity>> createActivity() async {
    return _createActivity(
      () async => await localDataSource.getActivities().then(
            (activities) => activities.first,
          ),
    );
  }

  Future<Either<Failure, Activity>> _createActivity(
    Future<Activity> Function() fn,
  ) async {
    try {
      final activity = await fn();

      return Right(activity);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }
}

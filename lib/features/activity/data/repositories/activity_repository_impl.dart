import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/activity.dart';
import 'package:pulse/core/common/entities/training.dart';
import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/activity/data/datasources/activity_local_data_source.dart';
import 'package:pulse/features/activity/data/datasources/activity_remote_data_source.dart';
import 'package:pulse/features/activity/domain/repository/activity_repository.dart';
import 'package:pulse/features/activity/domain/usecases/create_activity_uc.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityLocalDataSource localDataSource;
  final ActivityRemoteDataSource remoteDataSource;

  ActivityRepositoryImpl(this.localDataSource, this.remoteDataSource);

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

  @override
  Future<Either<Failure, Training>> saveActivity(Training training) async {
    return _saveActivity(
      () async => await remoteDataSource.saveActivity(training),
    );
  }

  Future<Either<Failure, Training>> _saveActivity(
    Future<Training> Function() fn,
  ) async {
    try {
      final activity = await fn();

      return Right(activity);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }
}

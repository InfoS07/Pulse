import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/common/entities/post.dart';
import 'package:pulse/core/common/entities/training.dart';
import 'package:pulse/core/common/entities/trainingList.dart';
import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/exercices/data/datasources/exercices_remote_data_source.dart';
import 'package:pulse/features/home/data/datasources/posts_remote_data_source.dart';
import 'package:pulse/features/home/domain/repository/posts_repository.dart';
import 'package:pulse/features/home/presentation/widgets/social_media_post_widget.dart';
import 'package:pulse/features/list_trainings/data/datasources/list_trainings_remote_data_source.dart';
import 'package:pulse/features/list_trainings/domain/repository/list_trainings_repository.dart';

class ListTrainingsRepositoryImpl implements ListTrainingsRepository {
  final ListTrainingsRemoteDataSource trainingsDataSource;

  ListTrainingsRepositoryImpl(this.trainingsDataSource);

  @override
  Future<Either<Failure, List<TrainingList>>> getTrainings(String userId) async {
    return _getTrainings(
      () async => await trainingsDataSource.getTrainings(userId),
    );
  }

  Future<Either<Failure, List<TrainingList>>> _getTrainings(
    Future<List<TrainingList>> Function() fn,
  ) async {
    try {
      final trainings = await fn();

      return Right(trainings);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }
}

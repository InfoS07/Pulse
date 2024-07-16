import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/exercices/data/datasources/exercices_remote_data_source.dart';
import 'package:pulse/features/exercices/domain/repository/exercices_repository.dart';

class ExercicesRepositoryImpl implements ExercicesRepository {
  final ExercicesRemoteDataSource exercicesDataSource;

  ExercicesRepositoryImpl(this.exercicesDataSource);

  @override
  Future<Either<Failure, Map<String, List<Exercice?>>>> getExercices() async {
    return _getExercices(
      () async => await exercicesDataSource.getExercices(),
    );
  }

  Future<Either<Failure, Map<String, List<Exercice?>>>> _getExercices(
    Future<Map<String, List<Exercice?>>> Function() fn,
  ) async {
    try {
      final exercices = await fn();

      return Right(exercices);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Map<String, List<Exercice?>>>> searchExercices(
      String searchTerm) async {
    return _getExercices(
      () async => await exercicesDataSource.searchExercices(searchTerm),
    );
  }

  @override
  Future<Either<Failure, Unit>> achatExercice(
      int exerciceId, String userId, int prix) async {
    return _achatExercice(
      exerciceId,
      userId,
      prix,
      () async =>
          await exercicesDataSource.achatExercice(exerciceId, userId, prix),
    );
  }

  Future<Either<Failure, Unit>> _achatExercice(
    int exerciceId,
    String userId,
    int prix,
    Future<Unit> Function() fn,
  ) async {
    try {
      await fn();

      return const Right(unit);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }
}

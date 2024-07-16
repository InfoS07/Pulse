import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/error/failures.dart';

abstract interface class ExercicesRepository {
  Future<Either<Failure, Map<String, List<Exercice?>>>> getExercices();
  Future<Either<Failure, Map<String, List<Exercice?>>>> searchExercices(
      String searchTerm);
  Future<Either<Failure, Unit>> achatExercice(
      int exerciceId, String userId, int prix);
}

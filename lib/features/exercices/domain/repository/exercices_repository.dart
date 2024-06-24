import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/error/failures.dart';

abstract interface class ExercicesRepository {
  Future<Either<Failure, List<Exercice?>>> getExercices();
}

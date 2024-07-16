import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/exercices/domain/repository/exercices_repository.dart';

class AchatExercise implements UseCase<Unit, AchatExerciseParams> {
  final ExercicesRepository exercicesRepository;

  const AchatExercise(this.exercicesRepository);

  @override
  Future<Either<Failure, Unit>> call(AchatExerciseParams params) async {
    return await exercicesRepository.achatExercice(
      params.exerciceId,
      params.userId,
      params.prix,
    );
  }
}

class AchatExerciseParams {
  final int exerciceId;
  final String userId;
  final int prix;
  AchatExerciseParams({
    required this.exerciceId,
    required this.userId,
    required this.prix,
  });
}

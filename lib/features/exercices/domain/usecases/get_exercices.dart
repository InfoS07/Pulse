import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/exercices/domain/repository/exercices_repository.dart';

class GetExercices implements UseCase<List<Exercice?>, NoParams> {
  final ExercicesRepository exercicesRepository;

  const GetExercices(this.exercicesRepository);

  @override
  Future<Either<Failure, List<Exercice?>>> call(NoParams params) async {
    return await exercicesRepository.getExercices();
  }
}

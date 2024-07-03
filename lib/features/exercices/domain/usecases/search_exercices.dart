import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/exercices/domain/repository/exercices_repository.dart';

class SearchExercices
    implements UseCase<Map<String, List<Exercice?>>, SearchExercicesParams> {
  final ExercicesRepository repository;

  SearchExercices(this.repository);

  @override
  Future<Either<Failure, Map<String, List<Exercice?>>>> call(
      SearchExercicesParams params) async {
    return await repository.searchExercices(params.searchTerm, params.category);
  }
}

class SearchExercicesParams {
  final String searchTerm;
  final String? category;

  SearchExercicesParams(this.searchTerm, this.category);
}

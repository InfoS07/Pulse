import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/search_users/domain/repository/search_user_repository.dart';

class SearchUserUC implements UseCase<List<Profil?>, SearchUserParams> {
  final SearchUserRepository repository;

  SearchUserUC(this.repository);

  @override
  Future<Either<Failure, List<Profil?>>> call(SearchUserParams params) async {
    return await repository.searchUsers(params.searchTerm);
  }
}

class SearchUserParams {
  final String searchTerm;

  SearchUserParams(this.searchTerm);
}

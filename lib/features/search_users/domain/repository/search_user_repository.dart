import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/core/error/failures.dart';

abstract interface class SearchUserRepository {
  Future<Either<Failure, List<Profil?>>> searchUsers(String searchTerm);
}

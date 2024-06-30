//class UserLogin implements UseCase<User, UserLoginParams>

import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/profil/domain/repository/profil_repository.dart';

class GetFollowings implements UseCase<List<Profil>, String> {
  final ProfilRepository profilRepository;

  const GetFollowings(this.profilRepository);

  @override
  Future<Either<Failure, List<Profil>>> call(String userId) async {
    return await profilRepository.getFollowings(userId);
  }
}
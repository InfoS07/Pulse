//class UserLogin implements UseCase<User, UserLoginParams>

import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/profil/domain/repository/profil_repository.dart';
import 'package:pulse/features/profil_other/domain/repository/profil_other_repository.dart';

class OtherGetProfil implements UseCase<Profil, String> {
  final OtherProfilRepository profilRepository;

  const OtherGetProfil(this.profilRepository);

  @override
  Future<Either<Failure, Profil>> call(String userId) async {
    return await profilRepository.getProfil(userId);
  }
}

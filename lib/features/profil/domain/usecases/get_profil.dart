//class UserLogin implements UseCase<User, UserLoginParams>

import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/profil/domain/repository/profil_repository.dart';

class GetProfil implements UseCase<Profil, NoParams> {
  final ProfilRepository profilRepository;

  const GetProfil(this.profilRepository);

  @override
  Future<Either<Failure, Profil>> call(NoParams params) async {
    return await profilRepository.getProfil();
  }
}

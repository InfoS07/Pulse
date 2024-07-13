import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/profil/domain/repository/profil_repository.dart';

class UpdateProfil implements UseCase<Unit, UpdateUserParams> {
  final ProfilRepository repository;

  UpdateProfil(this.repository);

  @override
  Future<Either<Failure, Unit>> call(UpdateUserParams params) async {
    return await repository.updateUser(
      userId: params.userId,
      firstName: params.firstName,
      lastName: params.lastName,
      username: params.username,
      photo: params.photo,
    );
  }
}

class UpdateUserParams {
  final String userId;
  final String firstName;
  final String lastName;
  final String username;
  final XFile? photo;

  UpdateUserParams({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.username,
    this.photo,
  });
}

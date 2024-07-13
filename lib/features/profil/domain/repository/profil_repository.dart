import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/core/error/failures.dart';

abstract interface class ProfilRepository {
  Future<Either<Failure, Profil>> getProfil(String userId);
  Future<Either<Failure, List<Profil>>> getFollowers(String userId);
  Future<Either<Failure, List<Profil>>> getFollowings(String userId);
  Future<Either<Failure, Unit>> updateUser({
    required String userId,
    required String firstName,
    required String lastName,
    XFile? photo,
  });
}

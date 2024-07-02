import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/core/error/failures.dart';

abstract interface class ProfilRepository {
  Future<Either<Failure, Profil>> getProfil(String userId);
  Future<Either<Failure, List<Profil>>> getFollowers(String userId);
  Future<Either<Failure, List<Profil>>> getFollowings(String userId);
}

import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/core/error/failures.dart';

abstract interface class ProfilFollowRepository {
  Future<Either<Failure, void>> follow(String userId,String followerId);
  Future<Either<Failure, void>> unfollow(String userId,String followerId);
}

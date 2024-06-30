//class UserLogin implements UseCase<User, UserLoginParams>

import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/profil/domain/repository/profil_repository.dart';
import 'package:pulse/features/profil_follow/domain/repository/profil_follow_repository.dart';

class Unfollow implements UseCase<void, UnfollowParams> {
  final ProfilFollowRepository profilFollowRepository;

  const Unfollow(this.profilFollowRepository);

  @override
  Future<Either<Failure, void>> call(UnfollowParams params) async {
    return await profilFollowRepository.unfollow(params.userId,params.followerId);
  }
}

class UnfollowParams {
  final String userId;
  final String followerId;

  UnfollowParams({required this.userId, required this.followerId});
}
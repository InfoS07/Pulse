//class UserLogin implements UseCase<User, UserLoginParams>

import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/profil/domain/repository/profil_repository.dart';
import 'package:pulse/features/profil_follow/domain/repository/profil_follow_repository.dart';

class Follow implements UseCase<void, FollowParams> {
  final ProfilFollowRepository profilFollowRepository;

  const Follow(this.profilFollowRepository);

  @override
  Future<Either<Failure, void>> call(FollowParams params) async {
    return await profilFollowRepository.follow(params.userId,params.followerId);
  }
}

class FollowParams {
  final String userId;
  final String followerId;

  FollowParams({required this.userId, required this.followerId});
}
import 'package:pulse/core/common/entities/profil.dart';

class ProfilFollowArguments {
  final List<Profil> followers;
  final List<Profil> followings;

  ProfilFollowArguments({
    required this.followers,
    required this.followings,
  });
}

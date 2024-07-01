part of 'profil_other_bloc.dart';

@immutable
abstract class OtherProfilEvent {}


class OtherProfilGetProfil extends OtherProfilEvent {
  final String userId;

  OtherProfilGetProfil(this.userId);
  
}

class OtherProfilGetFollowers extends OtherProfilEvent {
  final String userId;

  OtherProfilGetFollowers(this.userId);
  
}

class OtherProfilGetFollowings extends OtherProfilEvent {
  final String userId;

  OtherProfilGetFollowings(this.userId);
  
}

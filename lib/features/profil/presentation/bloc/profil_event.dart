part of 'profil_bloc.dart';

abstract class ProfilEvent {}

class ProfilGetProfil extends ProfilEvent {
  final String userId;

  ProfilGetProfil(this.userId);
}

class ProfilGetFollowers extends ProfilEvent {
  final String userId;

  ProfilGetFollowers(this.userId);
}

class ProfilGetFollowings extends ProfilEvent {
  final String userId;

  ProfilGetFollowings(this.userId);
}

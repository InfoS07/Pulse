part of 'profil_follow_bloc.dart';

@immutable
abstract class ProfilFollowEvent {}

class ProfilFollow extends ProfilFollowEvent {
  final FollowParams params;
  ProfilFollow(this.params);
  
}

class ProfilUnfollow extends ProfilFollowEvent {
  final UnfollowParams params;
  ProfilUnfollow(this.params);
  
}


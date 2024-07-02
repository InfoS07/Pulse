part of 'profil_follow_bloc.dart';

@immutable
sealed class ProfilFollowState {
  const ProfilFollowState();
}

final class ProfilFollowInitial extends ProfilFollowState {}

final class ProfilFollowLoading extends ProfilFollowState {}

final class ProfilFollowSuccess extends ProfilFollowState {
  const ProfilFollowSuccess();
}

final class ProfilUnfollowSuccess extends ProfilFollowState {
  const ProfilUnfollowSuccess();
}



final class ProfilFollowFailure extends ProfilFollowState {
  final String message;
  const ProfilFollowFailure(this.message);
}

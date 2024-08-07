part of 'profil_bloc.dart';

sealed class ProfilState {
  const ProfilState();
}

final class ProfilInitial extends ProfilState {}

final class ProfilLoading extends ProfilState {}

final class ProfilSuccess extends ProfilState {
  final Profil profil;
  final List<Profil> followers;
  final List<Profil> followings;
  const ProfilSuccess(this.profil, this.followers, this.followings);
}

final class ProfilFailure extends ProfilState {
  final String message;
  const ProfilFailure(this.message);
}

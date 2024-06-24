part of 'profil_bloc.dart';

@immutable
sealed class ProfilState {
  const ProfilState();
}

final class ProfilInitial extends ProfilState {}

final class ProfilLoading extends ProfilState {}

final class ProfilSuccess extends ProfilState {
  final Profil profil;
  const ProfilSuccess(this.profil);
}

final class ProfilFailure extends ProfilState {
  final String message;
  const ProfilFailure(this.message);
}

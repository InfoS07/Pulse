part of 'profil_other_bloc.dart';

@immutable
sealed class OtherProfilState {
  const OtherProfilState();
}

final class OtherProfilInitial extends OtherProfilState {}

final class OtherProfilLoading extends OtherProfilState {}

final class OtherProfilSuccess extends OtherProfilState {
  final Profil profil;
  final List<Profil> followers;
  final List<Profil> followings;
  final List<TrainingList> trainings;
  const OtherProfilSuccess(this.profil,this.followers,this.followings,this.trainings);
}

final class OtherProfilFailure extends OtherProfilState {
  final String message;
  const OtherProfilFailure(this.message);
}

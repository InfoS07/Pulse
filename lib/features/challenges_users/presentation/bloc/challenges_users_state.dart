part of 'challenges_users_bloc.dart';

@immutable
sealed class ChallengesUsersState {
  const ChallengesUsersState();

  @override
  List<Object> get props => [];
}

final class ChallengesUsersInitial extends ChallengesUsersState {}

final class ChallengesUsersLoading extends ChallengesUsersState {}

final class ChallengesUsersSuccess extends ChallengesUsersState {
  final List<ChallengeUserModel?> challenges;
  const ChallengesUsersSuccess(this.challenges);
}

final class ChallengesUsersEmpty extends ChallengesUsersState {}

final class ChallengesUsersError extends ChallengesUsersState {
  final String message;

  ChallengesUsersError(this.message);
}

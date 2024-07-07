part of 'challenges_users_bloc.dart';

@immutable
sealed class ChallengesUsersEvent {}

final class ChallengesUsersLoad extends ChallengesUsersEvent {}

class ChallengesUsersGetChallenges extends ChallengesUsersEvent {
  ChallengesUsersGetChallenges();
}


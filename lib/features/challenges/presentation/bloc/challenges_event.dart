part of 'challenges_bloc.dart';

@immutable
sealed class ChallengesEvent {}

final class ChallengesLoad extends ChallengesEvent {}

class ChallengesGetChallenges extends ChallengesEvent {
  ChallengesGetChallenges();
}

class JoinChallenge extends ChallengesEvent {
  final int challengeId;
  final String userId;

  JoinChallenge(this.challengeId, this.userId);
}

class QuitChallenge extends ChallengesEvent {
  final int challengeId;
  final String userId;

  QuitChallenge(this.challengeId, this.userId);
}

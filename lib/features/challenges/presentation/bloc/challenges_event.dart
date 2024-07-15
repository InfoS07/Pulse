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

class FinishChallenge extends ChallengesEvent {
  final int challengeId;
  final String userId;
  final int pointsGagnes;

  FinishChallenge(this.challengeId, this.userId,this.pointsGagnes);
}

class AchatExercice extends ChallengesEvent {
  final int exerciceId;
  final String userId;
  final int prix;

  AchatExercice(this.exerciceId, this.userId,this.prix);
}

class QuitChallenge extends ChallengesEvent {
  final int challengeId;
  final String userId;

  QuitChallenge(this.challengeId, this.userId);
}

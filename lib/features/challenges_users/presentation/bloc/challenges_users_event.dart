part of 'challenges_users_bloc.dart';

@immutable
sealed class ChallengesUsersEvent {}

final class ChallengesUsersLoad extends ChallengesUsersEvent {}

class ChallengesUsersGetChallenges extends ChallengesUsersEvent {
  ChallengesUsersGetChallenges();
}

class JoinChallengeEvent extends ChallengesUsersEvent {
  final int challengeId;
  final String userId;

  JoinChallengeEvent(this.challengeId, this.userId);

  @override
  List<Object> get props => [challengeId, userId];
}

class QuitChallengeEvent extends ChallengesUsersEvent {
  final int challengeId;
  final String userId;

  QuitChallengeEvent(this.challengeId, this.userId);

  @override
  List<Object> get props => [challengeId, userId];
}

class DeleteChallengeEvent extends ChallengesUsersEvent {
  final int challengeId;
  DeleteChallengeEvent(this.challengeId);
}

class CreateChallengeEvent extends ChallengesUsersEvent {
  final String challengeName;
  final String description;
  final DateTime endDate;
  final DateTime createdAt;
  final int trainingId;
  final String authorId;
  final String type;
  final List<String> invites;
  final Map<String, Map<String, dynamic>> participant;

  CreateChallengeEvent({
    required this.challengeName,
    required this.description,
    required this.endDate,
    required this.createdAt,
    required this.trainingId,
    required this.authorId,
    required this.type,
    required this.invites,
    required this.participant,
  });

  @override
  List<Object?> get props => [
    challengeName,
    description,
    endDate,
    trainingId,
    authorId,
    type,
    invites,
    createdAt,
    participant
  ];
}

class AddInvitesToChallengeEvent extends ChallengesUsersEvent {
  final int challengeId;
  final List<String> userIds;

  AddInvitesToChallengeEvent(this.challengeId, this.userIds);
}






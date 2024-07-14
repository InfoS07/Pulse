part of 'challenges_bloc.dart';

@immutable
sealed class ChallengesState {
  const ChallengesState();

  @override
  List<Object> get props => [];
}

final class ChallengesInitial extends ChallengesState {}

final class ChallengesLoading extends ChallengesState {}

final class ChallengesSuccess extends ChallengesState {
  final List<ChallengesModel?> challenges;
  const ChallengesSuccess(this.challenges);
}

final class ChallengesError extends ChallengesState {
  final String message;

  ChallengesError(this.message);
}

final class ChallengesEmpty extends ChallengesState {}

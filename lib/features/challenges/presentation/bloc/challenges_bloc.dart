import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/challenges/domain/models/challenges_model.dart';
import 'package:pulse/features/challenges/domain/repository/challenges_repository.dart';
import 'package:pulse/features/challenges/domain/usecases/get_challenges.dart';
import 'package:pulse/features/exercices/domain/usecases/get_exercices.dart';
import 'package:pulse/features/exercices/domain/usecases/search_exercices.dart';

part 'challenges_event.dart';
part 'challenges_state.dart';

class ChallengesBloc extends Bloc<ChallengesEvent, ChallengesState> {
  final GetChallenges _getChallenges;
  final ChallengesRepository _challengesRepository;

  ChallengesBloc({
    required GetChallenges getChallenges,
    required ChallengesRepository challengesRepository,
  })  : _getChallenges = getChallenges,
        _challengesRepository = challengesRepository,
        super(ChallengesInitial()) {
    on<ChallengesGetChallenges>(_onGetChallenges);
    on<JoinChallenge>(_onJoinChallenge);
    on<QuitChallenge>(_onQuitChallenge);
    on<FinishChallenge>(_onFinishChallenge);
  }

  void _onGetChallenges(
    ChallengesGetChallenges event,
    Emitter<ChallengesState> emit,
  ) async {
    emit(ChallengesLoading());
    final res = await _getChallenges(NoParams());

    res.fold(
      (l) => emit(ChallengesError(l.message)),
      (r) => emit(ChallengesSuccess(r)),
    );
  }

  void _onFinishChallenge(
    FinishChallenge event,
    Emitter<ChallengesState> emit,
  ) async {
    final currentState = state;
    if (currentState is ChallengesSuccess) {
      final result = await _challengesRepository.finishChallenge(
          event.challengeId, event.userId, event.pointsGagnes);
      result.fold(
        (l) => emit(ChallengesError(l.message)),
        (r) {
          if (currentState.challenges.isEmpty)
            return;
          else {
            final updatedChallenges = currentState.challenges
                .map((challenge) => challenge!.id == event.challengeId
                    ? challenge!.copyWith(participants: [
                        ...challenge.participants!,
                        event.userId
                      ])
                    : challenge)
                .toList();
            emit(ChallengesSuccess(updatedChallenges));
          }
        } /* => add(ChallengesGetChallenges()) */,
      );
    }
  }

  void _onJoinChallenge(
    JoinChallenge event,
    Emitter<ChallengesState> emit,
  ) async {
    final currentState = state;
    if (currentState is ChallengesSuccess) {
      final result = await _challengesRepository.joinChallenge(
          event.challengeId, event.userId);
      result.fold(
        (l) => emit(ChallengesError(l.message)),
        (r) {
          if (currentState.challenges.isEmpty)
            return;
          else {
            final updatedChallenges = currentState.challenges
                .map((challenge) => challenge!.id == event.challengeId
                    ? challenge!.copyWith(participants: [
                        ...challenge.participants!,
                        event.userId
                      ])
                    : challenge)
                .toList();
            emit(ChallengesSuccess(updatedChallenges));
          }
        },
      );
    }
  }

  void _onQuitChallenge(
    QuitChallenge event,
    Emitter<ChallengesState> emit,
  ) async {
    final currentState = state;
    if (currentState is ChallengesSuccess) {
      final result = await _challengesRepository.quitChallenge(
          event.challengeId, event.userId);
      result.fold(
        (l) => emit(ChallengesError(l.message)),
        (r) {
          if (currentState.challenges.isEmpty)
            return;
          else {
            final updatedChallenges = currentState.challenges
                .map((challenge) => challenge!.id == event.challengeId
                    ? challenge!.copyWith(
                        participants: challenge.participants!
                            .where((element) => element != event.userId)
                            .toList())
                    : challenge)
                .toList();
            emit(ChallengesSuccess(updatedChallenges));
          }
        } /* => add(ChallengesGetChallenges()) */,
      );
    }
  }
}

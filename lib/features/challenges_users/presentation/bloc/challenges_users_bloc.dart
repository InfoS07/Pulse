import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/challenges/domain/models/challenges_model.dart';
import 'package:pulse/features/challenges/domain/repository/challenges_repository.dart';
import 'package:pulse/features/challenges/domain/usecases/get_challenges.dart';
import 'package:pulse/features/challenges_users/domain/models/challenges_users_model.dart';
import 'package:pulse/features/challenges_users/domain/repository/challenges_users_repository.dart';
import 'package:pulse/features/challenges_users/domain/usecases/get_challenges_users.dart';
import 'package:pulse/features/exercices/domain/usecases/get_exercices.dart';
import 'package:pulse/features/exercices/domain/usecases/search_exercices.dart';

part 'challenges_users_event.dart';
part 'challenges_users_state.dart';

class ChallengesUsersBloc extends Bloc<ChallengesUsersEvent, ChallengesUsersState> {
  final GetChallengeUsers _getChallengesUsers;
  final ChallengeUserRepository _challengesUsersRepository;

  ChallengesUsersBloc({
    required GetChallengeUsers getChallengesUsers,
    required ChallengeUserRepository challengesUsersRepository,
  })  : _getChallengesUsers = getChallengesUsers,
        _challengesUsersRepository = challengesUsersRepository,
        super(ChallengesUsersInitial()) {
    on<ChallengesUsersGetChallenges>(_onGetUsersChallenges);
  }

  void _onGetUsersChallenges(
    ChallengesUsersGetChallenges event,
    Emitter<ChallengesUsersState> emit,
  ) async {
    emit(ChallengesUsersLoading());
    final res = await _getChallengesUsers(NoParams());

    res.fold(
      (l) => emit(ChallengesUsersError(l.message)),
      (r) => emit(ChallengesUsersSuccess(r)),
    );
  }

}

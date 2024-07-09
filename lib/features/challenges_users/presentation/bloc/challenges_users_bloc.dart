import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/challenges/domain/models/challenges_model.dart';
import 'package:pulse/features/challenges/domain/repository/challenges_repository.dart';
import 'package:pulse/features/challenges/domain/usecases/get_challenges.dart';
import 'package:pulse/features/challenges_users/data/datasources/challenges_users_remote_data_source.dart';
import 'package:pulse/features/challenges_users/domain/models/challenges_users_model.dart';
import 'package:pulse/features/challenges_users/domain/repository/challenges_users_repository.dart';
import 'package:pulse/features/challenges_users/domain/usecases/get_challenges_users.dart';
import 'package:pulse/features/exercices/domain/usecases/get_exercices.dart';
import 'package:pulse/features/exercices/domain/usecases/search_exercices.dart';
import 'package:pulse/features/list_trainings/domain/models/create_challenge_user.dart';

part 'challenges_users_event.dart';
part 'challenges_users_state.dart';

class ChallengesUsersBloc extends Bloc<ChallengesUsersEvent, ChallengesUsersState> {
  final ChallengesUsersRemoteDataSource remoteDataSource;

  ChallengesUsersBloc({required this.remoteDataSource}) : super(ChallengesUsersInitial()) {
    on<ChallengesUsersGetChallenges>(_onGetChallengesUsers);
    on<JoinChallengeEvent>(_onJoinChallenge);
    on<QuitChallengeEvent>(_onQuitChallenge);
    on<DeleteChallengeEvent>(_onDeleteChallenge);
    on<CreateChallengeEvent>(_onCreateChallenge); 
  }

  Future<void> _onGetChallengesUsers(ChallengesUsersGetChallenges event, Emitter<ChallengesUsersState> emit) async {
    emit(ChallengesUsersLoading());
    try {
      final challenges = await remoteDataSource.getChallengeUsers();
      emit(ChallengesUsersSuccess(challenges));
    } catch (_) {
      emit(ChallengesUsersError("error"));
    }
  }

  Future<void> _onJoinChallenge(JoinChallengeEvent event, Emitter<ChallengesUsersState> emit) async {
    try {
      await remoteDataSource.joinChallenge(event.challengeId, event.userId);
      add(ChallengesUsersGetChallenges());
    } catch (_) {
      emit(ChallengesUsersError("error"));
    }
  }

  Future<void> _onQuitChallenge(QuitChallengeEvent event, Emitter<ChallengesUsersState> emit) async {
    try {
      await remoteDataSource.quitChallenge(event.challengeId, event.userId);
      add(ChallengesUsersGetChallenges());
    } catch (_) {
      emit(ChallengesUsersError("error"));
    }
  }


  Future<void> _onDeleteChallenge(DeleteChallengeEvent event, Emitter<ChallengesUsersState> emit) async {
    try {
      await remoteDataSource.deleteChallenge(event.challengeId);
      add(ChallengesUsersGetChallenges());
    } catch (_) {
      emit(ChallengesUsersError("error"));
    }
  }

  Future<void> _onCreateChallenge(CreateChallengeEvent event, Emitter<ChallengesUsersState> emit) async {
    try {
      final createChallengeUser = CreateChallengeUser(
        challengeName: event.challengeName,
        description: event.description,
        endDate: event.endDate,
        trainingId: event.trainingId,
        authorId: event.authorId,
        type: event.type,
        invites: event.invites,
        createdAt: event.createdAt,
        participant: event.participant
      );

      await remoteDataSource.createChallenge(createChallengeUser);

      // Après la création réussie, récupérer la liste mise à jour des défis
      add(ChallengesUsersGetChallenges());
    } catch (_) {
      emit(ChallengesUsersError("Erreur lors de la création du défi"));
    }
  }
}

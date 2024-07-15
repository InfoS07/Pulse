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
import 'package:pulse/features/challenges_users/domain/usecases/watch_challenges_insert.dart';
import 'package:pulse/features/exercices/domain/usecases/get_exercices.dart';
import 'package:pulse/features/exercices/domain/usecases/search_exercices.dart';
import 'package:pulse/features/list_trainings/domain/models/create_challenge_user.dart';

part 'challenges_users_event.dart';
part 'challenges_users_state.dart';

class ChallengesUsersBloc
    extends Bloc<ChallengesUsersEvent, ChallengesUsersState> {
  final ChallengesUsersRemoteDataSource _remoteDataSource;
  //final WatchChallengesInsert _watchChallengesUseCase;

  ChallengesUsersBloc({
    required ChallengesUsersRemoteDataSource remoteDataSource,
    /* required WatchChallengesInsert watchChallengesUseCase */
  })  : //_watchChallengesUseCase = watchChallengesUseCase,
        _remoteDataSource = remoteDataSource,
        super(ChallengesUsersInitial()) {
    on<ChallengesUsersGetChallenges>(_onGetChallengesUsers);
    on<JoinChallengeEvent>(_onJoinChallenge);
    on<FinishChallengeUserEvent>(_onFinishChallengUser);
    on<QuitChallengeEvent>(_onQuitChallenge);
    on<DeleteChallengeEvent>(_onDeleteChallenge);
    on<CreateChallengeEvent>(_onCreateChallenge);
    on<AddInvitesToChallengeEvent>(_onAddInvitesToChallenge);
    on<StartListeningToChallengesEvent>(_onStartListeningToChallenges);
  }

  void _onStartListeningToChallenges(StartListeningToChallengesEvent event,
      Emitter<ChallengesUsersState> emit) {
    /*  _watchChallengesUseCase.listen((challenges) {
      // Émettre un état avec les nouveaux challenges
      emit(ChallengesUsersSuccess(challenges));
    }).onError((error) {
      emit(ChallengesUsersError(error.toString()));
    }); */
  }

  Future<void> _onGetChallengesUsers(ChallengesUsersGetChallenges event,
      Emitter<ChallengesUsersState> emit) async {
    emit(ChallengesUsersLoading());
    try {
      final challenges = await _remoteDataSource.getChallengeUsers();
      emit(ChallengesUsersSuccess(challenges));
    } catch (_) {
      emit(ChallengesUsersError("error"));
    }
  }

  Stream<ChallengesUsersState> mapEventToState(ChallengesUsersEvent event) {
    throw UnimplementedError();
  }

  Future<void> _onJoinChallenge(
      JoinChallengeEvent event, Emitter<ChallengesUsersState> emit) async {
    try {
      await _remoteDataSource.joinChallenge(event.challengeId, event.userId);
      add(ChallengesUsersGetChallenges());
    } catch (_) {
      emit(ChallengesUsersError("error"));
    }
  }

    Future<void> _onFinishChallengUser(
      FinishChallengeUserEvent event, Emitter<ChallengesUsersState> emit) async {
    try {
      await _remoteDataSource.finishChallengeUser(event.challengeId, event.userId,event.score);
      add(ChallengesUsersGetChallenges());
    } catch (_) {
      emit(ChallengesUsersError("error"));
    }
  }

  Future<void> _onQuitChallenge(
      QuitChallengeEvent event, Emitter<ChallengesUsersState> emit) async {
    try {
      await _remoteDataSource.quitChallenge(event.challengeId, event.userId);
      add(ChallengesUsersGetChallenges());
    } catch (_) {
      emit(ChallengesUsersError("error"));
    }
  }

  Future<void> _onDeleteChallenge(
      DeleteChallengeEvent event, Emitter<ChallengesUsersState> emit) async {
    try {
      await _remoteDataSource.deleteChallenge(event.challengeId);
      add(ChallengesUsersGetChallenges());
    } catch (_) {
      emit(ChallengesUsersError("error"));
    }
  }

  Future<void> _onCreateChallenge(
      CreateChallengeEvent event, Emitter<ChallengesUsersState> emit) async {
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
          participant: event.participant);

      await _remoteDataSource.createChallenge(createChallengeUser);

      add(ChallengesUsersGetChallenges());
    } catch (_) {
      emit(ChallengesUsersError("Erreur lors de la création du défi"));
    }
  }

  Future<void> _onAddInvitesToChallenge(AddInvitesToChallengeEvent event,
      Emitter<ChallengesUsersState> emit) async {
    try {
      await _remoteDataSource.addInvitesToChallenge(
          event.challengeId, event.userIds);
      add(ChallengesUsersGetChallenges());
    } catch (_) {
      emit(ChallengesUsersError("Erreur lors de l'ajout des invitations"));
    }
  }
}

part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();

  final supabase = await Supabase.initialize(
      url: AppSecrets.supabaseUrl, anonKey: AppSecrets.supabaseAnonKey);

  serviceLocator.registerLazySingleton(() => supabase.client);

  final graphQLService = GraphQLService(AppSecrets.apiGraphqlUrl);

  serviceLocator.registerLazySingleton<GraphQLService>(() => graphQLService);

  serviceLocator.registerFactory(() => InternetConnection());

  serviceLocator.registerLazySingleton(
    () => AppUserCubit(),
  );
  serviceLocator.registerFactory<ConnectionChecker>(
    () => ConnectionCheckerImpl(
      serviceLocator(),
    ),
  );

  serviceLocator
      .registerSingleton<AppRouterListenable>(appRouterListenableProvider);

  serviceLocator.registerSingleton<GoRouter>(goRouterProvider);

  _initHome();
  _initProfil();
  _initExercices();
  _initActivity();
  _initOtherProfil();
  _initProfileFollower();
  _initTrainingList();
  _initChallenges();
  _initChallengesUsers();
  _initSearchUser();
  _initComments();
}

void _initAuth() {
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    // Repository
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    // Usecases
    ..registerFactory(
      () => UserSignUp(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserLogin(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => CurrentUser(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => SignOut(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserResetPassword(
        serviceLocator(),
      ),
    )
    // Bloc
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userLogin: serviceLocator(),
        currentUser: serviceLocator(),
        signOut: serviceLocator(),
        userResetPassword: serviceLocator(),
        appUserCubit: serviceLocator(),
      ),
    );
}

void _initHome() {
  serviceLocator
    ..registerFactory<PostsRemoteDataSource>(
      () => PostsRemoteDataSourceImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    // Repository
    ..registerFactory<PostsRepository>(
      () => PostsRepositoryImpl(
        serviceLocator(),
      ),
    )
    // Usecases
    ..registerFactory(
      () => GetPostsUC(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => LikePostUc(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => DeletePostUc(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => AddCommentUc(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => ReportCommentUc(
        serviceLocator(),
      ),
    )
    // Bloc
    ..registerLazySingleton(
      () => HomeBloc(
        getPosts: serviceLocator(),
        likePost: serviceLocator(),
        deletePost: serviceLocator(),
        addCommentUc: serviceLocator(),
        reportComment: serviceLocator(),
        //getPosts: serviceLocator(),
      ),
    );
}

void _initProfil() {
  serviceLocator
    ..registerFactory<ProfilRemoteDataSource>(
      () => ProfilRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    // Repository
    ..registerFactory<ProfilRepository>(
      () => ProfilRepositoryImpl(
        serviceLocator(),
      ),
    )
    // Usecases
    ..registerFactory(
      () => GetProfil(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetFollowers(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetFollowings(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UpdateProfil(
        serviceLocator(),
      ),
    )
    // Bloc
    ..registerLazySingleton(
      () => ProfilBloc(
        getProfil: serviceLocator(),
        getFollowers: serviceLocator(),
        getFollowings: serviceLocator(),
        updateProfil: serviceLocator(),
      ),
    );
}

void _initProfileFollower() {
  serviceLocator
    ..registerFactory<ProfilFollowRemoteDataSource>(
      () => ProfilFollowRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    // Repository
    ..registerFactory<ProfilFollowRepository>(
      () => ProfilFollowRepositoryImpl(
        serviceLocator(),
      ),
    )
    // Usecases
    ..registerFactory(
      () => Follow(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => Unfollow(
        serviceLocator(),
      ),
    )
    // Bloc
    ..registerLazySingleton(
      () => ProfilFollowBloc(
        follow: serviceLocator(),
        unfollow: serviceLocator(),
      ),
    );
}

void _initTrainingList() {
  serviceLocator
    ..registerFactory<ListTrainingsRemoteDataSource>(
      () => ListTrainingsRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    // Repository
    ..registerFactory<ListTrainingsRepository>(
      () => ListTrainingsRepositoryImpl(
        serviceLocator(),
      ),
    )
    // Usecases
    ..registerFactory(
      () => GetTrainings(
        serviceLocator(),
      ),
    )
    // Bloc
    ..registerLazySingleton(
      () => ListTrainingsBloc(
        getTrainings: serviceLocator(),
      ),
    );
}

void _initChallenges() {
  serviceLocator
    ..registerFactory<ChallengesRemoteDataSource>(
      () => ChallengesRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    // Repository
    ..registerFactory<ChallengesRepository>(
      () => ChallengesRepositoryImpl(
        serviceLocator(),
      ),
    )
    // Usecases
    ..registerFactory(
      () => GetChallenges(
        serviceLocator(),
      ),
    )
    // Bloc
    ..registerLazySingleton(
      () => ChallengesBloc(
        getChallenges: serviceLocator(),
        challengesRepository: serviceLocator(),
      ),
    );
}

void _initChallengesUsers() {
  serviceLocator
    ..registerFactory<ChallengesUsersRemoteDataSource>(
      () => ChallengeUserRemoteDataSourceImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    // Repository
    ..registerFactory<ChallengeUserRepository>(
      () => ChallengeUserRepositoryImpl(
        serviceLocator(),
      ),
    )
    // Usecases
    ..registerFactory(
      () => GetChallengeUsersUc(
        serviceLocator(),
      ),
    )
    // Bloc
    ..registerLazySingleton(
      () => ChallengesUsersBloc(
        remoteDataSource: serviceLocator(),
      ),
    );
}

void _initOtherProfil() {
  serviceLocator
    ..registerFactory<OtherProfilRemoteDataSource>(
      () => OtherProfilRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    // Repository
    ..registerFactory<OtherProfilRepository>(
      () => OtherProfilRepositoryImpl(
        serviceLocator(),
      ),
    )
    // Usecases
    ..registerFactory(
      () => OtherGetProfil(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => OtherGetFollowers(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => OtherGetFollowings(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => OtherGetTrainings(
        serviceLocator(),
      ),
    )
    // Bloc
    ..registerLazySingleton(
      () => OtherProfilBloc(
        getProfil: serviceLocator(),
        getFollowers: serviceLocator(),
        getFollowings: serviceLocator(),
        getTrainings: serviceLocator(),
      ),
    );
}

void _initExercices() {
  serviceLocator
    ..registerFactory<ExercicesRemoteDataSource>(
      () => ExercicesRemoteDataSourceImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    // Repository
    ..registerFactory<ExercicesRepository>(
      () => ExercicesRepositoryImpl(
        serviceLocator(),
      ),
    )
    // Usecases
    ..registerFactory(
      () => GetExercices(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => SearchExercices(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => AchatExercise(
        serviceLocator(),
      ),
    )
    // Bloc
    ..registerLazySingleton(
      () => ExercicesBloc(
        getExercices: serviceLocator(),
        searchExercices: serviceLocator(),
        achatExercise: serviceLocator(),
      ),
    );
}

void _initActivity() {
  serviceLocator
    ..registerFactory<ActivityLocalDataSource>(
      () => ActivityLocalDataSourceImpl(),
    )
    ..registerFactory<ActivityRemoteDataSource>(
      () => ActivityRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    // Repository
    ..registerFactory<ActivityRepository>(
      () => ActivityRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    // Usecases
    ..registerFactory(
      () => CreateActivityUC(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => SaveActivityUC(
        serviceLocator(),
      ),
    )
    // Bloc
    ..registerLazySingleton(
      () => ActivityBloc(
        saveActivity: serviceLocator(),
        //createActivityUC: serviceLocator(),
      ),
    );
}

void _initSearchUser() {
  serviceLocator
    ..registerFactory<SearchUserRemoteDataSource>(
      () => SearchUserRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    // Repository
    ..registerFactory<SearchUserRepository>(
      () => SearchUserRepositoryImpl(
        serviceLocator(),
      ),
    )
    // Usecases
    ..registerFactory(
      () => SearchUserUC(
        serviceLocator(),
      ),
    )
    // Bloc
    ..registerLazySingleton(
      () => SearchUsersBloc(
        searchUser: serviceLocator(),
      ),
    );
}

void _initComments() {
  serviceLocator
    ..registerFactory<CommentsRemoteDataSource>(
      () => CommentsRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    // Repository
    ..registerFactory<CommentsRepository>(
      () => CommentsRepositoryImpl(
        serviceLocator(),
      ),
    )
    // Usecases
    ..registerFactory(
      () => GetCommentsUc(
        serviceLocator(),
      ),
    )
    // Bloc
    ..registerLazySingleton(
      () => CommentBloc(),
    );
}

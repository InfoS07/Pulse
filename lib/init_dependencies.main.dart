part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();

  final supabase = await Supabase.initialize(
      url: AppSecrets.supabaseUrl, anonKey: AppSecrets.supabaseAnonKey);

  serviceLocator.registerLazySingleton(() => supabase.client);

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
}

void _initAuth() {
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
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
    // Bloc
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userLogin: serviceLocator(),
        currentUser: serviceLocator(),
        signOut: serviceLocator(),
        appUserCubit: serviceLocator(),
      ),
    );
}

void _initHome() {
  serviceLocator
    ..registerFactory<PostsRemoteDataSource>(
      () => PostsRemoteDataSourceImpl(),
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
    // Bloc
    ..registerLazySingleton(
      () => HomeBloc(
        getPosts: serviceLocator(),
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
    // Bloc
    ..registerLazySingleton(
      () => ProfilBloc(
        getProfil: serviceLocator(),
      ),
    );
}

void _initExercices() {
  serviceLocator
    ..registerFactory<ExercicesRemoteDataSource>(
      () => ExercicesRemoteDataSourceImpl(
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
    // Bloc
    ..registerLazySingleton(
      () => ExercicesBloc(
        getExercices: serviceLocator(),
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

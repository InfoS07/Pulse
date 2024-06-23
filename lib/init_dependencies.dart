import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/core/network/connection_checker.dart';
import 'package:pulse/core/router/app_router.dart';
import 'package:pulse/core/router/app_router_listenable.dart';
import 'package:pulse/core/secrets/app_secrets.dart';
import 'package:pulse/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:pulse/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pulse/features/auth/domain/repository/auth_repository.dart';
import 'package:pulse/features/auth/domain/usecases/current_user.dart';
import 'package:pulse/features/auth/domain/usecases/user_login.dart';
import 'package:pulse/features/auth/domain/usecases/user_sign_up.dart';
import 'package:pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pulse/features/profil/data/datasources/profil_remote_data_source.dart';
import 'package:pulse/features/profil/data/repositories/profil_repository_impl.dart';
import 'package:pulse/features/profil/domain/repository/profil_repository.dart';
import 'package:pulse/features/profil/domain/usecases/get_profil.dart';
import 'package:pulse/features/profil/domain/usecases/signout.dart';
import 'package:pulse/features/profil/presentation/bloc/profil_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  _initProfil();
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

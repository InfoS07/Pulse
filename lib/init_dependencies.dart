import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/core/network/connection_checker.dart';
import 'package:pulse/core/router/app_router.dart';
import 'package:pulse/core/router/app_router_listenable.dart';
import 'package:pulse/core/secrets/app_secrets.dart';
import 'package:pulse/core/services/graphql_client.dart';
import 'package:pulse/features/activity/data/datasources/activity_local_data_source.dart';
import 'package:pulse/features/activity/data/datasources/activity_remote_data_source.dart';
import 'package:pulse/features/activity/data/repositories/activity_repository_impl.dart';
import 'package:pulse/features/activity/domain/repository/activity_repository.dart';
import 'package:pulse/features/activity/domain/usecases/create_activity_uc.dart';
import 'package:pulse/features/activity/domain/usecases/save_activity_uc.dart';
import 'package:pulse/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:pulse/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:pulse/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pulse/features/auth/domain/repository/auth_repository.dart';
import 'package:pulse/features/auth/domain/usecases/current_user.dart';
import 'package:pulse/features/auth/domain/usecases/user_login.dart';
import 'package:pulse/features/auth/domain/usecases/user_sign_up.dart';
import 'package:pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pulse/features/exercices/data/datasources/exercices_remote_data_source.dart';
import 'package:pulse/features/exercices/data/repositories/exercices_repository_impl.dart';
import 'package:pulse/features/exercices/domain/repository/exercices_repository.dart';
import 'package:pulse/features/exercices/domain/usecases/get_exercices.dart';
import 'package:pulse/features/exercices/presentation/bloc/exercices_bloc.dart';
import 'package:pulse/features/home/data/datasources/posts_remote_data_source.dart';
import 'package:pulse/features/home/data/repositories/posts_repository_impl.dart';
import 'package:pulse/features/home/domain/repository/posts_repository.dart';
import 'package:pulse/features/home/domain/usecases/get_posts_uc.dart';
import 'package:pulse/features/home/presentation/bloc/home_bloc.dart';
import 'package:pulse/features/profil/data/datasources/profil_remote_data_source.dart';
import 'package:pulse/features/profil/data/repositories/profil_repository_impl.dart';
import 'package:pulse/features/profil/domain/repository/profil_repository.dart';
import 'package:pulse/features/profil/domain/usecases/get_profil.dart';
import 'package:pulse/features/profil/domain/usecases/signout.dart';
import 'package:pulse/features/profil/presentation/bloc/profil_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

part 'init_dependencies.main.dart';

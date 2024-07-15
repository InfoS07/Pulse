import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/features/auth/presentation/bloc/auth_bloc.dart';

FutureOr<String?> appRouterRedirect(
    BuildContext context, GoRouterState state) async {
  final appUserCubit = context.read<AppUserCubit>();
  final authBlocState = context.read<AuthBloc>().state;
  final userState = appUserCubit.state;
  final isLoggingOut =
      userState is AppUserLoggedOut && state.matchedLocation == '/profil';
  final isLoggedIn = userState is AppUserLoggedIn;
  final isLoggingIn = state.matchedLocation == '/login';
  final isSignup = state.matchedLocation == '/signup';

  print('isSignup: $isSignup');
  print('authBlocState: $authBlocState');
  /* if (isSignup && authBlocState is AuthFailure) {
    return '/signup';
  } else {
    if (isLoggingOut) {
      return '/login';
    }
  } */

  if (isLoggedIn && isLoggingIn) {
    return '/home';
  }

  return null;
}

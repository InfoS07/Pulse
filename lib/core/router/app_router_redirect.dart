import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';

FutureOr<String?> appRouterRedirect(
    BuildContext context, GoRouterState state) async {
  final appUserCubit = context.read<AppUserCubit>();
  final userState = appUserCubit.state;
  final isLoggingOut =
      userState is AppUserLoggedOut && state.matchedLocation == '/profil';
  final isLoggedIn = userState is AppUserLoggedIn;
  final isLoggingIn = state.matchedLocation == '/login';

  print("userState: $userState");

  if (isLoggingOut) {
    return '/login';
  }
  if (isLoggedIn && isLoggingIn) {
    return '/home';
  }
  return null;
}

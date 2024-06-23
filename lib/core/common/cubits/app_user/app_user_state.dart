part of 'app_user_cubit.dart';

sealed class AppUserState {}

class AppUserInitial extends AppUserState {}

class AppUserChecking extends AppUserState {}

class AppUserLoggedIn extends AppUserState {
  final User user;
  AppUserLoggedIn(this.user);
}

class AppUserLoggedOut extends AppUserState {}

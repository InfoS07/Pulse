part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

final class AuthSignUp extends AuthEvent {
  final String email;
  final String password;
  final String username;
  final String firstName;
  final String lastName;

  AuthSignUp({
    required this.email,
    required this.password,
    required this.lastName,
    required this.firstName,
    required this.username,
  });
}

final class AuthLogin extends AuthEvent {
  final String email;
  final String password;

  AuthLogin({
    required this.email,
    required this.password,
  });
}

final class AuthIsUserLoggedIn extends AuthEvent {}

final class AuthSignOut extends AuthEvent {}

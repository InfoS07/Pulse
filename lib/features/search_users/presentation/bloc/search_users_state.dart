part of 'search_users_bloc.dart';

abstract class SearchUsersState extends Equatable {
  const SearchUsersState();

  @override
  List<Object> get props => [];
}

class SearchUsersInitial extends SearchUsersState {}

class SearchUsersLoading extends SearchUsersState {}

class SearchUsersLoaded extends SearchUsersState {
  final List<Profil?> profils;

  const SearchUsersLoaded(this.profils);

  @override
  List<Object> get props => [profils];
}

class SearchUsersError extends SearchUsersState {
  final String message;

  const SearchUsersError(this.message);

  @override
  List<Object> get props => [message];
}

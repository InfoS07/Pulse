part of 'search_users_bloc.dart';

abstract class SearchUsersEvent extends Equatable {
  const SearchUsersEvent();

  @override
  List<Object> get props => [];
}

class SearchUsersQueryChanged extends SearchUsersEvent {
  final String query;

  const SearchUsersQueryChanged({required this.query});

  @override
  List<Object> get props => [query];
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/core/common/entities/user.dart';
import 'package:pulse/features/search_users/domain/usecases/search_user_uc.dart';

part 'search_users_event.dart';
part 'search_users_state.dart';

class SearchUsersBloc extends Bloc<SearchUsersEvent, SearchUsersState> {
  final SearchUserUC _searchUser;

  SearchUsersBloc({required SearchUserUC searchUser})
      : _searchUser = searchUser,
        super(SearchUsersInitial()) {
    on<SearchUsersQueryChanged>(_onSearchUser);
  }

  void _onSearchUser(
    SearchUsersQueryChanged event,
    Emitter<SearchUsersState> emit,
  ) async {
    emit(SearchUsersLoading());
    final res = await _searchUser(SearchUserParams(event.query));

    res.fold(
      (l) => emit(SearchUsersError(l.message)),
      (r) => emit(SearchUsersLoaded(r)),
    );
  }
}

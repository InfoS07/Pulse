import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pulse/features/profil_follow/domain/usecases/follow.dart';
import 'package:pulse/features/profil_follow/domain/usecases/unfollow.dart';

part 'profil_follow_event.dart';
part 'profil_follow_state.dart';

class ProfilFollowBloc extends Bloc<ProfilFollowEvent, ProfilFollowState> {
  final Follow _follow;
  final Unfollow _unfollow;

  ProfilFollowBloc({
    required Follow follow,
    required Unfollow unfollow,
  })  : _follow = follow,
        _unfollow = unfollow,
        super(ProfilFollowInitial()) {
    on<ProfilFollow>(_onFollow);
    on<ProfilUnfollow>(_onUnfollow);
  }

  void _onFollow(
    ProfilFollow event,
    Emitter<ProfilFollowState> emit,
  ) async {
    emit(ProfilFollowLoading());
    final res = await _follow(event.params);
    res.fold(
      (l) => emit(ProfilFollowFailure(l.message)),
      (r) => emit(const ProfilFollowSuccess()),
    );
  }

  void _onUnfollow(
    ProfilUnfollow event,
    Emitter<ProfilFollowState> emit,
  ) async {
    emit(ProfilFollowLoading());
    final res = await _unfollow(event.params);
    res.fold(
      (l) => emit(ProfilFollowFailure(l.message)),
      (r) => emit(const ProfilFollowSuccess()),
    );
  }
}

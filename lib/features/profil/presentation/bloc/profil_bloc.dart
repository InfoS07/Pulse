import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/features/profil/domain/usecases/get_followers.dart';
import 'package:pulse/features/profil/domain/usecases/get_followings.dart';
import 'package:pulse/features/profil/domain/usecases/get_profil.dart';
import 'package:pulse/features/profil/domain/usecases/update_profil.dart';

part 'profil_event.dart';
part 'profil_state.dart';

class ProfilBloc extends Bloc<ProfilEvent, ProfilState> {
  final GetProfil _getProfil;
  final GetFollowers _getFollowers;
  final GetFollowings _getFollowings;
  final UpdateProfil _updateProfil;

  ProfilBloc({
    required GetProfil getProfil,
    required GetFollowers getFollowers,
    required GetFollowings getFollowings,
    required UpdateProfil updateProfil,
  })  : _getProfil = getProfil,
        _getFollowers = getFollowers,
        _getFollowings = getFollowings,
        _updateProfil = updateProfil,
        super(ProfilInitial()) {
    on<ProfilGetProfil>(_onGetProfil);
    on<ProfilUpdateProfil>(_onUpdateProfil);
  }

  void _onGetProfil(
    ProfilGetProfil event,
    Emitter<ProfilState> emit,
  ) async {
    emit(ProfilLoading());
    final res = await _getProfil(event.userId);
    final followersRes = await _getFollowers(event.userId);
    final followingsRes = await _getFollowings(
        event.userId); // Utilisation du userId passé dans l'événement

    res.fold(
      (l) => emit(ProfilFailure(l.message)),
      (r) {
        followersRes.fold((lf) => emit(ProfilFailure(lf.message)), (rf) {
          followingsRes.fold(
            (lff) => emit(ProfilFailure(lff.message)),
            (rff) => emit(ProfilSuccess(r, rf, rff)),
          );
        });
      },
    );
  }

  void _onUpdateProfil(
    ProfilUpdateProfil event,
    Emitter<ProfilState> emit,
  ) async {
    emit(ProfilLoading());
    final res = await _updateProfil(event.params);
    res.fold(
      (l) => emit(ProfilFailure(l.message)),
      (r) => add(ProfilGetProfil(event.params.userId)),
    );
  }
}

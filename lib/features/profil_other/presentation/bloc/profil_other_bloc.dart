import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/profil/domain/usecases/get_profil.dart';
import 'package:pulse/features/profil/domain/usecases/signout.dart';
import 'package:pulse/features/profil_other/domain/usecases/get_followers.dart';
import 'package:pulse/features/profil_other/domain/usecases/get_followings.dart';
import 'package:pulse/features/profil_other/domain/usecases/get_other_profil.dart';

part 'profil_other_event.dart';
part 'profil_other_state.dart';

class OtherProfilBloc extends Bloc<OtherProfilEvent, OtherProfilState> {
  final OtherGetProfil _getProfil;
  final OtherGetFollowers _getFollowers;
  final OtherGetFollowings _getFollowings;

  OtherProfilBloc({
    required OtherGetProfil getProfil,
    required OtherGetFollowers getFollowers,
    required OtherGetFollowings getFollowings,
  })  : _getProfil = getProfil,
        _getFollowers = getFollowers,
        _getFollowings = getFollowings,
        super(OtherProfilInitial()) {
    on<OtherProfilGetProfil>(_onGetProfil);
  }

  void _onGetProfil(
  OtherProfilGetProfil event,
  Emitter<OtherProfilState> emit,
) async {
  emit(OtherProfilLoading());
  final res = await _getProfil(event.userId);
  final followersRes = await _getFollowers(event.userId); 
  final followingsRes = await _getFollowings(event.userId); // Utilisation du userId passé dans l'événement

    res.fold(
      (l) => emit(OtherProfilFailure(l.message)),
      (r) {
        followersRes.fold(
          (lf) => emit(OtherProfilFailure(lf.message)),
          (rf) {
            followingsRes.fold(
              (lff) => emit(OtherProfilFailure(lff.message)),
              (rff) => emit(OtherProfilSuccess(r, rf,rff)),
            );
          } 
        );
      },
    );
}
}

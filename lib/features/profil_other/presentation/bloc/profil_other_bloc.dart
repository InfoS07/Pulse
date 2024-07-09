import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/core/common/entities/trainingList.dart';
import 'package:pulse/features/profil_other/domain/usecases/get_followers.dart';
import 'package:pulse/features/profil_other/domain/usecases/get_followings.dart';
import 'package:pulse/features/profil_other/domain/usecases/get_other_profil.dart';
import 'package:pulse/features/profil_other/domain/usecases/get_trainings.dart';

part 'profil_other_event.dart';
part 'profil_other_state.dart';

class OtherProfilBloc extends Bloc<OtherProfilEvent, OtherProfilState> {
  final OtherGetProfil _getProfil;
  final OtherGetFollowers _getFollowers;
  final OtherGetFollowings _getFollowings;
  final OtherGetTrainings _getTrainings;

  OtherProfilBloc({
    required OtherGetProfil getProfil,
    required OtherGetFollowers getFollowers,
    required OtherGetFollowings getFollowings,
    required OtherGetTrainings getTrainings,
  })  : _getProfil = getProfil,
        _getFollowers = getFollowers,
        _getFollowings = getFollowings,
        _getTrainings = getTrainings,
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
    final followingsRes = await _getFollowings(event.userId);
    final trainingsRes = await _getTrainings(
        event.userId); // Utilisation du userId passé dans l'événement

    res.fold(
      (l) => emit(OtherProfilFailure(l.message)),
      (r) {
        followersRes.fold((lf) => emit(OtherProfilFailure(lf.message)), (rf) {
          followingsRes.fold((lff) => emit(OtherProfilFailure(lff.message)),
              (rff) {
            trainingsRes.fold(
              (lfff) => emit(OtherProfilFailure(lfff.message)),
              (rfff) => emit(OtherProfilSuccess(r, rf, rff, rfff)),
            );
          });
        });
      },
    );
  }
}

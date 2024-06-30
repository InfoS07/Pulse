import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/profil/domain/usecases/get_profil.dart';
import 'package:pulse/features/profil/domain/usecases/signout.dart';
import 'package:pulse/features/profil_other/domain/usecases/get_other_profil.dart';

part 'profil_other_event.dart';
part 'profil_other_state.dart';

class OtherProfilBloc extends Bloc<OtherProfilEvent, OtherProfilState> {
  final OtherGetProfil _getProfil;

  OtherProfilBloc({
    required OtherGetProfil getProfil,
  })  : _getProfil = getProfil,
        super(OtherProfilInitial()) {
    on<OtherProfilGetProfil>(_onGetProfil);
  }

  void _onGetProfil(
    OtherProfilGetProfil event,
    Emitter<OtherProfilState> emit,
  ) async {
    emit(OtherProfilLoading());
    final res = await _getProfil(NoParams());

    res.fold(
      (l) => emit(OtherProfilFailure(l.message)),
      (r) => emit(OtherProfilSuccess(r)),
    );
  }
}

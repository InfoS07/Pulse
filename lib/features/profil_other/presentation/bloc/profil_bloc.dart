import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/profil/domain/usecases/get_profil.dart';
import 'package:pulse/features/profil/domain/usecases/signout.dart';

part 'profil_event.dart';
part 'profil_state.dart';

class ProfilBloc extends Bloc<ProfilEvent, ProfilState> {
  final GetProfil _getProfil;

  ProfilBloc({
    required GetProfil getProfil,
  })  : _getProfil = getProfil,
        super(ProfilInitial()) {
    on<ProfilGetProfil>(_onGetProfil);
  }

  void _onGetProfil(
    ProfilGetProfil event,
    Emitter<ProfilState> emit,
  ) async {
    emit(ProfilLoading());
    final res = await _getProfil(NoParams());

    res.fold(
      (l) => emit(ProfilFailure(l.message)),
      (r) => emit(ProfilSuccess(r)),
    );
  }
}

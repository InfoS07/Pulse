import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/exercices/domain/usecases/get_exercices.dart';

part 'exercices_event.dart';
part 'exercices_state.dart';

class ExercicesBloc extends Bloc<ExercicesEvent, ExercicesState> {
  final GetExercices _getExercices;

  ExercicesBloc({required GetExercices getExercices})
      : _getExercices = getExercices,
        super(ExercicesInitial()) {
    on<ExercicesLoad>(_onGetExercices);
  }

  void _onGetExercices(
    ExercicesLoad event,
    Emitter<ExercicesState> emit,
  ) async {
    emit(ExercicesLoading());
    final res = await _getExercices(NoParams());

    res.fold(
      (l) => emit(ExercicesError(l.message)),
      (r) => emit(ExercicesLoaded(r)),
    );
  }
}

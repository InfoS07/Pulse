import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/exercices/domain/usecases/get_exercices.dart';
import 'package:pulse/features/exercices/domain/usecases/search_exercices.dart';

part 'exercices_event.dart';
part 'exercices_state.dart';

class ExercicesBloc extends Bloc<ExercicesEvent, ExercicesState> {
  final GetExercices _getExercices;
  final SearchExercices _searchExercices;

  ExercicesBloc(
      {required GetExercices getExercices,
      required SearchExercices searchExercices})
      : _getExercices = getExercices,
        _searchExercices = searchExercices,
        super(ExercicesInitial()) {
    on<ExercicesLoad>(_onGetExercices);
    on<ExercicesSearch>(_onSearchExercices);
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

  void _onSearchExercices(
    ExercicesSearch event,
    Emitter<ExercicesState> emit,
  ) async {
    emit(ExercicesLoading());
    final res = await _searchExercices(
        SearchExercicesParams(event.searchTerm, event.category));

    res.fold(
      (l) => emit(ExercicesError(l.message)),
      (r) {
        if (r.isEmpty) {
          emit(ExercicesEmpty());
        } else {
          emit(ExercicesLoaded(r));
        }
      },
    );
  }
}

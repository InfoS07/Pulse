import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/exercices/domain/usecases/achat_exercise.dart';
import 'package:pulse/features/exercices/domain/usecases/get_exercices.dart';
import 'package:pulse/features/exercices/domain/usecases/search_exercices.dart';

part 'exercices_event.dart';
part 'exercices_state.dart';

class ExercicesBloc extends Bloc<ExercicesEvent, ExercicesState> {
  final GetExercices _getExercices;
  final SearchExercices _searchExercices;
  final AchatExercise _achatExercise;

  ExercicesBloc(
      {required GetExercices getExercices,
      required SearchExercices searchExercices,
      required AchatExercise achatExercise})
      : _getExercices = getExercices,
        _searchExercices = searchExercices,
        _achatExercise = achatExercise,
        super(ExercicesInitial()) {
    on<ExercicesLoad>(_onGetExercices);
    on<ExercicesSearch>(_onSearchExercices);
    on<AchatExercice>(_onAchatExercice);
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
    //emit(ExercicesLoading());
    final res = await _searchExercices(SearchExercicesParams(event.searchTerm));

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

  void _onAchatExercice(
    AchatExercice event,
    Emitter<ExercicesState> emit,
  ) async {
    final res = await _achatExercise(AchatExerciseParams(
        exerciceId: event.exerciceId, userId: event.userId, prix: event.prix));

    res.fold(
      (l) => emit(ExercicesError(l.message)),
      (r) => add(ExercicesLoad()),
    );
  }
}

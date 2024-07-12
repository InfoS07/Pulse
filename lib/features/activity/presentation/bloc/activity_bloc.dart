import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulse/core/common/entities/activity.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/common/entities/training.dart';
import 'package:pulse/features/activity/domain/usecases/save_activity_uc.dart';

part 'activity_event.dart';
part 'activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final SaveActivityUC _saveActivityUC;

  ActivityBloc({required SaveActivityUC saveActivity})
      : _saveActivityUC = saveActivity,
        super(ActivityInitial(Exercice.empty())) {
    on<StartActivity>(_onStartActivity);
    on<UpdateActivity>(_onUpdateActivity);
    on<StopActivity>(_onStopActivity);
    on<SaveActivity>(_onSaveActivity);
  }

  void _onStartActivity(
    StartActivity event,
    Emitter<ActivityState> emit,
  ) {
    final newActivity = Activity.empty(event.exercise).copyWith(
      id: 1,
      status: 'En cours',
      startAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
    emit(ActivityInProgress(newActivity));
  }

  void _onUpdateActivity(
    UpdateActivity event,
    Emitter<ActivityState> emit,
  ) {
    if (state is ActivityInProgress) {
      if (event.buzzerExpected != null &&
          event.buzzerPressed != null &&
          event.pressedAt != null) {
        final buzzerStats = ActivityStats(
          buzzerExpected: event.buzzerExpected!,
          buzzerPressed: event.buzzerPressed!,
          reactionTime: event.reactionTime!,
          pressedAt: event.pressedAt!,
        );
        final updatedActivity = state.activity.copyWith(
          caloriesBurned: event.caloriesBurned,
          endAt: DateTime.now(),
          timer: event.timeElapsed,
          touches: event.touches,
          misses: event.misses,
          stats: [...state.activity.stats, buzzerStats],
        );
        emit(ActivityInProgress(updatedActivity));
      } else {
        final updatedActivity = state.activity.copyWith(
          caloriesBurned: event.caloriesBurned,
          endAt: DateTime.now(),
          timer: event.timeElapsed,
          touches: event.touches,
          misses: event.misses,
        );
        emit(ActivityInProgress(updatedActivity));
      }
    }
  }

  void _onStopActivity(
    StopActivity event,
    Emitter<ActivityState> emit,
  ) {
    if (state is ActivityInProgress) {
      final currentState = state as ActivityInProgress;
      final stoppedActivity = currentState.activity.copyWith(
        status: 'Terminé',
        endAt: DateTime.now(),
        timer: event.timeElapsed,
      );
      emit(ActivityStopped(
          stoppedActivity, Training.empty(currentState.activity)));
    }
  }

  void _onSaveActivity(
    SaveActivity event,
    Emitter<ActivityState> emit,
  ) async {
    if (state is ActivityStopped || state is ActivitySavedError) {
      final training = Training(
        id: DateTime.now().millisecondsSinceEpoch,
        title: event.title,
        description: event.description,
        activity: state.activity,
        photos: event.photos,
      );

      final res = await _saveActivityUC(training);

      res.fold(
        (l) => emit(
            ActivitySavedError(l.message, state.activity, training, state)),
        (r) => emit(ActivitySaved(state.activity, r)),
      );
      //emit(ActivitySaved(currentState.activity, training));
    }
  }
}

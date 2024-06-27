import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:pulse/core/common/entities/activity.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/common/entities/training.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/activity/domain/usecases/create_activity_uc.dart';
import 'package:pulse/features/activity/domain/usecases/save_activity_uc.dart';

part 'activity_event.dart';
part 'activity_state.dart';

/* class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final CreateActivityUC _createActivityUC;

  ActivityBloc({required CreateActivityUC createActivityUC})
      : _createActivityUC = createActivityUC,
        super(ActivityInitial()) {
    on<ActivityLoad>(_onCreateActivity);

    
  }

  void _onCreateActivity(
    ActivityLoad event,
    Emitter<ActivityState> emit,
  ) async {
    emit(ActivityLoading());
    final res = await _createActivityUC(NoParams());

    res.fold(
      (l) => emit(ActivityError(l.message)),
      (r) => emit(ActivityLoaded(r)),
    );
  }
} */

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
      final updatedActivity = state.activity.copyWith(
        laps: state.activity.laps + 1,
        caloriesBurned: event.caloriesBurned,
        steps: state.activity.steps + event.touches + event.misses,
        endAt: DateTime.now(),
        avgBpm: (state.activity.avgBpm + 100) ~/ 2, // Exemple
        maxBpm: (state.activity.maxBpm + 120) ~/ 2, // Exemple
        avgSpeed: (state.activity.avgSpeed + 5) / 2, // Exemple
        maxSpeed: (state.activity.maxSpeed + 10) / 2, // Exemple
        timer: event.timeElapsed,
      );
      emit(ActivityInProgress(updatedActivity));
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
    if (state is ActivityStopped) {
      final currentState = state as ActivityStopped;
      final training = Training(
        id: DateTime.now().millisecondsSinceEpoch,
        description: event.description,
        comments: [],
        activity: currentState.activity,
      );

      final res = await _saveActivityUC(training);
      print("res");
      print(res);

      res.fold(
        (l) => emit(
            ActivitySavedError(l.message, currentState.activity, training)),
        (r) => emit(ActivitySaved(currentState.activity, r)),
      );
      //emit(ActivitySaved(currentState.activity, training));
    }
  }
}

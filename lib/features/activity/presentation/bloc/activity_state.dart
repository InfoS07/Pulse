/* part of 'activity_bloc.dart';

@immutable
sealed class ActivityState {}

final class ActivityInitial extends ActivityState {}

final class ActivityLoading extends ActivityState {}

final class ActivityLoaded extends ActivityState {
  final Activity activity;

  ActivityLoaded(this.activity);
}

final class ActivityError extends ActivityState {
  final String message;

  ActivityError(this.message);
}
 */
part of 'activity_bloc.dart';

class ActivityState extends Equatable {
  final Activity activity;

  const ActivityState(this.activity);

  @override
  List<Object> get props => [activity];
}

class ActivityInitial extends ActivityState {
  ActivityInitial(exercise) : super(Activity.empty(exercise));
}

class ActivityInProgress extends ActivityState {
  ActivityInProgress(Activity activity) : super(activity);
}

class ActivityStopped extends ActivityState {
  final Activity activity;
  final Training training;

  ActivityStopped(this.activity, this.training) : super(activity);

  @override
  List<Object> get props => [activity, training];
}

class ActivitySaved extends ActivityState {
  final Activity activity;
  final Training training;

  ActivitySaved(this.activity, this.training) : super(activity);

  @override
  List<Object> get props => [activity, training];
}

class ActivitySavedError extends ActivityState {
  final String message;
  final Activity activity;
  final Training training;
  final ActivityState previousState;

  ActivitySavedError(
      this.message, this.activity, this.training, this.previousState)
      : super(activity);

  @override
  List<Object> get props => [message, previousState];
}

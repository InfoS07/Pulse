part of 'activity_bloc.dart';

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

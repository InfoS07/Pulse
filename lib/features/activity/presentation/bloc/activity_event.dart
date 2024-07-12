part of 'activity_bloc.dart';

abstract class ActivityEvent extends Equatable {
  const ActivityEvent();

  @override
  List<Object> get props => [];
}

class StartActivity extends ActivityEvent {
  final Exercice exercise;

  const StartActivity(this.exercise);

  @override
  List<Object> get props => [exercise];
}

class UpdateActivity extends ActivityEvent {
  final int? caloriesBurned;
  final int? touches;
  final int? misses;
  final Duration? timeElapsed;
  final int? reactionTime;
  final String? buzzerExpected;
  final String? buzzerPressed;
  final DateTime? pressedAt;

  const UpdateActivity({
    this.caloriesBurned,
    this.touches,
    this.misses,
    this.timeElapsed,
    this.reactionTime,
    this.buzzerExpected,
    this.buzzerPressed,
    this.pressedAt,
  });
}

class StopActivity extends ActivityEvent {
  final Duration timeElapsed;

  const StopActivity(this.timeElapsed);

  @override
  List<Object> get props => [timeElapsed];
}

class SaveActivity extends ActivityEvent {
  final String title;
  final String description;
  final List<XFile> photos;

  const SaveActivity({
    required this.title,
    required this.description,
    required this.photos,
  });

  @override
  List<Object> get props => [title, description, photos];
}

class SaveFailed extends ActivityEvent {
  final String message;

  const SaveFailed(this.message);

  @override
  List<Object> get props => [message];
}

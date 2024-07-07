part of 'activity_bloc.dart';

/* 
@immutable
sealed class ActivityEvent {}

final class ActivityLoad extends ActivityEvent {}

import 'package:equatable/equatable.dart';
import 'package:pulse/core/common/entities/activity.dart'; */
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
  final int caloriesBurned;
  final int touches;
  final int misses;
  final Duration timeElapsed;

  const UpdateActivity({
    required this.caloriesBurned,
    required this.touches,
    required this.misses,
    required this.timeElapsed,
  });

  @override
  List<Object> get props => [caloriesBurned, touches, misses, timeElapsed];
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

part of 'activity_bloc.dart';

@immutable
sealed class ActivityEvent {}

final class ActivityLoad extends ActivityEvent {}

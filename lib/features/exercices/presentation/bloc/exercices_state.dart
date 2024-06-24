part of 'exercices_bloc.dart';

@immutable
sealed class ExercicesState {}

final class ExercicesInitial extends ExercicesState {}

final class ExercicesLoading extends ExercicesState {}

final class ExercicesLoaded extends ExercicesState {
  final List<Exercice?> exercises;

  ExercicesLoaded(this.exercises);
}

final class ExercicesError extends ExercicesState {
  final String message;

  ExercicesError(this.message);
}

final class ExercicesEmpty extends ExercicesState {}

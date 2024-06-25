part of 'exercices_bloc.dart';

@immutable
sealed class ExercicesState {}

final class ExercicesInitial extends ExercicesState {}

final class ExercicesLoading extends ExercicesState {}

final class ExercicesLoaded extends ExercicesState {
  final Map<String, List<Exercice?>> exercisesByCategory;

  ExercicesLoaded(this.exercisesByCategory);
}

final class ExercicesError extends ExercicesState {
  final String message;

  ExercicesError(this.message);
}

final class ExercicesEmpty extends ExercicesState {}

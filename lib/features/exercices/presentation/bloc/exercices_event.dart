part of 'exercices_bloc.dart';

@immutable
sealed class ExercicesEvent {}

final class ExercicesLoad extends ExercicesEvent {}

final class ExercicesSearch extends ExercicesEvent {
  final String searchTerm;

  ExercicesSearch(this.searchTerm);
}

final class AchatExercice extends ExercicesEvent {
  final int exerciceId;
  final String userId;
  final int prix;

  AchatExercice(this.exerciceId, this.userId, this.prix);
}

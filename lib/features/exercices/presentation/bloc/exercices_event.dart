part of 'exercices_bloc.dart';

@immutable
sealed class ExercicesEvent {}

final class ExercicesLoad extends ExercicesEvent {}

final class ExercicesSearch extends ExercicesEvent {
  final String searchTerm;

  ExercicesSearch(this.searchTerm);
}

part of 'list_trainings_bloc.dart';

@immutable
abstract class ListTrainingsEvent {}

class ListTrainingsGetTraining extends ListTrainingsEvent {
  final String userId;

  ListTrainingsGetTraining(this.userId);
  
}

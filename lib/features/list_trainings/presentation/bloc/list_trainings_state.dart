part of 'list_trainings_bloc.dart';

abstract class ListTtrainingsState extends Equatable {
  const ListTtrainingsState();

  @override
  List<Object> get props => [];
}

class ListTrainingsInitial extends ListTtrainingsState {}

class ListTrainingsLoading extends ListTtrainingsState {}


class ListTrainingsSuccess extends ListTtrainingsState {
  final List<TrainingList> trainings;
  const ListTrainingsSuccess(this.trainings);
}

class ListTrainingsError extends ListTtrainingsState {
  final String message;

  const ListTrainingsError(this.message);

  @override
  List<Object> get props => [message];
}

// home_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pulse/core/common/entities/trainingList.dart';
import 'package:pulse/features/list_trainings/domain/usecases/get_trainings.dart';

part 'list_trainings_event.dart';
part 'list_trainings_state.dart';

class ListTrainingsBloc extends Bloc<ListTrainingsEvent, ListTtrainingsState> {
  final GetTrainings _getTrainings;

  ListTrainingsBloc({required GetTrainings getTrainings})
      : _getTrainings = getTrainings,
        super(ListTrainingsInitial()) {
    on<ListTrainingsGetTraining>(_onGetTraining);
  }

  void _onGetTraining(
  ListTrainingsGetTraining event,
  Emitter<ListTtrainingsState> emit,
) async {
  emit(ListTrainingsLoading());
  final res = await _getTrainings(event.userId);

    res.fold(
      (l) => emit(ListTrainingsError(l.message)),
      (r) => emit(ListTrainingsSuccess(r)),
    );
}

}

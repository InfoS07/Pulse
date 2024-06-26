import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pulse/core/common/entities/activity.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/activity/domain/usecases/create_activity_uc.dart';

part 'activity_event.dart';
part 'activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final CreateActivityUC _createActivityUC;

  ActivityBloc({required CreateActivityUC createActivityUC})
      : _createActivityUC = createActivityUC,
        super(ActivityInitial()) {
    on<ActivityLoad>(_onCreateActivity);
  }

  void _onCreateActivity(
    ActivityLoad event,
    Emitter<ActivityState> emit,
  ) async {
    emit(ActivityLoading());
    final res = await _createActivityUC(NoParams());

    res.fold(
      (l) => emit(ActivityError(l.message)),
      (r) => emit(ActivityLoaded(r)),
    );
  }
}

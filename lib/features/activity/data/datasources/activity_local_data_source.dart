import 'package:pulse/features/activity/domain/models/activity_model.dart';

abstract class ActivityLocalDataSource {
  Future<void> cacheActivities(List<ActivityModel> activities);
  Future<List<ActivityModel>> getActivities();
}

class ActivityLocalDataSourceImpl extends ActivityLocalDataSource {
  @override
  Future<void> cacheActivities(List<ActivityModel> activities) {
    //
    return Future.value();
  }

  @override
  Future<List<ActivityModel>> getActivities() {
    //
    return Future.value([]);
  }
}

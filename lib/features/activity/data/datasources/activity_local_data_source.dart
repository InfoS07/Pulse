import 'package:pulse/features/activity/domain/models/activity_model.dart';

abstract class ActivityLocalDataSource {
  Future<void> cacheActivities(List<ActivityModel> activities);
  Future<List<ActivityModel>> getActivities();
}

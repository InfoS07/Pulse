import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/activity.dart';
import 'package:pulse/core/error/failures.dart';

abstract interface class ActivityRepository {
  Future<Either<Failure, Activity>> createActivity();
  //Future<Either<Failure, Activity>> saveActivity();
}

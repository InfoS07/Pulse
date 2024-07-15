import 'dart:async';

import 'package:pulse/features/challenges/domain/repository/challenges_repository.dart';
import 'package:pulse/features/challenges_users/domain/repository/challenges_users_repository.dart';

class WatchChallengesInsert {
  final ChallengeUserRepository repository;

  WatchChallengesInsert(this.repository);

  StreamSubscription<List<Map<String, dynamic>>> call() {
    return repository.watchChallenges();
  }
}

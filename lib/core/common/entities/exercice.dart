import 'dart:ffi';

import 'package:pulse/core/common/entities/user.dart';

class Exercice {
  final String id;
  final String title;
  final String urlPhoto;
  final String description;
  final int duration;
  List<int> sequence = [1, 2, 3, 4, 5];
  int repetitions = 3;
  int podCount = 0;
  int playerCount = 0;
  int durationOneRepetition = 0;
  int caloriesBurned = 0;
  User author = User.empty();
  double score = 0.0;
  String level = "Nul";
  int laps = 0;

  Exercice(
      {required this.id,
      required this.title,
      required this.urlPhoto,
      required this.description,
      required this.duration,
      required this.sequence,
      required this.repetitions,
      required this.podCount,
      required this.playerCount,
      required this.durationOneRepetition,
      required this.caloriesBurned,
      required this.author,
      required this.score,
      required this.level,
      required this.laps});

  static Exercice empty() {
    return Exercice(
      id: '',
      title: '',
      urlPhoto: '',
      description: '',
      duration: 0,
      sequence: [],
      repetitions: 0,
      podCount: 0,
      playerCount: 0,
      durationOneRepetition: 0,
      caloriesBurned: 0,
      author: User.empty(),
      score: 0.0,
      level: '',
      laps: 0,
    );
  }
}

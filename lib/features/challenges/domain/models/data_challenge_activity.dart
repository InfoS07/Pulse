import 'package:pulse/core/common/entities/exercice.dart';

class DataChallengeActivity {
  late Exercice _exercice;
  final int points;
  final int repetitions;
  final int idChallenge;

  DataChallengeActivity({
    required Exercice exercice,
    required this.points,
    required this.repetitions,
    required this.idChallenge,
  }) : _exercice = exercice;

  // Getter for exercice
  Exercice get exercice => _exercice;

  // Setter for exercice
  set exercice(Exercice newExercice) {
    _exercice = newExercice;
  }
}

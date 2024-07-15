class Exercice {
  final int id;
  final String title;
  final String description;
  final List<String> photos;
  final List<String> categories;
  final int duration;
  List<int> sequence = [1, 2, 3, 4];
  int repetitions = 3;
  int podCount = 0;
  int playerCount = 0;
  int durationOneRepetition = 0;
  int caloriesBurned = 0;
  double score = 0.0;
  String difficulty = "Facile";
  int laps = 0;
  String hit_type = "Hand";

  Exercice(
      {required this.id,
      required this.title,
      required this.photos,
      required this.categories,
      required this.description,
      required this.duration,
      required this.sequence,
      required this.repetitions,
      required this.podCount,
      required this.playerCount,
      required this.durationOneRepetition,
      required this.caloriesBurned,
      required this.score,
      required this.difficulty,
      required this.laps,
      required this.hit_type});

  static Exercice empty() {
    return Exercice(
        id: 0,
        title: '',
        photos: [''],
        categories: [''],
        description: '',
        duration: 0,
        sequence: [],
        repetitions: 0,
        podCount: 0,
        playerCount: 0,
        durationOneRepetition: 0,
        caloriesBurned: 0,
        score: 0.0,
        difficulty: 'Facile',
        laps: 0,
        hit_type: 'Hand');
  }
}

class Activity {
  final int id;
  final int exerciseId;
  final int laps;
  final int caloriesBurned;
  final String status;
  final int steps;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime createdAt;
  final int avgBpm;
  final int maxBpm;
  final double avgSpeed;
  final double maxSpeed;
  final List<int> durationLaps;
  final List<int> pauseBetweenLaps;

  Activity({
    required this.id,
    required this.exerciseId,
    required this.laps,
    required this.caloriesBurned,
    required this.status,
    required this.steps,
    required this.startAt,
    required this.endAt,
    required this.createdAt,
    required this.avgBpm,
    required this.maxBpm,
    required this.avgSpeed,
    required this.maxSpeed,
    required this.durationLaps,
    required this.pauseBetweenLaps,
  });
}

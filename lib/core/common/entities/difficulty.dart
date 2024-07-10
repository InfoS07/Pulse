class Difficulty {
  static const String easy = "Facile";
  static const String medium = "Moyen";
  static const String hard = "Difficile";

  static const Map<String, String> levels = {
    "easy": easy,
    "medium": medium,
    "hard": hard,
  };

  static String getDifficulty(String key) {
    return levels[key] ?? "Unknown";
  }
}

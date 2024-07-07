class ChallengesModel {
  final int id;
  final String name;
  final String type;
  final String description;
  final int points;
  final DateTime createdAt;
  final String? photo;
  final int? exerciceId;
  final DateTime? endAt;
  final DateTime? startAt;
  final List<int>? participants;
  final List<int>? achievers;

  ChallengesModel({
    required this.id,
    required this.name,
    required this.description,
    required this.points,
    required this.type,
    required this.createdAt,
    this.photo,
    this.exerciceId,
    this.endAt,
    this.startAt,
    this.participants,
    this.achievers,
  });

  factory ChallengesModel.fromJson(Map<String, dynamic> map) {
    return ChallengesModel(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      points: map['points'] ?? 0,
      type: map['type'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      photo: map['photo'],
      exerciceId: map['exercice_id'],
      endAt: map['end_at'] != null ? DateTime.parse(map['end_at']) : null,
      startAt: map['start_at'] != null ? DateTime.parse(map['start_at']) : null,
      participants: (map['participants'] as List<dynamic>?)?.map((e) => e as int).toList(),
      achievers: (map['achievers'] as List<dynamic>?)?.map((e) => e as int).toList(),
    );
  }

  static List<ChallengesModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ChallengesModel.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'description': description,
      'points': points,
      'created_at': createdAt.toIso8601String(),
      'photo': photo,
      'exercice_id': exerciceId,
      'participants': participants,
      'achievers': achievers,
      'end_at': endAt?.toIso8601String(),
      'start_at': startAt?.toIso8601String(),
    };
  }
}

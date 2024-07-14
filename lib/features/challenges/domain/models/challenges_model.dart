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
  final List<String>? participants;
  final List<String>? achievers;

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
      participants: (map['participants'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      achievers: (map['achievers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
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

  ChallengesModel copyWith({
    int? id,
    String? name,
    String? description,
    int? points,
    String? type,
    DateTime? createdAt,
    String? photo,
    int? exerciceId,
    DateTime? endAt,
    DateTime? startAt,
    List<String>? participants,
    List<String>? achievers,
  }) {
    return ChallengesModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      points: points ?? this.points,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      photo: photo ?? this.photo,
      exerciceId: exerciceId ?? this.exerciceId,
      endAt: endAt ?? this.endAt,
      startAt: startAt ?? this.startAt,
      participants: participants ?? this.participants,
      achievers: achievers ?? this.achievers,
    );
  }
}

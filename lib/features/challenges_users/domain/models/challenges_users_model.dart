class ChallengeUserModel {
  final int id;
  final String name;
  final DateTime createdAt;
  final String? photo;
  final DateTime? endAt;
  final int trainingId;
  final String description;
  final String type;
  final Map<String, dynamic> participants;
  final String authorId;

  ChallengeUserModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.photo,
    this.endAt,
    required this.trainingId,
    required this.description,
    required this.type,
    required this.participants,
    required this.authorId,
  });

  factory ChallengeUserModel.fromJson(Map<String, dynamic> json) {
    return ChallengeUserModel(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
      photo: json['photo'],
      endAt: json['end_at'] != null ? DateTime.parse(json['end_at']) : null,
      trainingId: json['training_id'],
      description: json['description'],
      type: json['type'],
      participants: json['participants'],
      authorId: json['author_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'photo': photo,
      'end_at': endAt?.toIso8601String(),
      'training_id': trainingId,
      'description': description,
      'type': type,
      'participants': participants,
      'author_id': authorId,
    };
  }
}

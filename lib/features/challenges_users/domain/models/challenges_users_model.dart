import 'package:pulse/core/common/entities/user.dart';

class ChallengeUserModel {
  final int id;
  final String name;
  final DateTime createdAt;
  final String? photo;
  final DateTime? endAt;
  final int trainingId;
  final String description;
  final List<String> invites;
  final String type;
  final Map<String, Participant> participants;
  final String authorId;
  List<User> participantsDetails; // New field

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
    required this.invites,
    required this.participantsDetails, // New required parameter
  });

  factory ChallengeUserModel.fromJson(Map<String, dynamic> json) {
    final participantsJson = json['participants'] as Map<String, dynamic>;
    final participants = participantsJson.map(
      (key, value) =>
          MapEntry(key, Participant.fromJson(value as Map<String, dynamic>)),
    );

    // Initialize participantsDetails from participants data
    final participantsDetails = participants.values.map((participant) {
      final user = User(
        uid: participant.idUser,
        email: '', // Add these fields if available in your database
        lastName: '', // Add these fields if available in your database
        firstName: '', // Add these fields if available in your database
        username: '', // Add these fields if available in your database
        birthDate:
            DateTime.now(), // Add these fields if available in your database
        urlProfilePhoto: '', // Add these fields if available in your database
        points: 0, // Add these fields if available in your database
      );
      return user;
    }).toList();

    return ChallengeUserModel(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
      photo: json['photo'],
      endAt: json['end_at'] != null ? DateTime.parse(json['end_at']) : null,
      trainingId: json['training_id'],
      description: json['description'],
      type: json['type'],
      participants: participants,
      authorId: json['author_id'],
      invites: List<String>.from(json['invites']),
      participantsDetails: participantsDetails, // Assign participantsDetails
    );
  }

  Map<String, dynamic> toJson() {
    final participantsJson =
        participants.map((key, value) => MapEntry(key, value.toJson()));

    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'photo': photo,
      'end_at': endAt?.toIso8601String(),
      'training_id': trainingId,
      'description': description,
      'type': type,
      'participants': participantsJson,
      'author_id': authorId,
      'invites': invites,
    };
  }
}

class Participant {
  final int score;
  final String idUser;
  User user; // New field

  Participant({
    required this.score,
    required this.idUser,
    required this.user, // Initialize with User
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      score: json['score'],
      idUser: json['idUser'],
      user: User.empty(), // Initialize user
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'idUser': idUser,
    };
  }
}

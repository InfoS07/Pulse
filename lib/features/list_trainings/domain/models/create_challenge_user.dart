import 'package:flutter/foundation.dart';

class CreateChallengeUser {
  final String challengeName;
  final String description;
  final DateTime endDate;
  final DateTime createdAt;
  final int trainingId;
  final String authorId;
  final String type;
  final List<String> invites;
  final Map<String, Map<String, dynamic>> participant;

  CreateChallengeUser({
    required this.challengeName,
    required this.description,
    required this.endDate,
    required this.trainingId,
    required this.authorId,
    required this.type,
    required this.createdAt,
    required this.invites,
    required this.participant,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': challengeName,
      'description': description,
      'end_at': endDate.toIso8601String(),
      'training_id': trainingId,
      'author_id': authorId,
      'type': type,
      'invites': invites,
      'created_at': createdAt.toIso8601String(),
      'participants': participant
    };
  }
}

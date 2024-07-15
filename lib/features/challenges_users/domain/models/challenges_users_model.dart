import 'package:pulse/core/common/entities/training.dart';
import 'package:pulse/core/common/entities/training_challenges.dart';
import 'package:pulse/core/common/entities/user.dart';
import 'package:pulse/features/activity/domain/models/training_model.dart';
import 'package:pulse/features/auth/domain/models/user_model.dart';

class ChallengeUserModel {
  final int id;
  final String name;
  final String createdAt;
  final String? photo;
  final String endAt;
  final TrainingChallenge training;
  final String description;
  final String type;
  final List<User> invites;
  final List<Participant> participants;
  final User author;

  ChallengeUserModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.photo,
    required this.endAt,
    required this.training,
    required this.description,
    required this.type,
    required this.participants,
    required this.author,
    required this.invites,
  });

  factory ChallengeUserModel.fromJson(Map<String, dynamic> json) {
    return ChallengeUserModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      createdAt: json['created_at'] ?? '',
      photo: json['photo'] ?? '',
      endAt: json['end_at'] ?? '',
      training: TrainingChallenge.fromJson(json['training']),
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      author: UserModel.fromJson(json['author']),
      participants: (json['participants'] as List<dynamic>?)
              ?.map((participant) => Participant.fromJson(participant))
              .toList() ??
          [],
      invites: (json['invites'] as List<dynamic>?)
              ?.map((invite) => UserModel.fromJson(invite))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt,
      'photo': photo,
      'end_at': endAt,
      'training': training,
      'description': description,
      'type': type,
      'participants': participants,
      'author': author,
      'invites': invites,
    };
  }
}

class Participant {
  final int score;
  User user; // New field

  Participant({
    required this.score,
    required this.user,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      score: json['score'],
      user: UserModel.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'user': user,
    };
  }
}

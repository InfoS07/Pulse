import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/features/challenges_users/domain/models/challenges_users_model.dart';
import 'package:pulse/features/list_trainings/domain/models/create_challenge_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/features/challenges_users/domain/models/challenges_users_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pulse/core/common/entities/user.dart' as custom_user;

abstract class ChallengesUsersRemoteDataSource {
  Future<List<ChallengeUserModel>> getChallengeUsers();
  Future<void> joinChallenge(int challengeId, String userId);
  Future<void> quitChallenge(int challengeId, String userId);
  Future<void> deleteChallenge(int challengeId);
  Future<void> createChallenge(CreateChallengeUser challengeUser);
  Future<void> addInvitesToChallenge(int challengeId, List<String> userIds);
}

class ChallengeUserRemoteDataSourceImpl
    extends ChallengesUsersRemoteDataSource {
  final SupabaseClient supabaseClient;

  ChallengeUserRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<ChallengeUserModel>> getChallengeUsers() async {
    try {
      final response = await supabaseClient.from('challenges_users').select();

      final challenges = (response as List)
          .map((json) => ChallengeUserModel.fromJson(json))
          .toList();

      // Fetch users data
      final List<dynamic> userIds = challenges
          .expand((challenge) => challenge.participants.values
              .map((participant) => participant.idUser))
          .toSet()
          .toList();

      if (userIds.isNotEmpty) {
        final usersResponse = await supabaseClient
            .from('users')
            .select()
            .inFilter('uid', userIds);

        final users = (usersResponse as List)
            .map((json) => custom_user.User.fromJson(json))
            .toList();

        final userMap = {for (var user in users) user.uid: user};

        for (var challenge in challenges) {
          challenge.participants.forEach((key, participant) {
            participant.user = userMap[participant.idUser]!;
          });
        }
      }

      return challenges;
    } on PostgrestException catch (e) {
      throw ServerException("Error Zer");
    } catch (e) {
      throw ServerException("Error fetching challenges");
    }
  }

  @override
  Future<void> deleteChallenge(int challengeId) async {
    try {
      await supabaseClient
          .from('challenges_users')
          .delete()
          .eq('id', challengeId);
    } on PostgrestException catch (e) {
      throw ServerException("Error deleting challenge");
    } catch (e) {
      throw ServerException("Error deleting challenge");
    }
  }

  @override
  Future<void> joinChallenge(int challengeId, String userId) async {
    try {
      final response = await supabaseClient
          .from('challenges_users')
          .select()
          .eq('id', challengeId)
          .single();

      if (response != null) {
        final Map<String, dynamic> participants =
            Map<String, dynamic>.from(response['participants']);

        // Find the first available ID
        int newParticipantId = 1;
        while (participants.containsKey(newParticipantId.toString())) {
          newParticipantId++;
        }

        // Add the user to participants with the new ID
        participants[newParticipantId.toString()] = {
          'score': 0,
          'idUser': userId
        };

        await supabaseClient
            .from('challenges_users')
            .update({'participants': participants}).eq('id', challengeId);
      }
    } on PostgrestException catch (e) {
      throw ServerException("Error joining challenge");
    } catch (e) {
      throw ServerException("Error joining challenge");
    }
  }

  @override
  Future<void> quitChallenge(int challengeId, String userId) async {
    try {
      final response = await supabaseClient
          .from('challenges_users')
          .select()
          .eq('id', challengeId)
          .single();

      if (response != null) {
        final Map<String, dynamic> participants =
            Map<String, dynamic>.from(response['participants']);
        participants.removeWhere((key, value) => value['idUser'] == userId);

        await supabaseClient
            .from('challenges_users')
            .update({'participants': participants}).eq('id', challengeId);
      }
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException("Error quitting challenge");
    }
  }

  @override
  Future<void> createChallenge(CreateChallengeUser challengeUser) async {
    try {
      // Convert challengeUser model to JSON
      final json = challengeUser.toJson();

      // Send POST request to create challenge user
      print(json);
      var response =
          await supabaseClient.from('challenges_users').insert([json]);
      print(response);
    } on PostgrestException catch (e) {
      throw ServerException("Error creating challenge");
    } catch (e) {
      throw ServerException("Error creating challenge");
    }
  }

  Future<void> addInvitesToChallenge(int challengeId, List<String> userIds) async {
    try {
      final response = await supabaseClient
          .from('challenges_users')
          .select()
          .eq('id', challengeId)
          .single();

      if (response != null) {
        final List<String> currentInvites = List<String>.from(response['invites'] ?? []);
        
        // Ajouter les nouveaux userIds à la liste des invites existants
        currentInvites.addAll(userIds.where((userId) => !currentInvites.contains(userId)));

        await supabaseClient
            .from('challenges_users')
            .update({'invites': currentInvites})
            .eq('id', challengeId);
      }
    } on PostgrestException catch (e) {
      throw ServerException("Error adding invites to challenge");
    } catch (e) {
      throw ServerException("Error adding invites to challenge");
    }
  }
}

//{"name": "dsqdq", "description": "qsdqs", "end_at": challengeUser.endDate.toIso8601String(), "training_id": 1, "author_id": "a2ee471c-b57b-4815-879e-5024b058abeb", "type": "Durée", "invites": ["a2ee471c-b57b-4815-879e-5024b058abeb"], "created_at": challengeUser.createdAt.toIso8601String()}
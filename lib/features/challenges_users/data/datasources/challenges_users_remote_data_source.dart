import 'dart:async';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:pulse/core/common/entities/training.dart';
import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/core/services/graphql_service.dart';
import 'package:pulse/features/challenges_users/domain/models/challenges_users_model.dart';
import 'package:pulse/features/list_trainings/domain/models/create_challenge_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/features/challenges_users/domain/models/challenges_users_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pulse/core/common/entities/user.dart' as custom_user;
import 'package:pulse/core/error/exceptions.dart' as pulse_exceptions;

abstract class ChallengesUsersRemoteDataSource {
  Future<List<ChallengeUserModel>> getChallengeUsers();
  Future<void> joinChallenge(int challengeId, String userId);
  Future<void> finishChallengeUser(int challengeId, String userId, int score);
  Future<void> quitChallenge(int challengeId, String userId);
  Future<void> deleteChallenge(int challengeId);
  Future<void> createChallenge(CreateChallengeUser challengeUser);
  Future<void> addInvitesToChallenge(int challengeId, List<String> userIds);
  StreamSubscription<List<Map<String, dynamic>>> getChallengesStream();
}

class ChallengeUserRemoteDataSourceImpl
    extends ChallengesUsersRemoteDataSource {
  final SupabaseClient supabaseClient;
  final GraphQLService graphQLService;

  ChallengeUserRemoteDataSourceImpl(this.supabaseClient, this.graphQLService);

  @override
  StreamSubscription<List<Map<String, dynamic>>> getChallengesStream() {
    return supabaseClient
        .from('challenges_users')
        .stream(primaryKey: ['id']).listen((List<Map<String, dynamic>> data) {
      // Do something awesome with the data
    });
  }

  @override
  Future<List<ChallengeUserModel>> getChallengeUsers() async {
    try {
      const String query = '''
        {
          challengesUser {
            id
            name
            description
            type
            created_at
            end_at
            training {
              id
              stats {
                buzzer_expected
                buzzer_pressed
                reaction_time
                pressed_at
              }
              repetitions
              start_at
              end_at
              title
              description
              author {
                    id
                    uid
                    email
                    last_name
                    first_name
                    profile_photo
                    birth_date
                    points
              }
              exercise {
                id
                title
                description
                pod_count
                calories_burned
                photos
                categories
                photos
                sequence
              }
            }
            participants {
                score
                user {
                    id
                    uid
                    email
                    last_name
                    first_name
                    profile_photo
                    birth_date
                    points
                }
            }
            invites {
                id
                uid
                email
                last_name
                first_name
                profile_photo
                birth_date
                points
            }
            author {
                id
                uid
                email
                last_name
                first_name
                profile_photo
                birth_date
                points
            }
          }
        }
      ''';

      final result = await graphQLService.client.query(
        QueryOptions(
          document: gql(query),
          fetchPolicy: FetchPolicy.noCache,
        ),
      );

      if (result.hasException) {
        throw pulse_exceptions.ServerException(result.exception.toString());
      }

      if (result.data == null) {
        throw pulse_exceptions.ServerException("No data found");
      }

      if (result.data!.isEmpty) {
        return [];
      }

      final challengesData = result.data!["challengesUser"] as List<dynamic>;

      var data = challengesData.map((challenge) {
        return ChallengeUserModel.fromJson(challenge);
      }).toList();

      return data;
    } catch (e) {
      throw pulse_exceptions.ServerException(e.toString());
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
      throw pulse_exceptions.ServerException("Error deleting challenge");
    } catch (e) {
      throw pulse_exceptions.ServerException("Error deleting challenge");
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
      throw pulse_exceptions.ServerException("Error joining challenge");
    } catch (e) {
      throw pulse_exceptions.ServerException("Error joining challenge");
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
      throw pulse_exceptions.ServerException(e.message);
    } catch (e) {
      throw pulse_exceptions.ServerException("Error quitting challenge");
    }
  }

  @override
  Future<void> createChallenge(CreateChallengeUser challengeUser) async {
    try {
      // Convert challengeUser model to JSON
      final json = challengeUser.toJson();

      final response =
          await supabaseClient.from('challenges_users').insert([json]);
    } catch (e) {
      throw pulse_exceptions.ServerException("Error creating challenge");
    }
  }

  Future<void> addInvitesToChallenge(
      int challengeId, List<String> userIds) async {
    try {
      final response = await supabaseClient
          .from('challenges_users')
          .select()
          .eq('id', challengeId)
          .single();

      if (response != null) {
        final List<String> currentInvites =
            List<String>.from(response['invites'] ?? []);

        // Ajouter les nouveaux userIds à la liste des invites existants
        currentInvites.addAll(
            userIds.where((userId) => !currentInvites.contains(userId)));

        await supabaseClient
            .from('challenges_users')
            .update({'invites': currentInvites}).eq('id', challengeId);
      }
    } on PostgrestException catch (e) {
      throw pulse_exceptions.ServerException(
          "Error adding invites to challenge");
    } catch (e) {
      throw pulse_exceptions.ServerException(
          "Error adding invites to challenge");
    }
  }

  @override
  Future<void> finishChallengeUser(
      int challengeId, String userId, int score) async {
    try {
      final response = await supabaseClient
          .from('challenges_users')
          .select()
          .eq('id', challengeId)
          .single();

      if (response != null) {
        final Map<String, dynamic> participants =
            Map<String, dynamic>.from(response['participants']);

        // Rechercher le participant avec l'idUser correspondant
        bool userFound = false;
        participants.forEach((key, value) {
          if (value['idUser'] == userId) {
            value['score'] = score;
            userFound = true;
          }
        });

        if (!userFound) {
          throw pulse_exceptions.ServerException(
              "User not found in participants");
        }

        // Mettre à jour les participants dans la base de données
        await supabaseClient
            .from('challenges_users')
            .update({'participants': participants}).eq('id', challengeId);
      }
    } on PostgrestException catch (e) {
      throw pulse_exceptions.ServerException(
          "Error updating challenge participant");
    } catch (e) {
      throw pulse_exceptions.ServerException(
          "Error updating challenge participant");
    }
  }
}

//{"name": "dsqdq", "description": "qsdqs", "end_at": challengeUser.endDate.toIso8601String(), "training_id": 1, "author_id": "a2ee471c-b57b-4815-879e-5024b058abeb", "type": "Durée", "invites": ["a2ee471c-b57b-4815-879e-5024b058abeb"], "created_at": challengeUser.createdAt.toIso8601String()}
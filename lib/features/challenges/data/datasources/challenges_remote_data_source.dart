import 'dart:async';
import 'dart:ffi';

import 'package:pulse/core/common/entities/user.dart';
import 'package:pulse/core/error/exceptions.dart' as pulse_exceptions;
import 'package:pulse/core/services/graphql_service.dart';
import 'package:pulse/features/challenges/domain/models/challenges_model.dart';
import 'package:pulse/features/exercices/domain/models/exercices_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ChallengesRemoteDataSource {
  Future<List<ChallengesModel>> getChallenges();
  Future<void> joinChallenge(int challengeId, String userId);
  Future<void> quitChallenge(int challengeId, String userId);
  Future<void> finishChallenge(
      int challengeId, String userId, int pointsGagnes);
}

class ChallengesRemoteDataSourceImpl extends ChallengesRemoteDataSource {
  final SupabaseClient supabaseClient;

  ChallengesRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<ChallengesModel>> getChallenges() async {
    try {
      final response = await supabaseClient.from('challenges').select();
      final List<dynamic> data = response;
      return ChallengesModel.fromJsonList(data);
    } on PostgrestException catch (e) {
      throw ServerException();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> joinChallenge(int challengeId, String userId) async {
    try {
      // Récupérer les données du challenge spécifique
      final response = await supabaseClient
          .from('challenges')
          .select('*')
          .eq('id', challengeId.toString())
          .single();

      // Récupérer les participants actuels
      List<dynamic> participants = response['participants'];

      // Vérifier si l'utilisateur est déjà dans la liste des participants
      if (!participants.contains(userId)) {
        // Ajouter userId au tableau des participants
        participants.add(userId);

        // Mettre à jour la base de données avec les nouveaux participants
        await supabaseClient.from('challenges').update(
            {'participants': participants}).eq('id', challengeId.toString());
      }
    } on PostgrestException catch (e) {
      throw ServerException(); // Gérer les exceptions spécifiques à Supabase
    } catch (e) {
      throw ServerException(); // Gérer les autres exceptions
    }
  }

  @override
  Future<void> quitChallenge(int challengeId, String userId) async {
    try {
      // Récupérer les données du challenge spécifique
      final response = await supabaseClient
          .from('challenges')
          .select('*')
          .eq('id', challengeId.toString())
          .single();

      // Vérifier si le challenge existe
      if (response == null) {
        throw ServerException(); // Gérer l'erreur si le challenge n'est pas trouvé
      }

      // Récupérer les participants actuels
      List<dynamic> participants = response['participants'];

      // Retirer userId du tableau des participants
      participants.remove(userId);

      // Mettre à jour la base de données avec les nouveaux participants
      await supabaseClient.from('challenges').update(
          {'participants': participants}).eq('id', challengeId.toString());
    } on PostgrestException catch (e) {
      throw ServerException(); // Gérer les exceptions spécifiques à Supabase
    } catch (e) {
      throw ServerException(); // Gérer les autres exceptions
    }
  }

  @override
  Future<void> finishChallenge(
      int challengeId, String userId, int pointsGagnes) async {
    try {
      // Récupérer les données du challenge spécifique
      final response = await supabaseClient
          .from('challenges')
          .select('*')
          .eq('id', challengeId.toString())
          .single();

      // Récupérer les participants actuels
      List<dynamic> achievers = response['achievers'];

      // Vérifier si l'utilisateur est déjà dans la liste des participants
      if (!achievers.contains(userId)) {
        // Ajouter userId au tableau des participants
        achievers.add(userId);

        // Mettre à jour la base de données avec les nouveaux participants
        await supabaseClient
            .from('challenges')
            .update({'achievers': achievers}).eq('id', challengeId.toString());
      }

      final response2 = await supabaseClient
          .from('users')
          .select('*')
          .eq('uid', userId.toString())
          .single();

      int point = response2['points'];
      point += pointsGagnes;

      await supabaseClient
          .from('users')
          .update({'points': point}).eq('uid', userId.toString());
    } on PostgrestException catch (e) {
      throw ServerException(); // Gérer les exceptions spécifiques à Supabase
    } catch (e) {
      throw ServerException(); // Gérer les autres exceptions
    }
  }
}

import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/error/exceptions.dart' as pulse_exceptions;
import 'package:pulse/core/services/graphql_service.dart';
import 'package:pulse/features/exercices/domain/models/exercices_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ExercicesRemoteDataSource {
  Future<Map<String, List<ExercicesModel?>>> getExercices();
  Future<Map<String, List<ExercicesModel?>>> searchExercices(
    String searchTerm,
  );
  Future<Unit> achatExercice(int exerciceId, String userId, int prix);
}

class ExercicesRemoteDataSourceImpl extends ExercicesRemoteDataSource {
  final GraphQLService graphQLService;
  final SupabaseClient supabaseClient;

  ExercicesRemoteDataSourceImpl(this.graphQLService, this.supabaseClient);

  @override
  Future<Map<String, List<ExercicesModel?>>> getExercices() async {
    try {
      const String query = '''
        {
          exercises {
              id
              title
              description
              pod_count
              calories_burned
              photos
              categories
              photos
              difficulty
              player_count
              type
              sequence
              price_coin
              premiums
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

      final data = result.data?["exercises"] as List;

      return transformData(data);
    } catch (e) {
      throw pulse_exceptions.ServerException(e.toString());
    }
  }

  Map<String, List<ExercicesModel?>> transformData(List data) {
    final types = [];
    for (var element in data) {
      final type = element['type'];
      if (!types.contains(type)) {
        types.add(type);
      }
    }

    return types.fold<Map<String, List<ExercicesModel?>>>(
      {},
      (previousValue, element) {
        final filteredData = data.where((el) {
          final type = el['type'];
          return type == element;
        }).toList();

        final exercices = filteredData.map((e) {
          return ExercicesModel.fromJson(e);
        }).toList();

        previousValue[element] = exercices;

        return previousValue;
      },
    );
  }

  @override
  Future<Map<String, List<ExercicesModel?>>> searchExercices(
      String searchTerm) async {
    try {
      String query = '''
        {
          exercises(query: "$searchTerm") {
              id
              title
              description
              pod_count
              calories_burned
              photos
              categories
              photos
              difficulty
              player_count
              type
              sequence
              price_coin
              premiums
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

      final data = result.data?["exercises"] as List;

      return transformData(data);
    } catch (e) {
      throw pulse_exceptions.ServerException(e.toString());
    }
  }

  @override
  Future<Unit> achatExercice(int exerciceId, String userId, int prix) async {
    try {
      // Récupérer les données de l'utilisateur
      final userResponse = await supabaseClient
          .from('users')
          .select('points')
          .eq('uid', userId)
          .single();

      int pointsUtilisateur = userResponse['points'];

      // Vérifier si l'utilisateur a suffisamment de points
      if (pointsUtilisateur < prix) {
        throw Exception(
            "Vous n'avez pas assez de points pour acheter cet exercice.");
      }

      // Récupérer les données de l'exercice
      final exerciceResponse = await supabaseClient
          .from('exercises')
          .select('premiums')
          .eq('id', exerciceId)
          .single();

      List<dynamic> premiums = exerciceResponse['premiums'];

      // Vérifier si l'utilisateur est déjà dans la liste des participants
      if (!premiums.contains(userId)) {
        // Ajouter userId au tableau des participants
        premiums.add(userId);

        // Mettre à jour la base de données avec les nouveaux participants
        await supabaseClient
            .from('exercises')
            .update({'premiums': premiums}).eq('id', exerciceId);
      }

      // Déduire le prix des points de l'utilisateur
      int nouveauxPoints = pointsUtilisateur - prix;

      // Mettre à jour les points de l'utilisateur dans la base de données
      await supabaseClient
          .from('users')
          .update({'points': nouveauxPoints}).eq('uid', userId);

      return unit;
    } on PostgrestException catch (e) {
      throw ServerException();
    } catch (e) {
      throw ServerException();
    }
  }
}

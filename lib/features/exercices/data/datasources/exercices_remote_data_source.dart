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
      // Récupérer les données du challenge spécifique
      final response = await supabaseClient
          .from('exercises')
          .select('*')
          .eq('id', exerciceId.toString())
          .single();

      // Récupérer les participants actuels
      List<dynamic> premiums = response['premiums'];

      // Vérifier si l'utilisateur est déjà dans la liste des participants
      

      final response2 = await supabaseClient
          .from('users')
          .select('*')
          .eq('uid', userId.toString())
          .single();

      int point = response2['points'];
      if (point < prix) {
        throw const pulse_exceptions.ServerException('Vous n\'avez pas assez de points');
      }
      else {
        point -= prix;
        if (!premiums.contains(userId)) {
        premiums.add(userId);

        await supabaseClient
            .from('exercises')
            .update({'premiums': premiums}).eq('id', exerciceId.toString());
      }
      }
      

      await supabaseClient
          .from('users')
          .update({'points': point}).eq('uid', userId.toString());
    } on PostgrestException catch (e) {
      throw const ServerException(); // Gérer les exceptions spécifiques à Supabase
    } catch (e) {
      throw const ServerException(); // Gérer les autres exceptions
    }
    return unit;
  }
}

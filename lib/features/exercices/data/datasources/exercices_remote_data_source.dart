import 'package:pulse/core/error/exceptions.dart' as pulse_exceptions;
import 'package:pulse/core/services/graphql_service.dart';
import 'package:pulse/features/exercices/domain/models/exercices_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

abstract class ExercicesRemoteDataSource {
  Future<Map<String, List<ExercicesModel?>>> getExercices();
  Future<Map<String, List<ExercicesModel?>>> searchExercices(
    String searchTerm,
    String? category,
  );
}

class ExercicesRemoteDataSourceImpl extends ExercicesRemoteDataSource {
  final GraphQLService graphQLService;

  ExercicesRemoteDataSourceImpl(this.graphQLService);

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
    final categories = [];
    for (var element in data) {
      final categoriesData = element['categories'] as List;
      //if categoriesData already exists in categories, skip
      for (var category in categoriesData) {
        if (!categories.contains(category)) {
          categories.add(category);
        }
      }
    }

    return categories.fold<Map<String, List<ExercicesModel?>>>(
      {},
      (previousValue, element) {
        final filteredData = data.where((el) {
          final categories = el['categories'] as List;
          return categories.contains(element);
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
    String searchTerm,
    String? category,
  ) async {
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
}

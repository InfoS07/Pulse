
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
          exercicesGroupByCategories {
              id
              category
              exercises {
                  id
                  title
                  pod_count
                  description
                  duration
                  calories_burned
                  media {
                      url_photo
                  }
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

      final data = result.data?["exercicesGroupByCategories"] as List;

      return transformData(data.cast<Map<String, dynamic>>());
    } catch (e) {
      throw pulse_exceptions.ServerException(e.toString());
    }
  }

  Map<String, List<ExercicesModel?>> transformData(
      List<Map<String, dynamic>> data) {
    return data.fold<Map<String, List<ExercicesModel?>>>(
      {},
      (previousValue, element) {
        final category = element['category'] as String;
        final exercises = element['exercises'] as List;

        for (var exerciseData in exercises) {
          final exercice = ExercicesModel.fromJson(exerciseData);

          if (previousValue.containsKey(category)) {
            previousValue[category]!.add(exercice);
          } else {
            previousValue[category] = [exercice];
          }
        }

        return previousValue;
      },
    );
  }

  @override
  Future<Map<String, List<ExercicesModel?>>> searchExercices(
    String searchTerm,
    String? category,
  ) async {
    /* final filteredData = data.map((key, value) {
      final filteredValue = value.where((element) {
        final title = element!.title.toLowerCase();
        final search = searchTerm.toLowerCase();
        return title.contains(search);
      }).toList();
      return MapEntry(key, filteredValue);
    }); */

    final filteredData = <String, List<ExercicesModel?>>{};

    return filteredData;
  }
}

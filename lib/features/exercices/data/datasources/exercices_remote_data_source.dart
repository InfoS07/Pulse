import 'package:pulse/core/error/exceptions.dart' as pulse_exceptions;
import 'package:pulse/features/exercices/domain/models/exercices_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

abstract class ExercicesRemoteDataSource {
  Future<Map<String, List<ExercicesModel?>>> getExercices();
}

class ExercicesRemoteDataSourceImpl extends ExercicesRemoteDataSource {
  final GraphQLClient graphqlClient;

  ExercicesRemoteDataSourceImpl(this.graphqlClient);

  @override
  Future<Map<String, List<ExercicesModel?>>> getExercices() async {
    try {
      const String query = '''
        query GetExercices {
          exercises {
            id
            title
            media {
              url_photo
            }
          }
        }
      ''';

      final result = await graphqlClient.query(
        QueryOptions(
          document: gql(query),
          fetchPolicy: FetchPolicy.noCache,
        ),
      );
      print("result");
      print(result);
      if (result.hasException) {
        throw pulse_exceptions.ServerException(result.exception.toString());
      }

      final data = result.data?['exercises'] as List;
      return data.fold<Map<String, List<ExercicesModel?>>>(
        {},
        (previousValue, element) {
          final exercice = ExercicesModel.fromJson(element);
          final key = exercice.id;
          if (previousValue.containsKey(key)) {
            previousValue[key]!.add(exercice);
          } else {
            previousValue[key] = [exercice];
          }
          return previousValue;
        },
      );
    } catch (e) {
      throw pulse_exceptions.ServerException(e.toString());
    }
  }
}

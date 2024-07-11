import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:pulse/core/error/exceptions.dart' as pulse_exceptions;
import 'package:pulse/core/services/graphql_service.dart';
import 'package:pulse/features/profil/domain/models/profil_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SearchUserRemoteDataSource {
  Future<List<ProfilModel?>> searchUsers(String searchTerm);
}

class SearchUserRemoteDataSourceImpl implements SearchUserRemoteDataSource {
  final GraphQLService graphQLService;

  SearchUserRemoteDataSourceImpl(this.graphQLService);

  @override
  Future<List<ProfilModel?>> searchUsers(searchTerm) async {
    try {
      String query = '''
        {
          users(query: "$searchTerm") {
            id
            uid
            last_name
            first_name
            username
            email
            birth_date
            profile_photo
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

      final data = result.data?["users"] as List;

      return data.map((e) => ProfilModel.fromJson(e)).toList();
    } catch (e) {
      throw pulse_exceptions.ServerException(e.toString());
    }
  }
}

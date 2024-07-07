import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:pulse/features/challenges_users/domain/models/challenges_users_model.dart';
import 'package:pulse/features/challenges_users/domain/repository/challenges_users_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ChallengesUsersRemoteDataSource {
  Future<List<ChallengeUserModel>> getChallengeUsers();
}

class ChallengeUserRemoteDataSourceImpl extends ChallengesUsersRemoteDataSource {
  final SupabaseClient supabaseClient;

  ChallengeUserRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<ChallengeUserModel>> getChallengeUsers() async {
    try {
      final response = await supabaseClient
        .from('challenges_users')
        .select();

        print(response);
      return (response as List)
        .map((json) => ChallengeUserModel.fromJson(json))
        .toList();

    } on PostgrestException catch (e) {
      throw ServerException();
    } catch (e) {
      throw ServerException();
    }
  }
}
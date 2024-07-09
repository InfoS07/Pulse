import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/features/profil/domain/models/profil_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ProfilRemoteDataSource {
  Future<ProfilModel?> getProfil(String userId);
  Future<List<ProfilModel?>> getFollowers(String userId);
  Future<List<ProfilModel?>> getFollowings(String userId);
}

class ProfilRemoteDataSourceImpl implements ProfilRemoteDataSource {
  final SupabaseClient supabaseClient;

  ProfilRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<ProfilModel?> getProfil(String userId) async {
    try {
      final response =
          await supabaseClient.from('users').select().eq("uid", userId);
      /* if (response.error != null) {
        throw const ServerException('Error fetching data');
      } */
      return ProfilModel.fromJson(response.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ProfilModel?>> getFollowers(String userId) async {
    try {
      // Récupérer les IDs des followers
      final response = await supabaseClient
          .from('user_followers')
          .select('user_id')
          .eq("follower_id", userId);

      final List<dynamic> followerIds =
          response.map((item) => item['user_id']).toList();

      // Récupérer les informations des utilisateurs par leurs IDs
      final userResponse = await supabaseClient
          .from('users')
          .select()
          .inFilter('uid', followerIds);

      // Retourner la liste de ProfilModel
      return ProfilModel.fromJsonList(userResponse);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ProfilModel?>> getFollowings(String userId) async {
    try {
      // Récupérer les IDs des followers
      final response = await supabaseClient
          .from('user_followers')
          .select('follower_id')
          .eq("user_id", userId);

      final List<dynamic> followerIds =
          response.map((item) => item['follower_id']).toList();
      print(followerIds);

      // Récupérer les informations des utilisateurs par leurs IDs
      final userResponse = await supabaseClient
          .from('users')
          .select()
          .inFilter('uid', followerIds);

      // Retourner la liste de ProfilModel
      return ProfilModel.fromJsonList(userResponse);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

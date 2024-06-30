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
      final response = await supabaseClient.from('users').select().eq("id", userId);
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
          .select('id_user')
          .eq("id_follower", userId);

      final List<dynamic> followerIds = response.map((item) => item['id_user']).toList();

      // Récupérer les informations des utilisateurs par leurs IDs
      final userResponse = await supabaseClient
          .from('users')
          .select()
          .inFilter('id', followerIds);

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
          .select('id_follower')
          .eq("id_user", userId);

      final List<dynamic> followerIds = response.map((item) => item['id_follower']).toList();

      // Récupérer les informations des utilisateurs par leurs IDs
      final userResponse = await supabaseClient
          .from('users')
          .select()
          .inFilter('id', followerIds);

      // Retourner la liste de ProfilModel
      return ProfilModel.fromJsonList(userResponse);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

}

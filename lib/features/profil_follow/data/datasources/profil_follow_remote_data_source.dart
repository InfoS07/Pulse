import 'dart:ffi';

import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/features/profil/domain/models/profil_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ProfilFollowRemoteDataSource {
  Future<void> Follow(String userId, String followerId);
  Future<void> Unfollow(String userId, String followerId);
}

class ProfilFollowRemoteDataSourceImpl implements ProfilFollowRemoteDataSource {
  final SupabaseClient supabaseClient;

  ProfilFollowRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<void> Follow(String userId, String followerId) async {
    try {
      final response = await supabaseClient
          .from('user_followers')
          .insert({
            'id_user': userId,
            'id_follower': followerId,
          });

      if (response.error != null) {
        throw ServerException(response.error!.message);
      }
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> Unfollow(String userId, String followerId) async {
    try {
      final response = await supabaseClient
          .from('user_followers')
          .delete()
          .eq('id_user', userId)
          .eq('id_follower', followerId);

      if (response.error != null) {
        throw ServerException(response.error!.message);
      }
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

}

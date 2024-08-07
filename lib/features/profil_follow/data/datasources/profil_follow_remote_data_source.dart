import 'package:pulse/core/error/exceptions.dart';
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
      await supabaseClient.from('user_followers').insert({
        'user_id': userId,
        'follower_id': followerId,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> Unfollow(String userId, String followerId) async {
    try {
      await supabaseClient
          .from('user_followers')
          .delete()
          .eq('user_id', userId)
          .eq('follower_id', followerId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

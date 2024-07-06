import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulse/core/common/entities/social_media_post.dart';
import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/features/home/domain/models/social_media_post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

abstract class PostsRemoteDataSource {
  Future<List<SocialMediaPost>> getPosts();
  Future<Unit> likePost(int postId);
}

class PostsRemoteDataSourceImpl implements PostsRemoteDataSource {
  final SupabaseClient supabaseClient;

  PostsRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<SocialMediaPost>> getPosts() async {
    try {
      final response = await supabaseClient
          .from('training')
          .select(
              '*,  user:users!training_author_id_fkey(*),  likes : training_like_users(* , user : users (username, profile_photo)) , comments: training_comments (* , user : users (username, profile_photo)), exercice : exercises(*)')
          .order('created_at', ascending: false);

      /* if (response.error != null) {
        throw ServerException(response.error!.message);
      }
      */

      final List<dynamic> postsData = response;

      var data = postsData.map<Future<SocialMediaPostModel>>((post) async {
        post['postImageUrls'] = <String>[];
        post["exercice"]['exerciceImageUrl'] = "";

        if (post["photos"] != null && post["photos"].length > 0) {
          final List<dynamic> photos = post["photos"];
          for (var photo in photos) {
            final String url =
                supabaseClient.storage.from('training').getPublicUrl(photo);
            post['postImageUrls'].add(url);
          }
        }

        if (post["exercice"]["photos"].length > 0) {
          final String url = supabaseClient.storage
              .from('exercises_photos')
              .getPublicUrl(post["exercice"]["photos"][0]);

          post["exercice"]['exerciceImageUrl'] = url;
        }

        final isLiked = post['likes'].any(
            (like) => like['user_id'] == supabaseClient.auth.currentUser!.id);

        post['isLiked'] = isLiked;

        return SocialMediaPostModel.fromJson(post);
      }).toList();

      return await Future.wait(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<XFile> uint8ListToXFile(Uint8List data, String filename) async {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/$filename';
    final file = await File(filePath).writeAsBytes(data);
    return XFile(file.path);
  }

  //likePost
  @override
  Future<Unit> likePost(int postId) async {
    try {
      final userId = supabaseClient.auth.currentUser!.id;

      final checkResponse = await supabaseClient
          .from('training_like_users')
          .select()
          .eq('training_id', postId)
          .eq('user_id', userId);

      /* if (checkResponse != null) {
        throw ServerException("Error checking like post");
      } */

      if (checkResponse.isNotEmpty) {
        final deleteResponse = await supabaseClient
            .from('training_like_users')
            .delete()
            .eq('training_id', postId)
            .eq('user_id', userId);

        /* if (deleteResponse != null) {
          throw ServerException(deleteResponse.error!.message);
        } */
      } else {
        final insertResponse =
            await supabaseClient.from('training_like_users').upsert({
          'training_id': postId,
          'user_id': userId,
        });

        /* if (insertResponse.error != null) {
          throw ServerException(insertResponse.error!.message);
        } */
      }
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }

    return unit;
  }
}

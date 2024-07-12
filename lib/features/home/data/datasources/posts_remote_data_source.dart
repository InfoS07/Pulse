import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulse/core/common/entities/social_media_post.dart';
import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/core/services/graphql_service.dart';
import 'package:pulse/features/home/domain/models/social_media_post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pulse/core/error/exceptions.dart' as pulse_exceptions;

abstract class PostsRemoteDataSource {
  Future<List<SocialMediaPost?>> getPosts();
  Future<Unit> likePost(int postId);
  Future<Unit> deletePost(int postId);
}

class PostsRemoteDataSourceImpl implements PostsRemoteDataSource {
  final SupabaseClient supabaseClient;
  final GraphQLService graphQLService;

  PostsRemoteDataSourceImpl(this.supabaseClient, this.graphQLService);

  @override
  Future<List<SocialMediaPost?>> getPosts() async {
    try {
      const String query = '''
        {
          trainings {
            id
            title
            description
            created_at
            start_at
            end_at
            repetitions
            exercise {
              id
              title
              description
              pod_count
              calories_burned
              photos
              categories
              photos
              sequence
            }
            stats {
                buzzer_expected
                buzzer_pressed
                reaction_time
                pressed_at
            }
            author {
                id
                uid
                last_name
                first_name
                username
                profile_photo
            }
            likes {
                user {
                  id
                  uid
                }
            }
            comments {
                id
                user {
                  id
                  uid
                  last_name
                  first_name
                  username
                  profile_photo
                  birth_date
                }
                content
                created_at
            }
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

      print(result);
      if (result.hasException) {
        throw pulse_exceptions.ServerException(result.exception.toString());
      }

      if (result.data == null) {
        throw pulse_exceptions.ServerException("No data found");
      }

      if (result.data!.isEmpty) {
        return [];
      }

      print(result);

      final postsData = result.data!["trainings"] as List<dynamic>;

      var data = postsData.map((post) {
        final isLiked = post['likes'].any((like) =>
            like['user']['uid'] == supabaseClient.auth.currentUser!.id);

        post['isLiked'] = isLiked;

        return SocialMediaPostModel.fromJson(post);
      }).toList();

      return data;
    } catch (e) {
      throw pulse_exceptions.ServerException(e.toString());
    }
  }

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
      throw pulse_exceptions.ServerException(e.message);
    } catch (e) {
      throw pulse_exceptions.ServerException(e.toString());
    }

    return unit;
  }

  @override
  Future<Unit> deletePost(int postId) async {
    try {
      print("postId: ${postId}");
      String mutation = '''
        mutation {
          deleteTraining(input: {trainingId: "${postId.toString()}"}) {
            success
            errorCode
          }
        }
      ''';

      final result = await graphQLService.client.mutate(
        MutationOptions(
          document: gql(mutation),
        ),
      );

      print("result: ${result}");
      if (result.hasException) {
        throw pulse_exceptions.ServerException(result.exception.toString());
      }

      final success = result.data?['deleteTraining']['success'] as bool;
      if (!success) {
        final errorCode = result.data?['deleteTraining']['errorCode'] as String;
        throw pulse_exceptions.ServerException('Error code: $errorCode');
      }

      return unit;
    } catch (e) {
      throw pulse_exceptions.ServerException(e.toString());
    }
  }
}

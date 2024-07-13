import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/features/profil/domain/models/profil_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ProfilRemoteDataSource {
  Future<ProfilModel?> getProfil(String userId);
  Future<List<ProfilModel?>> getFollowers(String userId);
  Future<List<ProfilModel?>> getFollowings(String userId);
  Future<void> updateUser({
    required String userId,
    required String firstName,
    required String lastName,
    XFile? photo,
  });
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
  Future<void> updateUser({
    required String userId,
    required String firstName,
    required String lastName,
    XFile? photo,
  }) async {
    try {
      var response;
      if (photo != null) {
        final file = await _xFileToFile(photo);
        final fileName = _getUniqueFileName(photo);

        final uploadResponse = await supabaseClient.storage
            .from('training')
            .upload(fileName, file);

        response = await supabaseClient.from('users').update({
          'first_name': firstName,
          'last_name': lastName,
          'photo_url': fileName,
        }).eq('uid', userId);
      } else {
        response = await supabaseClient.from('users').update({
          'first_name': firstName,
          'last_name': lastName,
        }).eq('uid', userId);
      }

      if (response != null) {
        throw const ServerException('Erreur lors de la modification du profil');
      }
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<File> _xFileToFile(XFile xFile) async {
    final bytes = await xFile.readAsBytes();
    final file = File(xFile.path);
    await file.writeAsBytes(bytes);
    return file;
  }

  String _getUniqueFileName(XFile xFile) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileExtension = xFile.path.split('.').last;
    return 'training_$timestamp.$fileExtension';
  }
}

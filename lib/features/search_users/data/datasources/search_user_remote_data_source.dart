import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/features/profil/domain/models/profil_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

abstract class SearchUserRemoteDataSource {
  Future<List<ProfilModel?>> searchUsers(String searchTerm);
}

class SearchUserRemoteDataSourceImpl implements SearchUserRemoteDataSource {
  final SupabaseClient supabaseClient;

  SearchUserRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<ProfilModel?>> searchUsers(searchTerm) async {
    try {
      final response = await supabaseClient.from('users').select().or(
          'username.ilike.%$searchTerm%,first_name.ilike.%$searchTerm%,last_name.ilike.%$searchTerm%');
      /* if (response.error != null) {
        throw const ServerException('Error fetching data');
      } */

      return response.map((e) => ProfilModel.fromJson(e)).toList();
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
}

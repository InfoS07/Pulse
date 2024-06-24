import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/features/profil/domain/models/profil_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ProfilRemoteDataSource {
  Future<ProfilModel?> getProfil();
}

class ProfilRemoteDataSourceImpl implements ProfilRemoteDataSource {
  final SupabaseClient supabaseClient;

  ProfilRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<ProfilModel?> getProfil() async {
    try {
      final response = await supabaseClient.from('users').select().eq("id", 1);
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
}

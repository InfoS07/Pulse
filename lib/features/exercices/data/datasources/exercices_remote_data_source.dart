import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/features/exercices/domain/models/exercices_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ExercicesRemoteDataSource {
  Future<List<ExercicesModel?>> getExercices();
}

class ExercicesRemoteDataSourceImpl extends ExercicesRemoteDataSource {
  final SupabaseClient supabaseClient;

  ExercicesRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<ExercicesModel?>> getExercices() async {
    try {
      final response = await supabaseClient.from('exercices').select('*');
      final list = [ExercicesModel.fromJson(response.first)];
      return list;
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

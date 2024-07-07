import 'package:pulse/core/common/entities/trainingList.dart';
import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/features/list_trainings/domain/models/training_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ListTrainingsRemoteDataSource {
  Future<List<TrainingList>> getTrainings(String userId);
}

class ListTrainingsRemoteDataSourceImpl
    implements ListTrainingsRemoteDataSource {
  final SupabaseClient supabaseClient;

  ListTrainingsRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<TrainingModel>> getTrainings(String userId) async {
    try {
      final trainingResponse = await supabaseClient
          .from('training')
          .select()
          .eq('author_id', userId);

      // Retourner la liste de TrainingModel
      return TrainingModel.fromJsonList(trainingResponse);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

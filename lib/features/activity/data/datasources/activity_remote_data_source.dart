import 'package:pulse/core/common/entities/training.dart';
import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/features/activity/domain/models/training_model.dart';
import 'package:pulse/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:pulse/features/profil/domain/models/profil_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ActivityRemoteDataSource {
  Future<Training> saveActivity(Training training);
}

class ActivityRemoteDataSourceImpl implements ActivityRemoteDataSource {
  final SupabaseClient supabaseClient;

  ActivityRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<Training> saveActivity(training) async {
    try {
      final response = await supabaseClient.from('training').insert([
        {
          "title": training.description,
          'description': training.description,
        }
      ]);
      return training;
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

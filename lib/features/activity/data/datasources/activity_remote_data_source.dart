import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:pulse/core/common/entities/training.dart';
import 'package:pulse/core/error/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ActivityRemoteDataSource {
  Future<Training> saveActivity(Training training);
}

class ActivityRemoteDataSourceImpl implements ActivityRemoteDataSource {
  final SupabaseClient supabaseClient;

  ActivityRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<Training> saveActivity(Training training) async {
    try {
      // Upload photos
      var photosFileName = <String>[];
      for (var photo in training.photos) {
        final file = await _xFileToFile(photo);
        final fileName = _getUniqueFileName(photo);
        photosFileName.add(fileName);

        final uploadResponse = await supabaseClient.storage
            .from('training')
            .upload(fileName, file);

        if (uploadResponse == null) {
          throw ServerException(uploadResponse);
        }
      }

      final response = await supabaseClient.from('training').insert([
        {
          "title": training.description,
          'description': training.description,
          'status': 'Terminé',
          'start_at': training.activity.startAt.toIso8601String(),
          'end_at': training.activity.endAt.toIso8601String(),
          'status': 'Terminé',
          'author_id': supabaseClient.auth.currentSession?.user.id,
          'photos': photosFileName,
        }
      ]);

      return training;
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

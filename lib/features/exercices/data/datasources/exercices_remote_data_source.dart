import 'dart:ffi';

import 'package:pulse/core/common/entities/user.dart';
import 'package:pulse/core/error/exceptions.dart' as pulse_exceptions;
import 'package:pulse/features/exercices/domain/models/exercices_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

abstract class ExercicesRemoteDataSource {
  Future<Map<String, List<ExercicesModel?>>> getExercices();
  Future<Map<String, List<ExercicesModel?>>> getExercicesExample();
  Future<Map<String, List<ExercicesModel?>>> searchExercices(
    String searchTerm,
    String? category,
  );
}

class ExercicesRemoteDataSourceImpl extends ExercicesRemoteDataSource {
  final GraphQLClient graphqlClient;
  final data = <String, List<ExercicesModel?>>{
    'Recommandation': [
      ExercicesModel(
        id: '1',
        title: 'Pompes classiques',
        urlPhoto:
            'https://images.pexels.com/photos/28080/pexels-photo.jpg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
        description: 'Faites des pompes classiques avec une bonne posture.',
        duration: 10,
        sequence: [],
        repetitions: 15,
        podCount: 10,
        playerCount: 10,
        durationOneRepetition: 30,
        caloriesBurned: 100,
        score: 10.0,
        level: "Débutant",
        laps: 1,
      ),
      ExercicesModel(
        id: '2',
        title: 'Squats',
        urlPhoto:
            'https://images.pexels.com/photos/416809/pexels-photo-416809.jpeg?auto=compress&cs=tinysrgb&w=600',
        description: 'Faites des squats en maintenant le dos droit.',
        duration: 10,
        sequence: [],
        repetitions: 20,
        podCount: 10,
        playerCount: 10,
        durationOneRepetition: 40,
        caloriesBurned: 150,
        score: 9.5,
        level: "Intermédiaire",
        laps: 1,
      ),
      ExercicesModel(
        id: '3',
        title: 'Fentes',
        urlPhoto:
            'https://images.pexels.com/photos/28080/pexels-photo.jpg?auto=compress&cs=tinysrgb&w=600',
        description: 'Alternez les fentes avant avec une bonne posture.',
        duration: 10,
        sequence: [],
        repetitions: 15,
        podCount: 10,
        playerCount: 10,
        durationOneRepetition: 45,
        caloriesBurned: 120,
        score: 9.0,
        level: "Avancé",
        laps: 1,
      ),
      ExercicesModel(
        id: '4',
        title: 'Planche',
        urlPhoto:
            'https://images.pexels.com/photos/221210/pexels-photo-221210.jpeg?auto=compress&cs=tinysrgb&w=600',
        description:
            'Tenez la position de la planche aussi longtemps que possible.',
        duration: 5,
        sequence: [],
        repetitions: 1,
        podCount: 10,
        playerCount: 10,
        durationOneRepetition: 60,
        caloriesBurned: 50,
        score: 8.5,
        level: "Intermédiaire",
        laps: 1,
      ),
    ],
    'Cardio': [
      ExercicesModel(
        id: '5',
        title: 'Course à pied',
        urlPhoto:
            'https://images.pexels.com/photos/239520/pexels-photo-239520.jpeg?auto=compress&cs=tinysrgb&w=600',
        description: 'Courez à une allure modérée pendant 30 minutes.',
        duration: 30,
        sequence: [],
        repetitions: 1,
        podCount: 10,
        playerCount: 10,
        durationOneRepetition: 1800,
        caloriesBurned: 300,
        score: 9.0,
        level: "Intermédiaire",
        laps: 1,
      ),
      ExercicesModel(
        id: '6',
        title: 'Sauts à la corde',
        urlPhoto:
            'https://images.pexels.com/photos/1130626/pexels-photo-1130626.jpeg?auto=compress&cs=tinysrgb&w=600',
        description: 'Faites des sauts à la corde pendant 10 minutes.',
        duration: 10,
        sequence: [],
        repetitions: 1,
        podCount: 10,
        playerCount: 10,
        durationOneRepetition: 600,
        caloriesBurned: 200,
        score: 9.5,
        level: "Débutant",
        laps: 1,
      ),
      ExercicesModel(
        id: '7',
        title: 'Montées de genoux',
        urlPhoto:
            'https://images.pexels.com/photos/416809/pexels-photo-416809.jpeg?auto=compress&cs=tinysrgb&w=600',
        description: 'Alternez les montées de genoux à un rythme rapide.',
        duration: 5,
        sequence: [],
        repetitions: 50,
        podCount: 10,
        playerCount: 10,
        durationOneRepetition: 60,
        caloriesBurned: 100,
        score: 8.5,
        level: "Avancé",
        laps: 1,
      ),
      ExercicesModel(
        id: '8',
        title: 'Burpees',
        urlPhoto:
            'https://images.pexels.com/photos/239520/pexels-photo-239520.jpeg?auto=compress&cs=tinysrgb&w=600',
        description: 'Enchaînez les burpees en maintenant une bonne technique.',
        duration: 5,
        sequence: [],
        repetitions: 15,
        podCount: 10,
        playerCount: 10,
        durationOneRepetition: 90,
        caloriesBurned: 150,
        score: 8.0,
        level: "Intermédiaire",
        laps: 1,
      ),
    ],
    'Musculation': [
      ExercicesModel(
        id: '9',
        title: 'Développé couché',
        urlPhoto:
            'https://images.pexels.com/photos/416809/pexels-photo-416809.jpeg?auto=compress&cs=tinysrgb&w=600',
        description: 'Exercice pour les pectoraux avec haltères.',
        duration: 10,
        sequence: [],
        repetitions: 12,
        podCount: 10,
        playerCount: 10,
        durationOneRepetition: 30,
        caloriesBurned: 120,
        score: 9.0,
        level: "Débutant",
        laps: 1,
      ),
      ExercicesModel(
        id: '10',
        title: 'Curl biceps',
        urlPhoto:
            'https://images.pexels.com/photos/104827/cat-pet-animal-domestic-104827.jpeg?auto=compress&cs=tinysrgb&w=600',
        description: 'Faites des curls pour travailler les biceps.',
        duration: 10,
        sequence: [],
        repetitions: 15,
        podCount: 10,
        playerCount: 10,
        durationOneRepetition: 40,
        caloriesBurned: 100,
        score: 8.5,
        level: "Intermédiaire",
        laps: 1,
      ),
      ExercicesModel(
        id: '11',
        title: 'Tractions',
        urlPhoto:
            'https://images.pexels.com/photos/239520/pexels-photo-239520.jpeg?auto=compress&cs=tinysrgb&w=600',
        description:
            'Effectuez des tractions pour renforcer le dos et les bras.',
        duration: 5,
        sequence: [],
        repetitions: 10,
        podCount: 10,
        playerCount: 10,
        durationOneRepetition: 45,
        caloriesBurned: 80,
        score: 9.5,
        level: "Avancé",
        laps: 1,
      ),
      ExercicesModel(
        id: '12',
        title: 'Extensions triceps',
        urlPhoto:
            'https://images.pexels.com/photos/221210/pexels-photo-221210.jpeg?auto=compress&cs=tinysrgb&w=600',
        description: 'Travaillez les triceps avec des extensions.',
        duration: 10,
        sequence: [],
        repetitions: 12,
        podCount: 10,
        playerCount: 10,
        durationOneRepetition: 30,
        caloriesBurned: 110,
        score: 8.0,
        level: "Intermédiaire",
        laps: 1,
      ),
    ],
    "Yoga": [
      ExercicesModel(
        id: '13',
        title: 'Salutation au soleil',
        urlPhoto:
            'https://images.pexels.com/photos/104827/cat-pet-animal-domestic-104827.jpeg?auto=compress&cs=tinysrgb&w=600',
        description: 'Enchaînez les postures de la salutation au soleil.',
        duration: 10,
        sequence: [],
        repetitions: 1,
        podCount: 10,
        playerCount: 10,
        durationOneRepetition: 600,
        caloriesBurned: 100,
        score: 9.0,
        level: "Débutant",
        laps: 1,
      )
    ],
    // Ajoutez d'autres catégories ici
  };

  ExercicesRemoteDataSourceImpl(this.graphqlClient);

  @override
  Future<Map<String, List<ExercicesModel?>>> getExercicesExample() async {
    try {
      const String query = '''
        {
          exercicesGroupByCategories {
              id
              category
              exercises {
                  id
                  title
                  pod_count
                  description
                  duration
                  calories_burned
                  media {
                      url_photo
                  }
              }
          }
        }
      ''';

      final result = await graphqlClient.query(
        QueryOptions(
          document: gql(query),
          fetchPolicy: FetchPolicy.noCache,
        ),
      );
      print("result");
      print(result);

      if (result.hasException) {
        throw pulse_exceptions.ServerException(result.exception.toString());
      }

      final data = result.data?["exercicesGroupByCategories"] as List;

      print("data");
      print(data);

      return transformData(data.cast<Map<String, dynamic>>());
    } catch (e) {
      throw pulse_exceptions.ServerException(e.toString());
    }
  }

  Map<String, List<ExercicesModel?>> transformData(
      List<Map<String, dynamic>> data) {
    return data.fold<Map<String, List<ExercicesModel?>>>(
      {},
      (previousValue, element) {
        final category = element['category'] as String;
        final exercises = element['exercises'] as List;

        for (var exerciseData in exercises) {
          final exercice = ExercicesModel.fromJson(exerciseData);

          if (previousValue.containsKey(category)) {
            previousValue[category]!.add(exercice);
          } else {
            previousValue[category] = [exercice];
          }
        }

        return previousValue;
      },
    );
  }

  @override
  Future<Map<String, List<ExercicesModel?>>> getExercices() async {
    return data;
  }

  @override
  Future<Map<String, List<ExercicesModel?>>> searchExercices(
    String searchTerm,
    String? category,
  ) async {
    final filteredData = data.map((key, value) {
      final filteredValue = value.where((element) {
        final title = element!.title.toLowerCase();
        final search = searchTerm.toLowerCase();
        return title.contains(search);
      }).toList();
      return MapEntry(key, filteredValue);
    });

    print(filteredData);

    return filteredData;
  }
}

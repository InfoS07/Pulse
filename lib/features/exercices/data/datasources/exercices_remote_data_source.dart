import 'dart:ffi';

import 'package:pulse/core/common/entities/user.dart';
import 'package:pulse/core/error/exceptions.dart' as pulse_exceptions;
import 'package:pulse/features/exercices/domain/models/exercices_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

abstract class ExercicesRemoteDataSource {
  Future<Map<String, List<ExercicesModel?>>> getExercices();
  Future<Map<String, List<ExercicesModel?>>> getExercicesExample();
}

class ExercicesRemoteDataSourceImpl extends ExercicesRemoteDataSource {
  final GraphQLClient graphqlClient;

  ExercicesRemoteDataSourceImpl(this.graphqlClient);

  @override
  Future<Map<String, List<ExercicesModel?>>> getExercicesExample() async {
    try {
      const String query = '''
        query GetExercices {
          exercises {
            id
            title
            media {
              url_photo
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

      if (result.hasException) {
        throw pulse_exceptions.ServerException(result.exception.toString());
      }

      final data = result.data?['exercises'] as List;
      return data.fold<Map<String, List<ExercicesModel?>>>(
        {},
        (previousValue, element) {
          final exercice = ExercicesModel.fromJson(element);
          final key = exercice.id;
          if (previousValue.containsKey(key)) {
            previousValue[key]!.add(exercice);
          } else {
            previousValue[key] = [exercice];
          }
          return previousValue;
        },
      );
    } catch (e) {
      throw pulse_exceptions.ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, List<ExercicesModel?>>> getExercices() async {
    return <String, List<ExercicesModel?>>{
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
          author: User.empty(),
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
          author: User.empty(),
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
          author: User.empty(),
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
          author: User.empty(),
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
          author: User.empty(),
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
          author: User.empty(),
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
          author: User.empty(),
          level: "Avancé",
          laps: 1,
        ),
        ExercicesModel(
          id: '8',
          title: 'Burpees',
          urlPhoto:
              'https://images.pexels.com/photos/239520/pexels-photo-239520.jpeg?auto=compress&cs=tinysrgb&w=600',
          description:
              'Enchaînez les burpees en maintenant une bonne technique.',
          duration: 5,
          sequence: [],
          repetitions: 15,
          podCount: 10,
          playerCount: 10,
          durationOneRepetition: 90,
          caloriesBurned: 150,
          score: 8.0,
          author: User.empty(),
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
          author: User.empty(),
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
          author: User.empty(),
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
          author: User.empty(),
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
          author: User.empty(),
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
          author: User.empty(),
          level: "Débutant",
          laps: 1,
        )
      ],
      // Ajoutez d'autres catégories ici
    };
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/widgets/exercise_card.dart';

class ExercicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercices'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildExerciseList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Recherche',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _buildExerciseList(BuildContext context) {
    final exercises = {
      'Recommandés': [
        {
          'title': 'Squat touch press',
          'people': 1,
          'pods': 4,
          'image':
              'https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg?auto=compress&cs=tinysrgb&w=600'
        },
        {
          'title': 'Squat touch press',
          'people': 2,
          'pods': 4,
          'image':
              'https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg?auto=compress&cs=tinysrgb&w=600'
        },
        {
          'title': 'Squat touch press',
          'people': 3,
          'pods': 4,
          'image':
              'https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg?auto=compress&cs=tinysrgb&w=600'
        },
      ],
      'Cardio': [
        {
          'title': 'Squat touch press',
          'people': 3,
          'pods': 4,
          'image':
              'https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg?auto=compress&cs=tinysrgb&w=600'
        },
        // Ajoutez d'autres exercices ici
      ],
      'Musculation': [
        {
          'title': 'Squat touch press',
          'people': 3,
          'pods': 4,
          'image':
              'https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg?auto=compress&cs=tinysrgb&w=600'
        },
        // Ajoutez d'autres exercices ici
      ],
      // Ajoutez d'autres catégories ici
    };

    return ListView(
      children: exercises.entries.map((category) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                category.key,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: category.value.map<Widget>((exercise) {
                  return ExerciseCard(
                    exercise: exercise,
                    onTap: () {
                      context.push('/exercices/details', extra: exercise);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

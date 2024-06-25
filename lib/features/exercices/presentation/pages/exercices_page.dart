import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/common/widgets/exercise_card.dart';
import 'package:pulse/features/exercices/presentation/bloc/exercices_bloc.dart';

class ExercicesPage extends StatefulWidget {
  @override
  _ExercicesPageState createState() => _ExercicesPageState();
}

class _ExercicesPageState extends State<ExercicesPage> {
  @override
  void initState() {
    super.initState();
    context.read<ExercicesBloc>().add(ExercicesLoad());
  }

  Future<void> _refreshExercises() async {
    context.read<ExercicesBloc>().add(ExercicesLoad());
  }

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
            Expanded(
              child: BlocConsumer<ExercicesBloc, ExercicesState>(
                listener: (context, state) {
                  if (state is ExercicesError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ExercicesLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is ExercicesLoaded) {
                    return RefreshIndicator(
                      onRefresh: _refreshExercises,
                      child: _buildExerciseList(
                          context, state.exercisesByCategory),
                    );
                  } else if (state is ExercicesEmpty) {
                    return Center(child: Text('No exercises available'));
                  }
                  return Center(child: Text('Start loading exercises...'));
                },
              ),
            ),
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

  Widget _buildExerciseList(
      BuildContext context, Map<String, List<Exercice?>> exercisesByCategory) {
    return ListView(
      children: exercisesByCategory.entries.map((category) {
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
                  if (exercise != null) {
                    return ExerciseCard(
                      exercise: exercise,
                      onTap: () {
                        context.push('/exercices/details/${exercise.id}',
                            extra: exercise);
                      },
                    );
                  }
                  return SizedBox();
                }).toList(),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

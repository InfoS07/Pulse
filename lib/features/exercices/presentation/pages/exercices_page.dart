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
  String? selectedCategory;
  final List<String> categories = ['Cardio', 'Force', 'Souplesse', 'Équilibre'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ExercicesBloc>().add(ExercicesLoad());
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshExercises() async {
    context.read<ExercicesBloc>().add(ExercicesLoad());
  }

  void _onCategorySelected(String? category) {
    setState(() {
      selectedCategory = category;
    });
    _triggerSearch();
  }

  void _onSearchChanged() {
    _triggerSearch();
  }

  void _triggerSearch() {
    final searchTerm = _searchController.text;
    final category = selectedCategory;
    context.read<ExercicesBloc>().add(ExercicesSearch(searchTerm, category));
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
                  return RefreshIndicator(
                    onRefresh: _refreshExercises,
                    child: ListView(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 2),
                        Center(
                            child: Text('Pull down to refresh exercises...')),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 40, // Adjust the height to make the TextField smaller
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Recherche',
                prefixIcon: const Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(
                    vertical: 8.0), // Adjust the padding as needed
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<String>(
          icon: const Icon(Icons.more_vert),
          hint: const Text('Options'),
          value: selectedCategory,
          items: categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: _onCategorySelected,
        ),
      ],
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
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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

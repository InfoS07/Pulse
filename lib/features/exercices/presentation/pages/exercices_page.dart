import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/common/widgets/exercise_card.dart';
import 'package:pulse/core/common/widgets/search_input.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/features/exercices/presentation/bloc/exercices_bloc.dart';
import 'package:pulse/features/home/presentation/widgets/filter_button.dart';

class ExercicesPage extends StatefulWidget {
  const ExercicesPage({super.key});

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
        title: const Text('Exercices'),
        scrolledUnderElevation: 0,
        backgroundColor: AppPallete.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildSearchBar(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SearchInput(
                controller: _searchController,
                placeholder: 'Rechercher un exercice',
              ),
            ),
            /* SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    FilterButton(
                      text: 'Tout',
                      isSelected: true, //state.filter == 'Tout',
                      onTap: () {
                        /* BlocProvider.of<HomeBloc>(context)
                            .add(FilterPosts('Tout')); */
                      },
                    ),
                    SizedBox(width: 16),
                    FilterButton(
                      text: 'Moi',
                      isSelected: true, //state.filter == 'Moi',
                      onTap: () {},
                    ),
                    SizedBox(width: 16),
                    FilterButton(
                      text: 'Abonné',
                      isSelected: true, //state.filter == 'Abonné',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ), */
            Container(
              padding: EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  FilterButton(
                    text: 'Tout',
                    isSelected: true, //state.filter == 'Tout',
                    onTap: () {
                      /* BlocProvider.of<HomeBloc>(context)
                            .add(FilterPosts('Tout')); */
                    },
                  ),
                  SizedBox(width: 16),
                  FilterButton(
                    text: 'Moi',
                    isSelected: false, //state.filter == 'Moi',
                    onTap: () {},
                  ),
                  SizedBox(width: 16),
                  FilterButton(
                    text: 'Abonné',
                    isSelected: false, //state.filter == 'Abonné',
                    onTap: () {},
                  ),
                ],
              ),
            ),
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
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ExercicesLoaded) {
                    return RefreshIndicator(
                      onRefresh: _refreshExercises,
                      child: _buildExerciseList(
                          context, state.exercisesByCategory),
                    );
                  } else if (state is ExercicesEmpty) {
                    return const Center(child: Text('Aucun exercice trouvé.'));
                  } else if (state is ExercicesError) {
                    return _buildErrorScreen(context, state.message);
                  }

                  return const Center(child: Text('Chargement des exercices'));
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
        /* Expanded(
          child: SizedBox(
            height: 40, // Adjust the height to make the TextField smaller
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Recherche',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 8.0), // Adjust the padding as needed
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ), */
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
                  return const SizedBox();
                }).toList(),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Impossible de charger cette page.',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _refreshExercises();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.primaryColor, // Couleur du bouton
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, color: Colors.black),
                SizedBox(width: 8),
                Text(
                  'Réessayer',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

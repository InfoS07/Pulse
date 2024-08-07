import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/analytics.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/common/widgets/exercise_card.dart';
import 'package:pulse/core/common/widgets/search_input.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/features/challenges/presentation/bloc/challenges_bloc.dart';
import 'package:pulse/features/exercices/presentation/bloc/exercices_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toasty_box.dart';

class ExercicesPage extends StatefulWidget {
  const ExercicesPage({super.key});

  @override
  _ExercicesPageState createState() => _ExercicesPageState();
}

class _ExercicesPageState extends State<ExercicesPage> {
  final TextEditingController _searchController = TextEditingController();

  String? userId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AppUserCubit>().state;
    if (authState is AppUserLoggedIn) {
      userId = authState.user.uid;
    }
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
    _triggerSearch();
  }

  void _onSearchChanged() {
    _triggerSearch();
  }

  void _triggerSearch() {
    final searchTerm = _searchController.text;
    context.read<ExercicesBloc>().add(ExercicesSearch(searchTerm));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercices'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SearchInput(
                controller: _searchController,
                placeholder: 'Rechercher un exercice',
              ),
            ),
            Expanded(
              child: BlocConsumer<ExercicesBloc, ExercicesState>(
                listener: (context, state) {
                  if (state is ExercicesError) {
                    ToastService.showErrorToast(
                      context,
                      length: ToastLength.long,
                      expandedHeight: 100,
                      message: state.message,
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ExercicesLoading) {
                    return RefreshIndicator(
                      onRefresh: _refreshExercises,
                      child: _buildShimmerEffect(),
                    );
                  } else if (state is ExercicesLoaded) {
                    return RefreshIndicator(
                      onRefresh: _refreshExercises,
                      child: _buildExerciseList(
                          context, state.exercisesByCategory),
                    );
                  } else if (state is ExercicesEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage('assets/images/search.png'),
                            width: 150,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Aucun exercice trouvé',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    );
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

  Widget _buildExerciseList(
      BuildContext context, Map<String, List<Exercice?>> exercisesByCategory) {
    return ListView(
      children: exercisesByCategory.entries.map((category) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
              child: Text(
                category.key,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: _buildExerciseRows(category.value),
            ),
            const SizedBox(height: 30),
          ],
        );
      }).toList(),
    );
  }

  List<Widget> _buildExerciseRows(List<Exercice?> exercises) {
    List<Widget> rows = [];
    for (int i = 0; i < exercises.length; i += 5) {
      rows.add(
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: exercises
                .sublist(i, i + 5 > exercises.length ? exercises.length : i + 5)
                .map((exercise) {
              if (exercise != null) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ExerciseCard(
                    isLocked: exercise.price > 0 &&
                        !exercise.premiums.contains(userId),
                    exercise: exercise,
                    onTap: () {
                      AnalyticsManager.of(context).logEvent(
                          name: "press_exercice",
                          parameters: {'exerice_title': exercise.title});
                      context.push('/exercices/details/${exercise.id}',
                          extra: exercise);
                    },
                    onLockedTap: () => _showPurchaseDialog(context, exercise),
                  ),
                );
              }
              return const SizedBox();
            }).toList(),
          ),
        ),
      );
    }
    return rows;
  }

  List<Widget> _buildExerciseRowsShimmer(List<Exercice?> exercises) {
    List<Widget> rows = [];
    for (int i = 0; i < exercises.length; i += 5) {
      rows.add(
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: exercises
                .sublist(i, i + 5 > exercises.length ? exercises.length : i + 5)
                .map((exercise) {
              if (exercise != null) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ExerciseCardShimmer(),
                );
              }
              return const SizedBox();
            }).toList(),
          ),
        ),
      );
    }
    return rows;
  }

  Widget _buildShimmerEffect() {
    final exercisesByCategory = {
      "test": [
        Exercice.empty(),
        Exercice.empty(),
        Exercice.empty(),
        Exercice.empty(),
        Exercice.empty(),
        Exercice.empty(),
        Exercice.empty(),
        Exercice.empty(),
        Exercice.empty(),
        Exercice.empty(),
        Exercice.empty(),
        Exercice.empty(),
        Exercice.empty(),
        Exercice.empty(),
        Exercice.empty()
      ],
      "test2": [
        Exercice.empty(),
        Exercice.empty(),
        Exercice.empty(),
        Exercice.empty(),
        Exercice.empty()
      ],
      "test3": [Exercice.empty(), Exercice.empty(), Exercice.empty()]
    };

    return ListView(
      children: exercisesByCategory.entries.map((category) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
              child: Shimmer.fromColors(
                baseColor: Colors.white,
                highlightColor: Colors.grey,
                child: Container(
                  height: 28,
                  width: 100,
                  color: Colors.grey[300],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: _buildExerciseRowsShimmer(category.value),
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
            onPressed: _refreshExercises,
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

  void _showPurchaseDialog(BuildContext context, Exercice exercise) {
    showDialog(
      context: context,
      builder: (context) {
        return BlocProvider.value(
          value: context.read<ExercicesBloc>(),
          child: BlocListener<ExercicesBloc, ExercicesState>(
            listener: (context, state) {
              if (state is ExercicesError) {
                ToastService.showErrorToast(
                  context,
                  length: ToastLength.long,
                  expandedHeight: 100,
                  message: state.message,
                );
              }
            },
            child: AlertDialog(
              title: const Text('Acheter exercice'),
              content: Text(
                  'Voulez-vous acheter cet exercice pour ${exercise.price} points ?'),
              actions: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Annuler'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ExercicesBloc>().add(AchatExercice(
                              exercise.id, userId!, exercise.price));
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPallete.primaryColor,
                        ),
                        child: const Text(
                          'Acheter',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

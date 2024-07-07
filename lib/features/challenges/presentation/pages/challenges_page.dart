import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/core/utils/bottom_sheet.dart';
import 'package:pulse/features/challenges/domain/models/challenges_model.dart';
import 'package:pulse/features/challenges/presentation/bloc/challenges_bloc.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/features/challenges_users/presentation/pages/challenges_users_page.dart';
import 'package:pulse/features/exercices/presentation/bloc/exercices_bloc.dart';

class GroupPage extends StatefulWidget {
  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  String? userId;

  @override
  void initState() {
    super.initState();
    // Retrieve the logged-in user's ID
    final authState = context.read<AppUserCubit>().state;
    if (authState is AppUserLoggedIn) {
      userId = authState.user.uid;
      // Fetch challenges and exercises after userId is set
      context.read<ChallengesBloc>().add(ChallengesGetChallenges());
      context.read<ExercicesBloc>().add(ExercicesLoad()); // Load exercises
    }
  }

  Future<void> _refreshChallenges() async {
    context.read<ChallengesBloc>().add(ChallengesGetChallenges());
    context.read<ExercicesBloc>().add(ExercicesLoad()); // Refresh exercises
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Challenges'),
          bottom: const TabBar(
            indicatorColor: AppPallete.primaryColor,
            indicatorWeight: 3.0,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(
                child: Text(
                  'Challenges',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  'Défis',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        body: userId == null
            ? Center(child: CircularProgressIndicator())
            : MultiBlocListener(
                listeners: [
                  BlocListener<ChallengesBloc, ChallengesState>(
                    listener: (context, state) {
                      if (state is ChallengesError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${state.message}')),
                        );
                      }
                    },
                  ),
                  BlocListener<ExercicesBloc, ExercicesState>(
                    listener: (context, state) {
                      if (state is ExercicesError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${state.message}')),
                        );
                      }
                    },
                  ),
                ],
                child: BlocBuilder<ChallengesBloc, ChallengesState>(
                  builder: (context, state) {
                    if (state is ChallengesLoading) {
                      print("Loading");
                      return Center(child: CircularProgressIndicator());
                    } else if (state is ChallengesError) {
                      print("Error");
                      return Center(child: Text('Error: ${state.message}'));
                    } else if (state is ChallengesSuccess) {
                      print("Success");
                      List<ChallengesModel?> allChallenges =
                          _mapChallenges(state.challenges, false);

                      return TabBarView(
                        children: [
                          RefreshIndicator(
                            onRefresh: _refreshChallenges,
                            child: _buildChallengeGrid(allChallenges),
                          ),
                          //Center(child: Text('Autres Challenges à venir...')), // Placeholder for future implementation
                          ChallengeUserPage()
                        ],
                      );
                    } else {
                      return Center(child: Text('No Challenges'));
                    }
                  },
                ),
              ),
      ),
    );
  }

  List<ChallengesModel?> _mapChallenges(
      List<ChallengesModel?> challenges, bool isInProgress) {
    if (!isInProgress) {
      // Return challenges with time remaining greater than 0
      return challenges.where((challenge) {
        final timeRemaining = challenge!.endAt!.difference(DateTime.now());
        return timeRemaining.inSeconds > 0;
      }).toList();
    }

    return challenges.where((challenge) {
      final isParticipant = challenge?.participants?.contains(userId!) ?? false;
      final isAchiever = challenge?.achievers?.contains(userId!) ?? false;
      final timeRemaining = challenge!.endAt!.difference(DateTime.now());
      return isParticipant && !isAchiever && timeRemaining.inSeconds > 0;
    }).toList();
  }

  Widget _buildChallengeGrid(List<ChallengesModel?> challenges) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          final challenge = challenges[index];
          return _buildChallengeCard(challenge!);
        },
      ),
    );
  }

  Widget _buildChallengeCard(ChallengesModel challenge) {
    final isParticipant = challenge.participants?.contains(userId!) ?? false;
    final isAchiever = challenge.achievers?.contains(userId!) ?? false;
    String status;
    Color statusColor;
    Color buttonColor = AppPallete.primaryColorFade;
    Color iconColor = Colors.white;

    if (isAchiever) {
      status = 'Terminé';
      statusColor = AppPallete.primaryColor;
    } else if (isParticipant) {
      status = '';
      statusColor = AppPallete.primaryColorFade;
    } else {
      status = 'Accepter';
      statusColor = AppPallete.primaryColor;
    }

    return GestureDetector(
      onTap: () {
        _showChallengeDetailsBottomSheet(context, challenge);
      },
      child: Card(
        color: Colors.black,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white, width: 0.5),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                challenge.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: Text(
                  challenge.description,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!isParticipant && !isAchiever) ...[
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<ChallengesBloc>()
                            .add(JoinChallenge(challenge.id, userId!));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: statusColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 8.0),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  if (isParticipant && !isAchiever) ...[
                    IconButton(
                      onPressed: () {
                        context
                            .read<ChallengesBloc>()
                            .add(QuitChallenge(challenge.id, userId!));
                      },
                      icon: Icon(Icons.exit_to_app,
                          color: AppPallete.primaryColor),
                      color: buttonColor,
                      padding: EdgeInsets.all(16.0),
                    ),
                    BlocBuilder<ExercicesBloc, ExercicesState>(
                      builder: (context, state) {
                        if (state is ExercicesLoaded) {
                          final exercise = _findExercise(
                              state.exercisesByCategory, challenge.exerciceId!);
                          if (exercise != null) {
                            return IconButton(
                              onPressed: () {
                                context.push('/activity', extra: exercise);
                              },
                              icon: Icon(Icons.play_arrow,
                                  color: AppPallete.primaryColor),
                              color: buttonColor,
                              padding: EdgeInsets.all(16.0),
                            );
                          }
                        }
                        return Container(); // Return an empty container if the exercise is not found
                      },
                    ),
                  ],
                  if (isAchiever) ...[
                    ElevatedButton(
                      onPressed: null, // bouton désactivé
                      style: ElevatedButton.styleFrom(
                        backgroundColor: statusColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 8.0),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChallengeDetailsBottomSheet(
      BuildContext context, ChallengesModel challenge) {
    final Duration timeRemaining = challenge.endAt!.difference(DateTime.now());
    final int daysRemaining = timeRemaining.inDays;
    final int points = challenge.points;

    final isParticipant = challenge.participants?.contains(userId!) ?? false;
    final isAchiever = challenge.achievers?.contains(userId!) ?? false;

    BottomSheetUtil.showCustomBottomSheet(
      context: context,
      onConfirm: () {
        if (!isParticipant && !isAchiever) {
          // Action when "Accepter" button is pressed
          context
              .read<ChallengesBloc>()
              .add(JoinChallenge(challenge.id, userId!));
        } else if (isParticipant && !isAchiever) {
          // Action when "Lancer" button is pressed
          Navigator.of(context).pop(); // Close bottom sheet
          // Navigate to Activity page
          final exerciseId = challenge.exerciceId;
          final state = context.read<ExercicesBloc>().state;
          if (state is ExercicesLoaded) {
            final exercise =
                _findExercise(state.exercisesByCategory, exerciseId!);
            if (exercise != null) {
              context.go('/activity', extra: exercise);
            }
          }
        }
      },
      onCancel: () {
        // Action when "Cancel" button is pressed (e.g., close bottom sheet)
      },
      buttonText:
          isAchiever ? 'Terminé' : (isParticipant ? 'Quitter' : 'Accepter'),
      buttonColor:
          isAchiever ? AppPallete.primaryColorFade : AppPallete.primaryColor,
      isDismissible: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                challenge.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                challenge.description,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 16),
              if (daysRemaining > 0) ...[
                Text(
                  'Temps restant: $daysRemaining jours',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                SizedBox(height: 8),
              ],
              Text(
                'Points: $points',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 24),
              if (isParticipant && !isAchiever) ...[
                ElevatedButton(
                  onPressed: () {
                    // Action when "Quitter" button is pressed
                    context
                        .read<ChallengesBloc>()
                        .add(QuitChallenge(challenge.id, userId!));
                    Navigator.of(context).pop(); // Close bottom sheet
                    _refreshChallenges(); // Refresh challenge list
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    minimumSize:
                        Size(double.infinity, 0), // Occupies full width
                  ),
                  child: Text(
                    'Quitter',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Action when "Lancer" button is pressed
                    //Navigator.of(context).pop(); // Close bottom sheet
                    // Navigate to Activity page
                    final exerciseId = challenge.exerciceId;
                    final state = context.read<ExercicesBloc>().state;
                    if (state is ExercicesLoaded) {
                      final exercise =
                          _findExercise(state.exercisesByCategory, exerciseId!);
                      if (exercise != null) {
                        context.push('/activity', extra: exercise);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    minimumSize:
                        Size(double.infinity, 0), // Occupies full width
                  ),
                  child: Text(
                    'Lancer',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
              if (!isParticipant && !isAchiever) ...[
                ElevatedButton(
                  onPressed: () {
                    // Action when "Accepter" button is pressed
                    context
                        .read<ChallengesBloc>()
                        .add(JoinChallenge(challenge.id, userId!));
                    Navigator.of(context).pop(); // Close bottom sheet
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    minimumSize:
                        Size(double.infinity, 0), // Occupies full width
                  ),
                  child: Text(
                    'Accepter',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
              if (isAchiever) ...[
                ElevatedButton(
                  onPressed: null, // Button disabled
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.primaryColorFade,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    minimumSize:
                        Size(double.infinity, 0), // Occupies full width
                  ),
                  child: Text(
                    'Terminé',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // New method to find the exercise by ID in the map of categories
  Exercice? _findExercise(
      Map<String, List<Exercice?>> exercisesByCategory, int exerciseId) {
    for (var category in exercisesByCategory.values) {
      for (var exercise in category) {
        if (exercise?.id == exerciseId.toString()) {
          return exercise;
        }
      }
    }
    return null;
  }
}

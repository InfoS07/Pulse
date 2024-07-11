import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/core/utils/bottom_sheet.dart';
import 'package:pulse/features/challenges_users/domain/models/challenges_users_model.dart';
import 'package:pulse/features/challenges_users/presentation/bloc/challenges_users_bloc.dart';
import 'package:pulse/features/exercices/presentation/bloc/exercices_bloc.dart';

class ChallengeUserPage extends StatefulWidget {
  @override
  _ChallengeUserPageState createState() => _ChallengeUserPageState();
}

class _ChallengeUserPageState extends State<ChallengeUserPage> {
  String? userId;
  BuildContext? bottomSheetContext;

  @override
  void initState() {
    super.initState();
    // Retrieve the logged-in user's ID and fetch challenges users
    final authState = context.read<AppUserCubit>().state;
    if (authState is AppUserLoggedIn) {
      userId = authState.user.uid;
      context.read<ChallengesUsersBloc>().add(ChallengesUsersGetChallenges());
      context.read<ExercicesBloc>().add(ExercicesLoad());
    }
  }

  Future<void> _refreshChallengesUsers() async {
    context.read<ChallengesUsersBloc>().add(ChallengesUsersGetChallenges());
    context.read<ExercicesBloc>().add(ExercicesLoad());
  }

  @override
  Widget build(BuildContext context) {
    return userId == null
        ? Center(child: CircularProgressIndicator())
        : MultiBlocListener(
            listeners: [
              BlocListener<ChallengesUsersBloc, ChallengesUsersState>(
                listener: (context, state) {
                  if (state is ChallengesUsersError) {
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
            child: BlocBuilder<ChallengesUsersBloc, ChallengesUsersState>(
              builder: (context, state) {
                if (state is ChallengesUsersLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is ChallengesUsersSuccess) {
                  final filteredChallenges =
                      state.challenges.where((challengeUser) {
                    return challengeUser!.invites.contains(userId);
                  }).toList();

                  return RefreshIndicator(
                    onRefresh: _refreshChallengesUsers,
                    child: filteredChallenges.isEmpty
                        ? Center(child: Text('No challenge users'))
                        : GridView.builder(
                            padding: const EdgeInsets.all(16.0),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: filteredChallenges.length,
                            itemBuilder: (context, index) {
                              final challengeUser = filteredChallenges[index];
                              return _buildChallengeUserCard(
                                  context, challengeUser!);
                            },
                          ),
                  );
                } else if (state is ChallengesUsersError) {
                  return Center(child: Text('Failed to fetch challenge users'));
                }
                return Center(child: Text('No challenge users'));
              },
            ),
          );
  }

  Widget _buildChallengeUserCard(
      BuildContext context, ChallengeUserModel challengeUser) {
    final isParticipant = challengeUser.participants.values
        .any((participant) => participant.idUser == userId);
    final isAchiever = isParticipant &&
        challengeUser.participants.values
                .firstWhere((participant) => participant.idUser == userId)
                .score >
            0;
    final isAuthor =
        challengeUser.authorId == userId; // Check if the user is the author
    String status;
    Color statusColor;
    Color buttonColor = AppPallete.primaryColorFade;

    if (isAchiever) {
      status = 'Terminé';
      statusColor = AppPallete.primaryColorFade;
    } else if (isParticipant) {
      status = '';
      statusColor = AppPallete.primaryColorFade;
    } else {
      status = 'Accepter';
      statusColor = AppPallete.primaryColor;
    }

    return GestureDetector(
      onTap: () {
        _showChallengeDetailsBottomSheet(context, challengeUser);
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
                challengeUser.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: Text(
                  challengeUser.description,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              SizedBox(height: 16),
              if (isAuthor)
                ElevatedButton(
                  onPressed: () =>
                      _showDeleteConfirmationDialog(context, challengeUser),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                  ),
                  child: Text(
                    'Supprimer',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!isParticipant && !isAchiever) ...[
                      ElevatedButton(
                        onPressed: () {
                          context.read<ChallengesUsersBloc>().add(
                              JoinChallengeEvent(challengeUser.id, userId!));
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
                          context.read<ChallengesUsersBloc>().add(
                              QuitChallengeEvent(challengeUser.id, userId!));
                        },
                        icon: Icon(Icons.exit_to_app,
                            color: AppPallete.primaryColor),
                        padding: EdgeInsets.all(16.0),
                      ),
                      BlocBuilder<ExercicesBloc, ExercicesState>(
                        builder: (context, state) {
                          if (state is ExercicesLoaded) {
                            final exercise = _findExercise(
                                state.exercisesByCategory,
                                challengeUser.trainingId);
                            if (exercise != null) {
                              return IconButton(
                                onPressed: () {
                                  context.push('/activity', extra: exercise);
                                },
                                icon: Icon(Icons.play_arrow,
                                    color: AppPallete.primaryColor),
                                color: Colors.white,
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
                        onPressed: () {
                          // Add logic to complete challenge
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
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChallengeDetailsBottomSheet(
      BuildContext context, ChallengeUserModel challengeUser) {
    final isParticipant = challengeUser.participants.values
        .any((participant) => participant.idUser == userId);
    final isAchiever = isParticipant &&
        challengeUser.participants.values
                .firstWhere((participant) => participant.idUser == userId)
                .score >
            0;
    final isAuthor =
        challengeUser.authorId == userId; // Check if the user is the author

    // Trier les participants par score décroissant
    final sortedParticipants = challengeUser.participants.values.toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    BottomSheetUtilUser.showCustomBottomSheet(
      context,
      (context) {
        bottomSheetContext = context; // Store the bottom sheet context
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                challengeUser.name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                challengeUser.description,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: sortedParticipants.length,
                  itemBuilder: (context, index) {
                    final participant = sortedParticipants[index];
                    final isOwner =
                        participant.idUser == challengeUser.authorId;
                    final isCurrentUser = participant.idUser == userId;

                    return ClipRRect(
                      borderRadius:
                          BorderRadius.circular(16), // Adjust radius as needed
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(participant.user.urlProfilePhoto),
                        ),
                        title: Row(
                          children: [
                            if (isOwner)
                              Icon(Icons.star, color: AppPallete.whiteColor),
                            SizedBox(width: 4),
                            if (isCurrentUser)
                              Text('Moi')
                            else
                              Text(
                                  '${participant.user.firstName} ${participant.user.lastName}')
                          ],
                        ),
                        trailing: Text('Score: ${participant.score}'),
                        tileColor:
                            isCurrentUser ? AppPallete.primaryColor : null,
                      ),
                    );
                  },
                ),
              ),
              if (isAuthor) ...[
                ElevatedButton(
                  onPressed: () =>
                      _showDeleteConfirmationDialog(context, challengeUser),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    minimumSize:
                        Size(double.infinity, 0), // Occupies full width
                  ),
                  child: Text(
                    'Supprimer',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ] else if (isParticipant && !isAchiever) ...[
                BlocBuilder<ExercicesBloc, ExercicesState>(
                  builder: (context, state) {
                    if (state is ExercicesLoaded) {
                      final exercise = _findExercise(
                          state.exercisesByCategory, challengeUser.trainingId);
                      if (exercise != null) {
                        return ElevatedButton(
                          onPressed: () {
                            context.push('/activity', extra: exercise);
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
                        );
                      }
                    }
                    return Container(); // Return an empty container if the exercise is not found
                  },
                ),
              ] else if (!isParticipant && !isAchiever) ...[
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<ChallengesUsersBloc>()
                        .add(JoinChallengeEvent(challengeUser.id, userId!));
                    Navigator.of(context).pop();
                    _refreshChallengesUsers();
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
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, ChallengeUserModel challengeUser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Voulez-vous vraiment supprimer ce challenge ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                context
                    .read<ChallengesUsersBloc>()
                    .add(DeleteChallengeEvent(challengeUser.id));
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
                if (bottomSheetContext != null) {
                  Navigator.of(bottomSheetContext!)
                      .pop(); // Ferme la bottom sheet
                }
                _refreshChallengesUsers(); // Rafraîchit la liste des challenges
              },
              child: Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

class BottomSheetUtilUser {
  static void showCustomBottomSheet(
      BuildContext context, WidgetBuilder builder) {
    showModalBottomSheet(
      context: context,
      builder: builder,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      isScrollControlled: false,
    );
  }
}

Exercice? _findExercise(
    Map<String, List<Exercice?>> exercisesByCategory, int exerciseId) {
  for (var category in exercisesByCategory.values) {
    for (var exercise in category) {
      if (exercise?.id == exerciseId) {
        return exercise;
      }
    }
  }
  return null;
}

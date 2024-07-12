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
        ? const Center(child: CircularProgressIndicator())
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
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ChallengesUsersSuccess) {
                  final filteredChallenges =
                      state.challenges.where((challengeUser) {
                    return challengeUser!.invites.contains(userId);
                  }).toList();

                  return RefreshIndicator(
                    onRefresh: _refreshChallengesUsers,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderSection(),
                        filteredChallenges.isEmpty
                            ? _buildErrorScreen(context, 'No challenge users')
                            : Expanded(
                                child: GridView.builder(
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
                                    final challengeUser =
                                        filteredChallenges[index];
                                    return _buildChallengeUserCard(
                                        context, challengeUser!);
                                  },
                                ),
                              ),
                      ],
                    ),
                  );
                } else if (state is ChallengesUsersError) {
                  return const Center(
                      child: Text('Failed to fetch challenge users'));
                } else if (state is ChallengesUsersEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: AssetImage('assets/images/friends.png'),
                          width: 150,
                          opacity: AlwaysStoppedAnimation(.8),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No challenges for now',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: AssetImage('assets/images/friends.png'),
                          width: 150,
                          opacity: AlwaysStoppedAnimation(.8),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Aucun défis pour le moment',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: AppPallete.backgroundColorDarker,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Défis entre amis',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vous avez fait une belle performance ?',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sélectionnez un entraîneemnt. Transformez le en défis, invitez vos amis et montrez-leur de quoi vous êtes capable !',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, // Button takes the full width
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    'Créer un défi',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Challenges disponibles',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
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
              _refreshChallengesUsers();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.primaryColor,
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
          side: const BorderSide(color: Colors.white, width: 0.5),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                challengeUser.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  challengeUser.description,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
              if (isAuthor)
                ElevatedButton(
                  onPressed: () =>
                      _showDeleteConfirmationDialog(context, challengeUser),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 8.0),
                  ),
                  child: const Text(
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 8.0),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
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
                        icon: const Icon(Icons.exit_to_app,
                            color: AppPallete.primaryColor),
                        padding: const EdgeInsets.all(16.0),
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
                                icon: const Icon(Icons.play_arrow,
                                    color: AppPallete.primaryColor),
                                color: Colors.white,
                                padding: const EdgeInsets.all(16.0),
                              );
                            }
                          }
                          return Container();
                        },
                      ),
                    ],
                    if (isAchiever) ...[
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: statusColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 8.0),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
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
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                challengeUser.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                challengeUser.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: sortedParticipants.length,
                  itemBuilder: (context, index) {
                    final participant = sortedParticipants[index];
                    final isOwner =
                        participant.idUser == challengeUser.authorId;
                    final isCurrentUser = participant.idUser == userId;

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(participant.user.urlProfilePhoto),
                        ),
                        title: Row(
                          children: [
                            if (isOwner)
                              const Icon(Icons.star,
                                  color: AppPallete.whiteColor),
                            const SizedBox(width: 4),
                            if (isCurrentUser)
                              const Text('Moi')
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  child: const Text(
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 0),
                          ),
                          child: const Text(
                            'Lancer',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        );
                      }
                    }
                    return Container();
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  child: const Text(
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
          title: const Text('Confirmer la suppression'),
          content: const Text('Voulez-vous vraiment supprimer ce challenge ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                context
                    .read<ChallengesUsersBloc>()
                    .add(DeleteChallengeEvent(challengeUser.id));
                Navigator.of(context).pop();
                if (bottomSheetContext != null) {
                  Navigator.of(bottomSheetContext!).pop();
                }
                _refreshChallengesUsers();
              },
              child:
                  const Text('Supprimer', style: TextStyle(color: Colors.red)),
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
      shape: const RoundedRectangleBorder(
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

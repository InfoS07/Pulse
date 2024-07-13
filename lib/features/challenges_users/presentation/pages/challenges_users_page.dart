import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/core/utils/bottom_sheet.dart';
import 'package:pulse/features/challenges_users/domain/models/challenges_users_model.dart';
import 'package:pulse/features/challenges_users/presentation/bloc/challenges_users_bloc.dart';
import 'package:pulse/features/exercices/presentation/bloc/exercices_bloc.dart';
import 'package:pulse/features/profil/presentation/bloc/profil_bloc.dart';

class ChallengeUserPage extends StatefulWidget {
  @override
  _ChallengeUserPageState createState() => _ChallengeUserPageState();
}

class _ChallengeUserPageState extends State<ChallengeUserPage> {
  String? userId;
  BuildContext? bottomSheetContext;
  List<Profil> followers = [];
  List<Profil> followings = [];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AppUserCubit>().state;
    if (authState is AppUserLoggedIn) {
      userId = authState.user.uid;
      context.read<ChallengesUsersBloc>().add(ChallengesUsersGetChallenges());
      context.read<ExercicesBloc>().add(ExercicesLoad());
      context.read<ProfilBloc>().add(ProfilGetProfil(userId!));
    }
  }

  Future<void> _refreshChallengesUsers() async {
    context.read<ChallengesUsersBloc>().add(ChallengesUsersGetChallenges());
    context.read<ExercicesBloc>().add(ExercicesLoad());
    context.read<ProfilBloc>().add(ProfilGetProfil(userId!));
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
              BlocListener<ProfilBloc, ProfilState>(
                listener: (context, state) {
                  if (state is ProfilSuccess) {
                    followers = state.followers;
                    followings = state.followings;
                    setState(() {});
                    // Appeler setState ici pour mettre à jour les variables d'état si nécessaire
                  } else if (state is ProfilFailure) {
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
                    child: ListView(
                      children: [
                        // Section explicative
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: AppPallete.backgroundColorDarker,
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Défis utilisateur',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 22),
                              Text(
                                'Mesurez-vous à vos amis grâce aux défis. Participez aux défis créés par vos amis ou créez les vôtres pour comparer vos performances.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16.0),

                        // Liste des challenges
                        filteredChallenges.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 60.0),
                                    Image(
                                      image:
                                          AssetImage('assets/images/heart.png'),
                                      width: 150,
                                    ),
                                    SizedBox(height: 16),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 30.0),
                                      child: Text(
                                        'Aucun défis pour le moment.',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.all(16.0),
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
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
                                  return _buildChallengeUserCard(context,
                                      challengeUser!, followers, followings);
                                },
                              ),
                      ],
                    ),
                  );
                } else if (state is ChallengesUsersError) {
                  return Center(child: Text('Failed to fetch challenge users'));
                }
                return Center(child: Text('Aucun défis'));
              },
            ),
          );
  }

  Widget _buildChallengeUserCard(
      BuildContext context,
      ChallengeUserModel challengeUser,
      List<Profil> followers,
      List<Profil> followings) {
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
        color: AppPallete.backgroundColor,
        shape: RoundedRectangleBorder(
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
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  _formatEndTime(challengeUser.endAt),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              SizedBox(height: 16),
              if (isAuthor) ...[
                ElevatedButton(
                  onPressed: () =>
                      _showDeleteConfirmationDialog(context, challengeUser),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 8.0),
                  ),
                  child: const Text(
                    'Supprimer',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ] else
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
                          print('isParticipant: $isParticipant');
                          print('state: $state');
                          if (state is ExercicesLoaded) {
                            final exercise = _findExercise(
                                state.exercisesByCategory,
                                challengeUser.training.exerciseId);
                            if (exercise != null) {
                              return IconButton(
                                onPressed: () {
                                  context.push('/activitychallenge', extra: {
                                    "exercise": exercise,
                                    "challengeUser": challengeUser
                                  });
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
                      BlocBuilder<ExercicesBloc, ExercicesState>(
                        builder: (context, state) {
                          if (state is ExercicesLoaded) {
                            final exercise = _findExercise(
                                state.exercisesByCategory,
                                challengeUser.training.id);
                            if (exercise != null) {
                              return IconButton(
                                onPressed: () {
                                  context.push('/activity', extra: exercise);
                                },
                                icon: Icon(Icons.play_arrow,
                                    color: AppPallete.primaryColor),
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

  String _formatEndTime(DateTime? endAt) {
    if (endAt == null) {
      return 'Fin : Non définie';
    }
    final now = DateTime.now();
    final duration = endAt.difference(now);

    if (duration.isNegative) {
      return 'Terminé';
    } else if (duration.inDays > 0) {
      return '${duration.inDays} jour${duration.inDays > 1 ? 's' : ''} restants';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h restantes';
    } else if (duration.inMinutes > 0) {
      return 'Termine dans ${duration.inMinutes}min';
    } else {
      return 'Termine dans moins d\'une minute';
    }
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
    print("sortedParticipants: $sortedParticipants");

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
                            isCurrentUser ? AppPallete.primaryColorFade : null,
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
                SizedBox(
                  height: 8,
                ),
                ElevatedButton(
                  onPressed: () => _showAddFriendsDialog(
                      context, challengeUser, followers, followings),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    minimumSize:
                        Size(double.infinity, 0), // Occupe toute la largeur
                  ),
                  child: Text(
                    'Ajouter des amis',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ] else if (isParticipant && !isAchiever) ...[
                BlocBuilder<ExercicesBloc, ExercicesState>(
                  builder: (context, state) {
                    if (state is ExercicesLoaded) {
                      final exercise = _findExercise(
                          state.exercisesByCategory, challengeUser.training.id);
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
                            minimumSize: Size(
                                double.infinity, 0), // Occupe toute la largeur
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
                    padding: EdgeInsets.symmetric(vertical: 16),
                    minimumSize:
                        Size(double.infinity, 0), // Occupe toute la largeur
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
          content: const Text('Voulez-vous vraiment supprimer ce défis ?'),
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

  void _showAddFriendsDialog(
      BuildContext context,
      ChallengeUserModel challengeUser,
      List<Profil> followers,
      List<Profil> followings) {
    final mutualFollowers = _getMutualFollowers(followers, followings);
    final invitedFriends = challengeUser.invites
        .toSet(); // Supposons que `invites` est une liste des IDs des amis invités

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final _formKey = GlobalKey<FormState>();
        final selectedFriends = <String>{};

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Ajouter des amis au défis'),
              content: mutualFollowers.isEmpty
                  ? Text(
                      'Vous devez suivre mutuellement des amis pour les inviter à des défis.')
                  : Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: mutualFollowers.map((friend) {
                          final isAlreadyInvited =
                              invitedFriends.contains(friend.uid);
                          return CheckboxListTile(
                            title: Text(
                              '${friend.firstName} ${friend.lastName}',
                              style: TextStyle(
                                  color: isAlreadyInvited
                                      ? Colors.grey
                                      : Colors.white),
                            ),
                            value: selectedFriends.contains(friend.uid),
                            onChanged: isAlreadyInvited
                                ? null
                                : (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedFriends.add(friend.uid);
                                      } else {
                                        selectedFriends.remove(friend.uid);
                                      }
                                    });
                                  },
                          );
                        }).toList(),
                      ),
                    ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Annuler'),
                ),
                if (mutualFollowers.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        if (bottomSheetContext != null) {
                          Navigator.of(bottomSheetContext!)
                              .pop(); // Ferme la bottom sheet
                        }
                        context.read<ChallengesUsersBloc>().add(
                            AddInvitesToChallengeEvent(
                                challengeUser.id, selectedFriends.toList()));
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text('Ajouter'),
                  ),
              ],
            );
          },
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

List<Profil> _getMutualFollowers(
    List<Profil> followers, List<Profil> followings) {
  final followingsSet = followings.map((p) => p.uid).toSet();
  return followers.where((f) => followingsSet.contains(f.uid)).toList();
}

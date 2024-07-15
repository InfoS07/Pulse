import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/core/utils/bottom_sheet_util.dart';
import 'package:pulse/features/home/presentation/widgets/exercise_card_widget.dart';
import 'package:pulse/features/profil/presentation/bloc/profil_bloc.dart';
import 'package:pulse/features/challenges_users/domain/models/challenges_users_model.dart';
import 'package:pulse/features/challenges_users/presentation/bloc/challenges_users_bloc.dart';
import 'package:pulse/features/exercices/presentation/bloc/exercices_bloc.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toasty_box.dart';

class ChallengeUserDetailsPage extends StatefulWidget {
  final ChallengeUserModel challengeUser;

  const ChallengeUserDetailsPage({required this.challengeUser, Key? key})
      : super(key: key);

  @override
  _ChallengeUserDetailsPageState createState() =>
      _ChallengeUserDetailsPageState();
}

class _ChallengeUserDetailsPageState extends State<ChallengeUserDetailsPage> {
  String? userId;
  BuildContext? bottomSheetContext;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AppUserCubit>().state;
    if (authState is AppUserLoggedIn) {
      userId = authState.user.uid;
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
    final isParticipant = widget.challengeUser.participants
        .any((participant) => participant.user.uid == userId);
    final isAchiever = isParticipant &&
        widget.challengeUser.participants
                .firstWhere((participant) => participant.user.uid == userId)
                .score >
            0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Défis', style: TextStyle(color: Colors.white)),
        actions: [
          if (userId == widget.challengeUser.author.uid)
            PopupMenuButton<String>(
              color: AppPallete.popUpBackgroundColor,
              tooltip: 'Plus d\'options',
              onSelected: (String result) {
                if (result == 'delete') {
                  _showDeleteDialog();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Supprimer le défis'),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: AppPallete.backgroundColorDarker,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.challengeUser.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.challengeUser.description,
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.challengeUser
                          .endAt, //_formatEndTime(widget.challengeUser.endAt),
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "${widget.challengeUser.training.repetitions} ${widget.challengeUser.type} nécessaires",
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    if (isParticipant && !isAchiever)
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to activity
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPallete.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text('Participer',
                            style: TextStyle(color: Colors.white)),
                      ),
                    if (!isParticipant)
                      ElevatedButton(
                        onPressed: () {
                          context.read<ChallengesUsersBloc>().add(
                              JoinChallengeEvent(
                                  widget.challengeUser.id, userId!));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPallete.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text('Accepter',
                            style: TextStyle(color: Colors.white)),
                      ),
                    if (isAchiever)
                      Container(
                        child: SizedBox(
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
                            child: const Text(
                              'Terminé',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    if (userId == widget.challengeUser.author.uid)
                      Container(
                        child: SizedBox(
                          width: double.infinity, // Button takes the full width
                          child: ElevatedButton(
                            onPressed: () => _showAddFriendsDialog(
                                context, widget.challengeUser),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppPallete.secondaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text(
                              'Ajouter des amis',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 30),
                    ExerciseCardWidget(
                      exerciseTitle: widget.challengeUser.training.title,
                      exerciseUrlPhoto:
                          widget.challengeUser.training.exercice.photos.first,
                      onTap: () {
                        context.push(
                            '/exercices/details/${widget.challengeUser.training.exercice.id}',
                            extra: widget.challengeUser.training.exercice);
                      },
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Classement',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.challengeUser.participants.length,
              itemBuilder: (context, index) {
                final participant =
                    widget.challengeUser.participants.elementAt(index);
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 2.0,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(participant.user.urlProfilePhoto),
                    ),
                    title: Text(
                      '${participant.user.firstName} ${participant.user.lastName}',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Text(
                      'Score: ${participant.score}',
                      style: TextStyle(color: AppPallete.primaryColor),
                    ),
                  ),
                );
              },
            ),
          ],
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
      return 'Le challenge est terminé';
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

  void _showDeleteDialog() {
    BottomSheetUtil.showCustomBottomSheet(
      context,
      onConfirm: () {
        _showDeleteConfirmationDialog(context, widget.challengeUser);

        ToastService.showSuccessToast(
          context,
          length: ToastLength.long,
          expandedHeight: 100,
          message: "Défis supprimé",
        );
      },
      buttonText: 'Supprimer le défis',
      buttonColor: Colors.red,
      confirmTextColor: Colors.white,
      cancelText: 'Annuler',
      cancelTextColor: Colors.grey,
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

                ToastService.showSuccessToast(
                  context,
                  length: ToastLength.long,
                  expandedHeight: 100,
                  message: "Défis supprimé",
                );
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
      BuildContext context, ChallengeUserModel challengeUser) {
    final profilState = context.read<ProfilBloc>().state;
    if (profilState is ProfilSuccess) {
      final mutualFollowers =
          _getMutualFollowers(profilState.followers, profilState.followings);
      final invitedFriends = challengeUser.invites.toSet();

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
                                        : Colors.black),
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
    } else {
      ToastService.showErrorToast(
        context,
        length: ToastLength.long,
        expandedHeight: 100,
        message: "Impossible de récupérer les abonnés",
      );
    }
  }

  List<Profil> _getMutualFollowers(
      List<Profil> followers, List<Profil> followings) {
    final followingsSet = followings.map((p) => p.uid).toSet();
    return followers.where((f) => followingsSet.contains(f.uid)).toList();
  }
}

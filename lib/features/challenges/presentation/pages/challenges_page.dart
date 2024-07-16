import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/core/utils/bottom_sheet.dart';
import 'package:pulse/features/challenges/domain/models/challenges_model.dart';
import 'package:pulse/features/challenges/domain/models/data_challenge_activity.dart';
import 'package:pulse/features/challenges/presentation/bloc/challenges_bloc.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/features/challenges_users/presentation/pages/challenges_users_page.dart';
import 'package:pulse/features/exercices/presentation/bloc/exercices_bloc.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toasty_box.dart';

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
          centerTitle: true,
          title: const Text('Challenges'),
          bottom: const TabBar(
            indicatorColor: AppPallete.primaryColor,
            indicatorWeight: 3.0,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
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
            ? const Center(child: CircularProgressIndicator())
            : MultiBlocListener(
                listeners: [
                  BlocListener<ChallengesBloc, ChallengesState>(
                    listener: (context, state) {
                      if (state is ChallengesError) {
                        ToastService.showErrorToast(
                          context,
                          length: ToastLength.long,
                          expandedHeight: 100,
                          message: state.message,
                        );
                      }
                    },
                  ),
                  BlocListener<ExercicesBloc, ExercicesState>(
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
                  ),
                ],
                child: BlocBuilder<ChallengesBloc, ChallengesState>(
                  builder: (context, state) {
                    if (state is ChallengesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ChallengesError) {
                      return Center(child: Text('Error: ${state.message}'));
                    } else if (state is ChallengesSuccess) {
                      List<ChallengesModel?> allChallenges =
                          _mapChallenges(state.challenges, false);

                      return TabBarView(
                        children: [
                          RefreshIndicator(
                            onRefresh: _refreshChallenges,
                            child: ListView(
                              children: [
                                // Section explicative
                                _buildHeaderSection(),
                                const SizedBox(height: 16.0),
                                _buildChallengesList(allChallenges)
                              ],
                            ),
                            /* child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeaderSection(),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: _buildChallengesList(allChallenges),
                                ),
                              ],
                            ), */
                          ),
                          ChallengeUserPage(),
                        ],
                      );
                    } else {
                      return const Center(child: Text('No Challenges'));
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
        // attention j'ai _TypeError (Null check operator used on a null value)
        final timeRemaining =
            challenge!.endAt!.difference(DateTime.now()) ?? Duration();
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

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: AppPallete.backgroundColorDarker,
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Challenges hebdomadaires',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
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
      ],
    );
  }

  Widget _buildChallengesList(List<ChallengesModel?> challenges) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        return _buildChallengeCard(challenges[index]!);
      },
    );
  }

  Widget _buildChallengeCard(ChallengesModel challenge) {
    final isParticipant = challenge.participants?.contains(userId!) ?? false;
    final isAchiever = challenge.achievers?.contains(userId!) ?? false;
    String status;
    Color statusColor;
    Color textColor = Colors.black;
    Color buttonColor = AppPallete.primaryColorFade;
    Color iconColor = Colors.white;
    Function()? onPressed;

    if (isAchiever) {
      status = 'Terminé';
      statusColor = AppPallete.primaryColor;
    } else if (isParticipant) {
      status = 'Accepté';
      statusColor = AppPallete.primaryColorFade;
      textColor = AppPallete.primaryColor;
    } else {
      status = 'Accepter';
      statusColor = AppPallete.primaryColor;
    }

    if (!isParticipant && !isAchiever) {
      onPressed = () {
        context
            .read<ChallengesBloc>()
            .add(JoinChallenge(challenge.id, userId!));
      };
    } else if (isParticipant && !isAchiever) {
      onPressed = () {
        context
            .read<ChallengesBloc>()
            .add(QuitChallenge(challenge.id, userId!));
      };
    }

    return GestureDetector(
      onTap: () {
        _showChallengeDetailsBottomSheet(context, challenge);
      },
      child: Card(
        color: AppPallete.backgroundColorDarker,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                challenge.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                challenge.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              Spacer(),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isParticipant && !isAchiever ||
                      isParticipant && !isAchiever) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: statusColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 5),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(color: textColor, fontSize: 12),
                        ),
                      ),
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
      BuildContext context, ChallengesModel challenge) {
    final Duration timeRemaining = challenge.endAt!.difference(DateTime.now());
    final int daysRemaining = timeRemaining.inDays;
    final int points = challenge.points;

    final isParticipant = challenge.participants?.contains(userId!) ?? false;
    final isAchiever = challenge.achievers?.contains(userId!) ?? false;

    BottomSheeChallengeUtil.showCustomBottomSheet(
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
              DataChallengeActivity activity = DataChallengeActivity(
                  exercice: exercise,
                  points: challenge.points,
                  repetitions: challenge.numbers,
                  idChallenge: challenge.id);
              context.go('/activityClassicChallenge', extra: exercise);
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
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                challenge.description,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 16),
              if (daysRemaining > 0) ...[
                Text(
                  'Temps restant: $daysRemaining jours',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                'Points: $points',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 24),
              if (isParticipant && !isAchiever) ...[
                SizedBox(
                  width: double.infinity, // Button takes the full width
                  child: ElevatedButton(
                    onPressed: () {
                      final exerciseId = challenge.exerciceId;
                      final state = context.read<ExercicesBloc>().state;
                      if (state is ExercicesLoaded) {
                        final exercise = _findExercise(
                            state.exercisesByCategory, exerciseId!);
                        if (exercise != null) {
                          DataChallengeActivity activity =
                              DataChallengeActivity(
                                  exercice: exercise,
                                  points: challenge.points,
                                  repetitions: challenge.numbers,
                                  idChallenge: challenge.id);
                          context.push('/activityClassicChallenge',
                              extra: activity);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPallete.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                    child: const Text(
                      'Lancer',
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context
                          .read<ChallengesBloc>()
                          .add(QuitChallenge(challenge.id, userId!));
                      Navigator.of(context).pop();
                      _refreshChallenges();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPallete.errorColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                    child: const Text(
                      'Quitter',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ],
              if (!isParticipant && !isAchiever) ...[
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<ChallengesBloc>()
                        .add(JoinChallenge(challenge.id, userId!));
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize:
                        const Size(double.infinity, 0), // Occupies full width
                  ),
                  child: const Text(
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize:
                        const Size(double.infinity, 0), // Occupies full width
                  ),
                  child: const Text(
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
        if (exercise?.id == exerciseId) {
          return exercise;
        }
      }
    }
    return null;
  }
}

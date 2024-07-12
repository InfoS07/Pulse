import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/core/common/entities/social_media_post.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/core/utils/bottom_sheet_util.dart';
import 'package:pulse/core/utils/formatters.dart';
import 'package:pulse/features/home/presentation/bloc/home_bloc.dart';
import 'package:pulse/features/home/presentation/widgets/action_buttons_post_widget.dart';
import 'package:pulse/features/home/presentation/widgets/exercise_card_widget.dart';
import 'package:pulse/features/home/presentation/widgets/image_list_view.dart';
import 'package:pulse/features/home/presentation/widgets/title_description_post_widget.dart';
import 'package:pulse/features/home/presentation/widgets/user_profile_post_header.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toasty_box.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pulse/features/challenges_users/presentation/bloc/challenges_users_bloc.dart';

class PostDetailsPage extends StatefulWidget {
  final int postId;

  const PostDetailsPage({super.key, required this.postId});

  @override
  _PostDetailsPageState createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  String? userId;
  SocialMediaPost? post;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AppUserCubit>().state;
    if (authState is AppUserLoggedIn) {
      userId = authState.user.uid;
    }

    final homeState = context.read<HomeBloc>().state;
    if (homeState is HomeLoaded) {
      post = homeState.posts[widget.postId];
    }
  }

  void toggleLike() {
    if (post != null) {
      BlocProvider.of<HomeBloc>(context).add(LikePost(post!.id));
    }
  }

  void _showDeleteDialog() {
    if (post != null) {
      BottomSheetUtil.showCustomBottomSheet(
        context,
        onConfirm: () {
          BlocProvider.of<HomeBloc>(context).add(DeletePost(post!.id));
          context.go('/home');

          ToastService.showSuccessToast(
            context,
            length: ToastLength.long,
            expandedHeight: 100,
            message: "Entrainement supprimé",
          );
        },
        buttonText: 'Supprimer l\'entrainement',
        buttonColor: Colors.red,
        confirmTextColor: Colors.white,
        cancelText: 'Annuler',
        cancelTextColor: Colors.grey,
      );
    }
  }

  void _showCreateChallengeUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final _formKey = GlobalKey<FormState>();
        String challengeName = '';
        String description = '';
        DateTime endDate =
            DateTime.now(); // Implement date picker or use a predefined date
        String type = 'Répétitions'; // Example, modify based on user input
        List<String> invites = [userId!]; // Example, modify based on user input

        return AlertDialog(
          title: Text('Créer un Défi Utilisateur'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Nom du Défi'),
                  onSaved: (value) => challengeName = value ?? '',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom pour le défi';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Description'),
                  onSaved: (value) => description = value ?? '',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Date de fin'),
                  readOnly: true,
                  controller: TextEditingController(
                    text: DateFormat('dd/MM/yyyy').format(endDate),
                  ),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: endDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null && pickedDate != endDate) {
                      setState(() {
                        endDate = pickedDate;
                      });
                    }
                  },
                  validator: (value) {
                    // Implement validation if needed
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: type,
                  onChanged: (newValue) {
                    setState(() {
                      type = newValue!;
                    });
                  },
                  items: ['Répétitions', 'Durée'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Type'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(
                'Créer',
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // Dispatch an event to create the challenge user
                  context.read<ChallengesUsersBloc>().add(CreateChallengeEvent(
                        challengeName: challengeName,
                        description: description,
                        endDate: endDate,
                        trainingId:
                            post!.exercice.id, // Modify based on your data
                        authorId: userId!,
                        type: type,
                        invites: invites,
                        createdAt: DateTime.now(),
                        participant: {
                          '1': {'score': 0, 'idUser': userId}
                        },
                      ));
                  Navigator.of(context).pop();
                }
              },
            ),
            SizedBox(
              width: 25,
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          post?.title ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          if (userId == post?.userUid)
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
                  child: Text('Supprimer l\'entraînement'),
                ),
              ],
            ),
        ],
      ),
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HomeLoaded) {
            post = state.posts[widget.postId];

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    color: AppPallete.backgroundColorDarker,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 28.0, top: 28.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (post != null) ...[
                            UserProfilePostHeader(
                              profileImageUrl: post!.profileImageUrl ??
                                  'https://image-uniservice.linternaute.com/image/450/4/1708793598/8469657.jpg',
                              username: post!.username,
                              timestamp: post!.timestamp,
                              onTap: () {
                                String userId = post!.userUid;
                                context.push('/otherProfil', extra: userId);
                              },
                            ),
                            const SizedBox(height: 18),
                            TitleDescriptionWidget(
                              title: post!.title,
                              description: post!.description,
                            ),
                            const SizedBox(height: 18),
                            if (post!.photos.isNotEmpty) ...[
                              const SizedBox(height: 19),
                              ImageListWidget(imageUrls: post!.photos),
                            ],
                            const SizedBox(height: 18),
                            ExerciseCardWidget(
                              exerciseTitle: post!.exercice.title,
                              exerciseUrlPhoto: post!.exercice.photos.first,
                              onTap: () {
                                context.push(
                                    '/exercices/details/${post!.exercice.id}',
                                    extra: post!.exercice);
                              },
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildInfoCard(
                                        formatDurationTraining(
                                          post!.startAt,
                                          post!.endAt,
                                        ),
                                        'Durée'),
                                    _buildInfoCard(
                                        '${post!.repetitions}', 'Répétitions'),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildInfoCard("0ms", 'Réaction moyen'),
                                    _buildInfoCard('230', 'calories kcal'),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ActionButtonsPostWidget(
                              isLiked: post!.isLiked,
                              likeCount: post!.likes,
                              onLikeTap: toggleLike,
                              commentCount: post!.comments.length,
                              onCommentTap: () {
                                context.push(
                                    '/home/details/${post!.id}/comments',
                                    extra: post);
                              },
                            ),
                            const SizedBox(height: 40),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: SizedBox(
                                width: double
                                    .infinity, // Button takes the full width
                                child: ElevatedButton(
                                  onPressed: () {
                                    _showCreateChallengeUserDialog(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppPallete.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                  ),
                                  child: Text(
                                    'Créer un défi',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            const Center(child: Text('Post not found')),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 22),
                ),
                SliverToBoxAdapter(
                  child: _buildAnalysisSection(),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 22),
                ),
                SliverToBoxAdapter(
                  child: _buildAnalysisTouchSection(),
                )
              ],
            );
          } else if (state is HomeError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('Erreur !'));
          }
        },
      ),
    );
  }

  Widget _buildInfoCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection() {
    return Container(
      color: AppPallete.backgroundColorDarker,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analyse du temps de réaction',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 3),
                      const FlSpot(1, 1),
                      const FlSpot(2, 4),
                      const FlSpot(3, 3),
                      const FlSpot(4, 2),
                      const FlSpot(5, 4),
                      const FlSpot(6, 5),
                    ],
                    isCurved: true,
                    color: AppPallete.thirdColor,
                    barWidth: 2,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [AppPallete.thirdColor, AppPallete.thirdColor]
                            .map((color) => color.withOpacity(0.3))
                            .toList(),
                      ),
                    ),
                  ),
                ],
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, interval: 1),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false, interval: 1),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false, interval: 1),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, interval: 1),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTouchSection() {
    return Container(
      color: AppPallete.backgroundColorDarker,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analyse des touches',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 3),
                      const FlSpot(1, 1),
                      const FlSpot(2, 4),
                      const FlSpot(3, 3),
                      const FlSpot(4, 2),
                      const FlSpot(5, 4),
                      const FlSpot(6, 5),
                    ],
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 2,
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, interval: 1),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, interval: 1),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false, interval: 1),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false, interval: 1),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

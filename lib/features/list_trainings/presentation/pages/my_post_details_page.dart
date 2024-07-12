import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/core/common/entities/social_media_post.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/core/utils/formatters.dart';
import 'package:pulse/features/challenges_users/presentation/bloc/challenges_users_bloc.dart';
import 'package:pulse/features/home/presentation/bloc/home_bloc.dart';
import 'package:pulse/features/home/presentation/widgets/action_buttons_post_widget.dart';
import 'package:pulse/features/home/presentation/widgets/exercise_card_widget.dart';
import 'package:pulse/features/home/presentation/widgets/image_list_view.dart';
import 'package:pulse/features/home/presentation/widgets/like_comment_count_widget.dart';
import 'package:pulse/features/home/presentation/widgets/title_description_post_widget.dart';
import 'package:pulse/features/home/presentation/widgets/user_profile_post_header.dart';
import 'package:pulse/core/utils/bottom_sheet_util.dart'; // Ajoutez cette ligne
import 'package:intl/intl.dart';

class PostMyDetailsPage extends StatefulWidget {
  final SocialMediaPost post;

  const PostMyDetailsPage({super.key, required this.post});

  @override
  _PostMyDetailsPageState createState() => _PostMyDetailsPageState();
}

class _PostMyDetailsPageState extends State<PostMyDetailsPage> {
  String? userId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AppUserCubit>().state;
    if (authState is AppUserLoggedIn) {
      userId = authState.user.uid;
    }
  }

  void toggleLike() {
    setState(() {
      BlocProvider.of<HomeBloc>(context).add(LikePost(widget.post.id));
    });
  }

  void _showDeleteDialog() {
    BottomSheetUtil.showCustomBottomSheet(
      context,
      onConfirm: () {
        // si l'auteur de la publication est l'utilisateur connecté
        // alors on peut supprimer la publication
        BlocProvider.of<HomeBloc>(context).add(DeletePost(widget.post.id));
        context.go('/home');
      },
      buttonText: 'Supprimer l\'entrainement',
      buttonColor: Colors.red,
      confirmTextColor: Colors.white,
      cancelText: 'Annuler',
      cancelTextColor: Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppPallete.backgroundColor,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          if (userId == widget.post.userUid)
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
      body: SingleChildScrollView(
        child: Container(
          color: AppPallete.backgroundColor,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 28.0, top: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserProfilePostHeader(
                  profileImageUrl: widget.post.profileImageUrl,
                  username: widget.post.username,
                  timestamp: widget.post.timestamp,
                  onTap: () {
                    context.push('/otherProfil', extra: userId);
                  },
                ),
                const SizedBox(height: 18),
                TitleDescriptionWidget(
                  title: widget.post.title,
                  description: widget.post.description,
                ),
                const SizedBox(height: 18),
                if (widget.post.photos.isNotEmpty) ...[
                  const SizedBox(height: 19),
                  ImageListWidget(imageUrls: widget.post.photos),
                ],
                const SizedBox(height: 18),
                ExerciseCardWidget(
                  exerciseTitle: widget.post.exercice.title,
                  exerciseUrlPhoto: widget.post.exercice.photos.first,
                  onTap: () {
                    context.push(
                        '/exercices/details/${widget.post.exercice.id}',
                        extra: widget.post.exercice);
                  },
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoCard(
                      formatDurationTraining(
                          widget.post.startAt, widget.post.endAt),
                      'Durée',
                    ),
                    _buildInfoCard('230', 'calories kcal'),
                  ],
                ),
                const SizedBox(height: 18),
                LikeCommentCountWidget(
                  likeCount: widget.post.likes,
                  commentCount: widget.post.comments.length,
                ),
                const SizedBox(height: 18),
                ActionButtonsPostWidget(
                  isLiked: widget.post.isLiked,
                  likeCount: widget.post.likes,
                  commentCount: widget.post.comments.length,
                  onLikeTap: toggleLike,
                  onCommentTap: () {
                    context.push('/home/details/${widget.post.id}/comments',
                        extra: widget.post);
                  },
                ),
                const SizedBox(height: 18),
                // Bouton pour créer un ChallengeUser
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _showCreateChallengeUserDialog(context);
                    },
                    child: Text(
                      'Créer un défi utilisateur',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
                        trainingId: widget
                            .post.exercice.id, // Modify based on your data
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
}

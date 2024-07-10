import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/core/common/entities/social_media_post.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/core/utils/formatters.dart';
import 'package:pulse/features/home/presentation/bloc/home_bloc.dart';
import 'package:pulse/features/home/presentation/widgets/action_buttons_post_widget.dart';
import 'package:pulse/features/home/presentation/widgets/exercise_card_widget.dart';
import 'package:pulse/features/home/presentation/widgets/image_list_view.dart';
import 'package:pulse/features/home/presentation/widgets/like_comment_count_widget.dart';
import 'package:pulse/features/home/presentation/widgets/title_description_post_widget.dart';
import 'package:pulse/features/home/presentation/widgets/user_profile_post_header.dart';
import 'package:pulse/core/utils/bottom_sheet_util.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toasty_box.dart';

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
            message: "Entrainement ${post!.id} supprimé",
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
            return SingleChildScrollView(
              child: Container(
                color: AppPallete.backgroundColorDarker,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 28.0, top: 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post != null) ...[
                        UserProfilePostHeader(
                          profileImageUrl: post!.profileImageUrl,
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
                            _buildInfoCard(
                                formatDurationTraining(
                                  post!.startAt,
                                  post!.endAt,
                                ),
                                'Durée'),
                            _buildInfoCard('230', 'calories kcal'),
                          ],
                        ),
                        const SizedBox(height: 18),
                        LikeCommentCountWidget(
                          likeCount: post!.likes,
                          commentCount: post!.comments.length,
                        ),
                        const SizedBox(height: 18),
                        ActionButtonsPostWidget(
                          isLiked: post!.isLiked,
                          onLikeTap: toggleLike,
                          onCommentTap: () {
                            context.push('/home/details/${post!.id}/comments',
                                extra: post);
                          },
                        ),
                      ] else ...[
                        const Center(child: Text('Post not found')),
                      ],
                    ],
                  ),
                ),
              ),
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
}

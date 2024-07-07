import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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

class SocialMediaPostWidget extends StatefulWidget {
  final SocialMediaPost post;
  final VoidCallback onTap;

  const SocialMediaPostWidget(
      {super.key, required this.post, required this.onTap});

  @override
  _SocialMediaPostWidgetState createState() => _SocialMediaPostWidgetState();
}

class _SocialMediaPostWidgetState extends State<SocialMediaPostWidget> {
  void toggleLike() {
    setState(() {
      BlocProvider.of<HomeBloc>(context).add(LikePost(widget.post.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 28.0, top: 28.0),
        color: AppPallete.backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserProfilePostHeader(
              profileImageUrl: widget.post.profileImageUrl,
              username: widget.post.username,
              timestamp: widget.post.timestamp,
              onTap: () {
                //context.push('/otherProfil');
              },
            ),
            const SizedBox(height: 22),
            TitleDescriptionWidget(
              title: widget.post.title,
              description: widget.post.description,
            ),
            const SizedBox(height: 18),
            ExerciseCardWidget(
              exerciseTitle: widget.post.exercice.title,
              exerciseUrlPhoto: widget.post.exercice.photos.first,
              onTap: () {
                context.push('/exercices/details/${widget.post.exercice.id}',
                    extra: widget.post.exercice);
              },
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Temps',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        formatDurationTraining(
                          widget.post.startAt,
                          widget.post.endAt,
                        ), // Example value, replace with your actual data
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (widget.post.photos.isNotEmpty) ...[
              const SizedBox(height: 19),
              ImageListWidget(imageUrls: widget.post.photos),
            ],
            const SizedBox(height: 18),
            LikeCommentCountWidget(
              likeCount: widget.post.likes,
              commentCount: widget.post.comments.length,
            ),
            const SizedBox(height: 18),
            ActionButtonsPostWidget(
              isLiked: widget.post.isLiked,
              onLikeTap: toggleLike,
              onCommentTap: () {
                context.push('/home/details/${widget.post.id}/comments',
                    extra: widget.post);
              },
            ),
          ],
        ),
      ),
    );
  }
}

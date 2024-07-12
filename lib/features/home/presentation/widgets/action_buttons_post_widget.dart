import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/features/home/presentation/widgets/like_button.dart';

class ActionButtonsPostWidget extends StatelessWidget {
  final bool isLiked;
  final VoidCallback onLikeTap;
  final int likeCount;
  final VoidCallback onCommentTap;
  final int commentCount;

  const ActionButtonsPostWidget({
    super.key,
    required this.isLiked,
    required this.likeCount,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.commentCount,
  });

  Future<bool> onLikeButtonTapped(bool isLiked) async {
    onLikeTap();
    return !isLiked;
  }

  Future<bool> onCommentButtonTapped(bool isLiked) async {
    onCommentTap();
    return !isLiked;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        LikeButton(
          onTap: onLikeButtonTapped,
          circleColor: CircleColor(
              start: AppPallete.primaryColor, end: AppPallete.secondaryColor),
          bubblesColor: BubblesColor(
            dotPrimaryColor: AppPallete.primaryColor,
            dotSecondaryColor: AppPallete.secondaryColor,
          ),
          likeBuilder: (_) {
            return Icon(
              isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
              color: isLiked ? AppPallete.primaryColor : Colors.white,
            );
          },
          size: 40,
          countPostion: CountPostion.right,
          likeCount: likeCount,
        ),
        const SizedBox(width: 18),
        LikeButton(
          onTap: onCommentButtonTapped,
          likeBuilder: (_) {
            return const Icon(
              Icons.comment,
              color: Colors.white,
            );
          },
          size: 40,
          countPostion: CountPostion.right,
          likeCount: commentCount,
        ),
      ],
    );
  }
}

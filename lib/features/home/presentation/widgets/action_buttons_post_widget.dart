import 'package:flutter/material.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/features/home/presentation/widgets/like_button.dart';

class ActionButtonsPostWidget extends StatelessWidget {
  final bool isLiked;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;

  const ActionButtonsPostWidget({super.key, 
    required this.isLiked,
    required this.onLikeTap,
    required this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        LikeButton(
          onTap: onLikeTap,
          icon: isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
          color: isLiked ? AppPallete.primaryColor : Colors.white,
        ),
        const SizedBox(width: 18),
        GestureDetector(
          onTap: onCommentTap,
          child: const Row(
            children: [
              Icon(Icons.comment, color: Colors.white),
            ],
          ),
        ),
      ],
    );
  }
}

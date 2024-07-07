import 'package:flutter/material.dart';

class LikeCommentCountWidget extends StatelessWidget {
  final int likeCount;
  final int commentCount;

  const LikeCommentCountWidget({super.key, required this.likeCount, required this.commentCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$likeCount personnes aiment',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Text(
            '$commentCount commentaires',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pulse/core/common/entities/comment.dart';
import 'package:pulse/core/common/entities/social_media_post.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/core/utils/formatters.dart';
import 'package:pulse/features/home/presentation/widgets/user_profile_post_header.dart';

class CommentsPage extends StatelessWidget {
  final SocialMediaPost post;

  const CommentsPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussion'),
        scrolledUnderElevation: 0,
        backgroundColor: AppPallete.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserProfilePostContainer(
            profileImageUrl: post.profileImageUrl,
            username: post.username,
            timestamp: post.timestamp,
            title: post.title,
            commentCount: post.comments.length,
            onTap: () {
              //context.push('/otherProfil');
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: post.comments.length,
              itemBuilder: (context, index) {
                final comment = post.comments[index];
                return Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(comment.profileImageUrl),
                        radius: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  comment.username,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  formatTimestamp(comment.createdAt),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              comment.content,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserProfilePostContainer extends StatelessWidget {
  final String profileImageUrl;
  final String username;
  final String timestamp;
  final String title;
  final int commentCount;
  final VoidCallback onTap;

  UserProfilePostContainer({
    required this.profileImageUrl,
    required this.username,
    required this.timestamp,
    required this.title,
    required this.commentCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppPallete.backgroundColor, // Fond gris
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserProfilePostHeader(
            profileImageUrl: profileImageUrl,
            username: username,
            timestamp: timestamp,
            onTap: onTap,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Icon(Icons.comment, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  '$commentCount commentaires',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UserProfilePostHeader extends StatelessWidget {
  final String profileImageUrl;
  final String username;
  final String timestamp;
  final VoidCallback onTap;

  UserProfilePostHeader({
    required this.profileImageUrl,
    required this.username,
    required this.timestamp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(profileImageUrl),
      ),
      title: Text(
        username,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        formatTimestamp(timestamp),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 10,
        ),
      ),
      onTap: onTap,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pulse/core/theme/app_pallete.dart';

class SocialMediaPost {
  final String profileImageUrl;
  final String username;
  final String timestamp;
  final String title;
  final String content;
  final String postImageUrl;
  final int likes;
  final int comments;

  SocialMediaPost({
    required this.profileImageUrl,
    required this.username,
    required this.timestamp,
    required this.title,
    required this.content,
    required this.postImageUrl,
    required this.likes,
    required this.comments,
  });
}

class SocialMediaPostWidget extends StatelessWidget {
  final SocialMediaPost post;
  final VoidCallback onTap; // Ajouter un callback

  SocialMediaPostWidget({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Définir l'action du callback
      child: Container(
        padding: EdgeInsets.all(16.0),
        color: Color.fromARGB(221, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(post.profileImageUrl),
                  radius: 20,
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      post.timestamp,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 22),
            Text(
              post.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 4),
            Text(
              post.content,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0), // Rounded corners
              child: Image.network(
                post.postImageUrl,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite, color: AppPallete.primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      post.likes.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(width: 18),
                Row(
                  children: [
                    Icon(Icons.comment, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      post.comments.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

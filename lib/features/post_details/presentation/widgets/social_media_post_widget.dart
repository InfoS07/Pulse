import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/entities/social_media_post.dart';
import 'package:pulse/core/theme/app_pallete.dart';

class SocialMediaPostWidget extends StatelessWidget {
  final SocialMediaPost post;

  const SocialMediaPostWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: const Color.fromARGB(221, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // Ajouter l'action de navigation
                  context.push('/otherProfil');
                },
                child: CircleAvatar(
                  backgroundImage: NetworkImage(post.profileImageUrl),
                  radius: 20,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.userUid,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    post.timestamp,
                    //size: 12,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            post.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            post.description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0), // Rounded corners
            child: Image.network(
              post.photos.first,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: AppPallete.primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    post.likes.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(width: 18),
              Row(
                children: [
                  const Icon(Icons.comment, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    post.comments.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

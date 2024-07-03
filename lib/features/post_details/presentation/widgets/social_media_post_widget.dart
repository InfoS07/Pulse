import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/entities/social_media_post.dart';
import 'package:pulse/core/theme/app_pallete.dart';

class SocialMediaPostWidget extends StatelessWidget {
  final SocialMediaPost post;

  SocialMediaPostWidget({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
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
            post.description,
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
    );
  }
}

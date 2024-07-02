import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/widgets/exercise_card.dart';
import 'package:pulse/features/home/presentation/widgets/filter_button.dart';
import 'package:pulse/features/home/presentation/widgets/social_media_post_widget.dart';
import 'package:pulse/features/home/presentation/widgets/week_days_widget.dart';

import 'package:flutter/material.dart';

class PostDetailsPage extends StatelessWidget {
  final SocialMediaPost post;

  PostDetailsPage({required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Ajouter l'action de navigation
                      String userId = "24";
                      context.push('/otherProfil',extra: userId);
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
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        post.timestamp,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                post.title,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                post.content,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  post.postImageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Chip(
                    label: Text('Cardio'),
                    backgroundColor: Colors.grey[800],
                  ),
                  SizedBox(width: 8),
                  Chip(
                    label: Text('Course'),
                    backgroundColor: Colors.grey[800],
                  ),
                  Spacer(),
                  FaIcon(
                    FontAwesomeIcons.fire,
                    color: Colors.orange,
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoCard('00:12:45', 'Durée'),
                  _buildInfoCard('230', 'calories kcal'),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      context.push('/home/details/1/likes');
                    },
                    child: Container(
                      child: Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            '${post.likes} j\'aime',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.push('/home/details/1/comments',
                          extra: post.comments);
                    },
                    child: Container(
                      child: Row(
                        children: [
                          Icon(Icons.comment, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            '${post.comments.length} commentaires',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String value, String label) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

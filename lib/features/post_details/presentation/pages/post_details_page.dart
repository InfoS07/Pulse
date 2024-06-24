import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/widgets/exercise_card.dart';
import 'package:pulse/features/home/presentation/widgets/filter_button.dart';
import 'package:pulse/features/home/presentation/widgets/social_media_post_widget.dart';
import 'package:pulse/features/home/presentation/widgets/week_days_widget.dart';

import 'package:flutter/material.dart';

class PostDetailsPage extends StatelessWidget {
  final int postIndex;

  PostDetailsPage({this.postIndex = 0});

  final List<SocialMediaPost> allPosts = List.generate(
    10,
    (index) => SocialMediaPost(
      profileImageUrl:
          'https://media.licdn.com/dms/image/C5603AQGS7eAEozhDzw/profile-displayphoto-shrink_200_200/0/1562875334307?e=2147483647&v=beta&t=Pp3nnMsNgTceqPRuxDHG1NU-3wEA_hQR3lL5ru1Ghvw',
      username: 'Eric $index',
      timestamp: '12/01/2024 - 12:${45 + index}',
      title: 'Course à pied',
      content:
          'Je viens de faire la meilleure séance de ma vie, incroyable je recommande cet exo :)',
      postImageUrl:
          'https://images.pexels.com/photos/317157/pexels-photo-317157.jpeg?auto=compress&cs=tinysrgb&w=600',
      likes: 20 + index,
      comments: 4 + index,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final post = allPosts[postIndex];

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
                'Une séance bien dure',
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
                  Icon(
                    Icons.local_fire_department,
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
              SizedBox(height: 8),
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
                      context.push('/home/details/$postIndex/likes');
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
                      context.push('/home/details/$postIndex/comments');
                    },
                    child: Container(
                      child: Row(
                        children: [
                          Icon(Icons.comment, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            '${post.comments} commentaires',
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

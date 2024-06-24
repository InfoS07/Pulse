import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/widgets/exercise_card.dart';
import 'package:pulse/features/home/presentation/widgets/filter_button.dart';
import 'package:pulse/features/home/presentation/widgets/social_media_post_widget.dart';
import 'package:pulse/features/home/presentation/widgets/week_days_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedFilter = 'Tout';

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

  final List<SocialMediaPost> myPosts = List.generate(
    2,
    (index) => SocialMediaPost(
      profileImageUrl:
          'https://images.pexels.com/photos/317157/pexels-photo-317157.jpeg?auto=compress&cs=tinysrgb&w=600',
      username: 'Moi $index',
      timestamp: '12/01/2024 - 12:${45 + index}',
      title: 'Course à pied',
      content: 'Ma meilleure séance de course à pied :)',
      postImageUrl:
          'https://images.pexels.com/photos/317157/pexels-photo-317157.jpeg?auto=compress&cs=tinysrgb&w=600',
      likes: 30 + index,
      comments: 5 + index,
    ),
  );

  final List<SocialMediaPost> subscriberPosts = List.generate(
    3,
    (index) => SocialMediaPost(
      profileImageUrl:
          'https://images.pexels.com/photos/317157/pexels-photo-317157.jpeg?auto=compress&cs=tinysrgb&w=600',
      username: 'Abonné $index',
      timestamp: '12/01/2024 - 12:${45 + index}',
      title: 'Course à pied',
      content: 'Incroyable séance de course à pied par un abonné :)',
      postImageUrl:
          'https://images.pexels.com/photos/317157/pexels-photo-317157.jpeg?auto=compress&cs=tinysrgb&w=600',
      likes: 25 + index,
      comments: 3 + index,
    ),
  );

  List<SocialMediaPost> get filteredPosts {
    switch (selectedFilter) {
      case 'Moi':
        return myPosts;
      case 'Abonné':
        return subscriberPosts;
      case 'Tout':
      default:
        return allPosts;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pulse App'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 100,
              child: WeekDaysWidget(),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 200,
              child: _buildRecommendedExercises(),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 18),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  FilterButton(
                    text: 'Tout',
                    isSelected: selectedFilter == 'Tout',
                    onTap: () {
                      setState(() {
                        selectedFilter = 'Tout';
                      });
                    },
                  ),
                  SizedBox(width: 16),
                  FilterButton(
                    text: 'Moi',
                    isSelected: selectedFilter == 'Moi',
                    onTap: () {
                      setState(() {
                        selectedFilter = 'Moi';
                      });
                    },
                  ),
                  SizedBox(width: 16),
                  FilterButton(
                    text: 'Abonné',
                    isSelected: selectedFilter == 'Abonné',
                    onTap: () {
                      setState(() {
                        selectedFilter = 'Abonné';
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 8),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: SocialMediaPostWidget(
                    post: filteredPosts[index],
                    onTap: () {
                      context.go(
                          '/home/details/$index'); //,extra: filteredPosts[index]);
                    },
                  ),
                );
              },
              childCount: filteredPosts.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedExercises() {
    final List<Map<String, dynamic>> recommendedExercises = [
      {
        'title': 'Squat touch press',
        'people': 1,
        'pods': 4,
        'image':
            'https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg?auto=compress&cs=tinysrgb&w=600',
      },
      {
        'title': 'Squat touch press',
        'people': 2,
        'pods': 4,
        'image':
            'https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg?auto=compress&cs=tinysrgb&w=600',
      },
      {
        'title': 'Squat touch press',
        'people': 3,
        'pods': 4,
        'image':
            'https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg?auto=compress&cs=tinysrgb&w=600',
      },
    ];

    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recommendedExercises.length,
        itemBuilder: (context, index) {
          final exercise = recommendedExercises[index];
          return ExerciseCard(
            exercise: exercise,
            onTap: () {
              context.push('/exercices/details');
            },
          );
        },
      ),
    );
  }
}
